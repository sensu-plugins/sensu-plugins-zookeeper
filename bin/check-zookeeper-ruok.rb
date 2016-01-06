#! /usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-ruok
#
# DESCRIPTION:
#   check if zookeeper node responds with imok
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  check if a node has zookeeper running and responds with imok
#  ./check-zookeeepr-ruok.rb # Equivalent to examples below
#  ./check-zookeeepr-ruok.rb -s localhost -p 2181
#  ./check-zookeeepr-ruok.rb --server localhost --port 2181
#
# LICENCE:
#   Phil Grayson <phil@philgrayson.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'socket'

class CheckZookeeperRUOK < Sensu::Plugin::Check::CLI
  option :server,
         description: 'zookeeper hostname to connect to',
         short: '-s HOSTNAME',
         long: '--server HOSTNAME',
         default: 'localhost'

  option :port,
         description: 'zk port to connect to',
         short: '-p PORT',
         long: '--port PORT',
         default: 2181

  option :timeout,
         description: 'how long to wait for a reply in seconds',
         short: '-t TIMEOUT',
         long: '--timeout PORT',
         proc: proc(&:to_i),
         default: 5

  def run
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write 'ruok'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to 'ruok' within #{config[:timeout]} seconds)
      end

      result = ready.first.first.read.chomp

      ok %(Got '#{result}') if result == 'imok'
      critical %(Got '#{result}')
    end
  end
end
