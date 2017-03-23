#!/usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-mode
#
# DESCRIPTION:
#   Check if Zookeeper node is in expected mode.
#
#   'mode' is ZooKeeper's mode which can be standalone or in a cluster.
#   In cluster mode a Zookeeper node can be either leader or follower.
#   We use stat command to get the mode and check if zookeeper node is a
#   standalone or leader or follower.
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if a node has Zookeeper running and responds with imok.
#  ./check-zookeeeper-mode.rb -m 'leader follower'
#  ./check-zookeeeper-mode.rb -s localhost -p 2181 -m 'leader follower'
#  ./check-zookeeeper-mode.rb --server localhost --port 2181 --mode 'leader follower'
#

require 'sensu-plugin/check/cli'
require 'socket'

class CheckZookeeperMode < Sensu::Plugin::Check::CLI
  option :server,
         description: 'Zookeeper hostname to connect to.',
         short: '-s HOSTNAME',
         long: '--server HOSTNAME',
         default: 'localhost'

  option :port,
         description: 'Zookeeper port to connect to.',
         short: '-p PORT',
         long: '--port PORT',
         default: 2181

  option :timeout,
         description: 'How long to wait for a reply in seconds.',
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         default: 5

  option :mode,
         description: 'Space separated expected modes.',
         short: '-m MODE',
         long: '--mode MODE',
         required: true

  def zk_command(four_letter_word)
    Socket.tcp(config[:server], config[:port]) do |sock|
      sock.print "#{four_letter_word}\r\n"
      sock.close_write
      sock.read
    end
  end

  def run
    response = zk_command(:stat)
    mode = get_mode(response)
    expected_modes = config[:mode].split
    if expected_modes.include?(mode)
      ok(mode)
    else
      critical("Zookeeper mode is #{mode} and it does not match #{expected_modes.join(', ')}")
    end
  end

  private

  def get_mode(response)
    response.each_line do |line|
      line = line.chomp
      k, v = line.split(': ')
      return v if k == 'Mode'
    end
  end
end
