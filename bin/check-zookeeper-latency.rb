#!/usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-latency
#
# DESCRIPTION:
#   Check average latency on Zookeeper node.
#
#   'mntr' is a ZooKeeper four letter word command, which outputs
#   Specifically latency is an amount of time it takes for the server
#   to respond to a client request (since the server was started).
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if a node has Zookeeper running and responds with imok.
#  ./check-zookeeeper-latency.rb # Equivalent to examples below
#  ./check-zookeeeper-latency.rb -s localhost -p 2181 -l 10
#  ./check-zookeeeper-latency.rb --server localhost --port 2181 --latency 10
#
# LICENCE:
#   Phil Grayson <phil@philgrayson.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'socket'

class CheckZookeeperREQS < Sensu::Plugin::Check::CLI
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

  option :avg_latency_critical,
         description: 'Critical threshold for Zookeeper average latency',
         short: '-l TICKS',
         long: '--latency TICKS',
         proc: proc(&:to_i),
         default: 10

  def run
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write 'mntr'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical "Zookeeper did not respond to 'mntr' within #{config[:timeout]} seconds"
      end

      result = ready.first.first.read.chomp.split("\n")
      avg_latency = result[1].split("\t")[1].to_i

      ok "Zookeeper has average latency #{avg_latency}" if avg_latency < config[:avg_latency_critical]
      critical "Zookeeper's average latency is #{avg_latency}, which is more than #{config[:avg_latency_critical]} threshold"
    end
  end
end
