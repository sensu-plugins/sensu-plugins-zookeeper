#!/usr/bin/env ruby
#
#  check-zookeeper-reqs
#
# DESCRIPTION:
#   Check if Zookeeper node has reliable number of outstanding requests.
#
#   'mntr' is a ZooKeeper four letter word command, which outputs
#   a list of variables that could be used for monitoring
#   the health of the cluster
#
#   This check verifies if Zookeeper is not overwhelemed with requests
#   that it cannot proceed
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if Zookeeper doesn't have a lot of outstanding requests
#  ./check-zookeeeper-reqs.rb # Equivalent to examples below
#  ./check-zookeeeper-reqs.rb -s localhost -p 2181 -r 10
#  ./check-zookeeeper-reqs.rb --server localhost --port 2181 --reqs 10
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

  option :out_reqs_critical,
         description: 'Critical threshold for Zookeeper outstanding requests',
         short: '-r REQS',
         long: '--reqs REQS',
         proc: proc(&:to_i),
         default: 10

  def run
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write 'mntr'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to 'mntr' within #{config[:timeout]} seconds)
      end

      result = ready.first.first.read.chomp.split("\n")
      out_reqs = result[7].split("\t")[1].to_i

      ok %(Zookeeper has #{out_reqs} outstanding requests) if out_reqs < config[:out_reqs_critical]
      critical %(Zookeeper has #{out_reqs} outstanding requests, which is more than #{config[:out_reqs_critical]} threshold)
    end
  end
end
