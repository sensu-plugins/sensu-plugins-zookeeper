#!/usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-file-descriptors.rb
#
# DESCRIPTION:
#   Check if Zookeeper has normal opened file descriptors rate.
#
#   'mntr' is a ZooKeeper four letter word command, which outputs
#   a list of variables that could be used for monitoring
#   the health of the cluster.
#
#   Specifically file-descriptors.rb tests if the server has normal amount of opened file descriptors.
#   Opened file descriptors rate is defined as (AVG_amount / MAX_amount).
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if a node has Zookeeper running and responds with imok.
#  ./check-zookeeeper-file-descriptors.rb.rb # Equivalent to examples below
#  ./check-zookeeeper-file-descriptors.rb.rb -s localhost -p 2181 -d 0.85
#  ./check-zookeeeper-file-descriptors.rb.rb --server localhost --port 2181 --file-descriptors 0.85
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

  option :fd_critical,
         description: 'Critical threshold for Zookeeper open files descriptors',
         short: '-d DESCRIPTORS',
         long: '--file-descriptors DESCRIPTORS',
         proc: proc(&:to_f),
         default: 0.85

  def run
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write 'mntr'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to 'mntr' within #{config[:timeout]} seconds)
      end

      result = ready.first.first.read.chomp.split("\n")
      avg_fd = (result[13].split("\t")[1].to_f / result[14].split("\t")[1].to_f)

      ok "Zookeeper's open file descriptors rate is #{avg_fd}" if avg_fd < config[:fd_critical]
      critical %(Zookeeper's open file descriptors rate is #{avg_fd}, which is more than #{config[:fd_critical]} threshold)
    end
  end
end
