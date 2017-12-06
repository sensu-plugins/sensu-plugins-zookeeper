#!/usr/bin/env ruby
#  encoding: UTF-8

#
#  netty-check-zookeeper-cluster
#
# DESCRIPTION:
#   Check if a Zookeeper 3.5 cluster is OK.
#
#   This check will each verify each node for errors,
#   check averag latency for a threshold value,
#   and if the cluster has a leader, make sure it has the right number of followers.
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  Check if a node has Zookeeper running and responds with imok.
#
#  Cluster should have 3 (n+1) nodes and average latency threshold should be 10
#  ./netty-check-zookeeeper-cluster.rb -c 2 -l 10
#
# LICENCE:
#   Duncan Schulze <duschulze@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'net/http'
require 'json'

class CheckZookeeperCluster < Sensu::Plugin::Check::CLI
  option :netty_port,
         description: 'Zookeeper nodes\' listen port',
         short: '-p port',
         long: '--port port',
         default: 8080,
         proc: proc(&:to_i)

  option :followers,
         description: 'Zookeeper cluster follower count',
         short: '-c count',
         long: '--count count',
         default: 2,
         proc: proc(&:to_i)

  option :latency,
         description: 'Critical threshold for Zookeeper average latency',
         short: '-l TICKS',
         long: '--latency TICKS',
         proc: proc(&:to_i),
         default: 10

  def get_monitoring_output(port)
    uri = URI.parse("http://localhost:#{port}/commands/monitor")
    http = Net::HTTP.new(uri.host, uri.port, read_timeout: 45)
    http.read_timeout = 30
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    JSON.parse(response.body)
  rescue Errno::ECONNREFUSED
    warning 'Connection refused'
  rescue Timeout::Error
    warning 'Connection timed out'
  end

  def are_you_ok
    response = get_monitoring_output(config[:netty_port])
    if response['error'].nil?
      return { success: true,
               message: 'Zookeeper is ok' }
    else
      return { success: false,
               message: 'Zookeeper is not ok, look into the logs' }
    end
  end

  def zookeeper_latency
    response = get_monitoring_output(config[:netty_port])
    if response['avg_latency'].to_i > config[:latecy].to_i
      return { success: false,
               message: %(Zookeeper latency is greater than #{config['latency']} seconds) }
    else
      return { success: true,
               message: 'Zookeeper latency is ok' }
    end
  end

  def follower_count
    response = get_monitoring_output(config[:netty_port])
    if response['server_state'].to_s == 'leader'
      if response['synced_followers'].to_i == config[:followers].to_i
        return { success: true,
                 message: 'Zookeeper follower count is correct' }
      else
        return { success: false,
                 message: %(Zookeeper follower count is not equal to #{config[:followers]}!) }
      end
    else
      return { success: true,
               message: 'Not the leader, follower check does not apply' }
    end
  end

  def run
    results = []
    are_you_ok_result = are_you_ok
    zookeeper_latency_result = zookeeper_latency
    follower_count_result = follower_count

    results.push(are_you_ok_result)
    results.push(zookeeper_latency_result)
    results.push(follower_count_result)

    output = "SUCCESS: #{results.select { |h| h[:success] }.map { |h| h[:message] }}\n FAIL: #{results.reject { |h| h[:success] }.map { |h| h[:message] }}"

    if results.any? { |h| !h[:success] }
      warning output
    else
      ok output
    end
  end
end
