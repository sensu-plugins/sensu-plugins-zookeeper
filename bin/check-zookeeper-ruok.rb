#!/usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-ruok
#
# DESCRIPTION:
#   Check if Zookeeper node responds to 'ruok' query succesfully.
#
#   'ruok' is a ZooKeeper four letter word command (short for Are You Okay?)
#   Specifically ruok tests if the server is running in a non-error state.
#   The server will respond with imok if it is running. Otherwise it will
#   not respond at all.
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if a node has Zookeeper running and responds with imok.
#  ./check-zookeeeper-ruok.rb # Equivalent to examples below
#  ./check-zookeeeper-ruok.rb -s localhost -p 2181
#  ./check-zookeeeper-ruok.rb --server localhost --port 2181
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

  def run
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write 'ruok'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to 'ruok' within #{config[:timeout]} seconds)
      end

      result = ready.first.first.read.chomp

      ok 'Zookeeper reports no errors' if result == 'imok'
      critical %(Zookeeper returned a non okay message: '#{result}')
    end
  end
end
