#!/usr/bin/env ruby
#
# metrics-zookeeper.rb
#
# Collect ZooKeeper metrics
# ===
#
# DESCRIPTION:
# This plugin gathers metrics from an Exhibitor run ZooKeeper cluster,
# based on the collectd plugin:
#
#   https://github.com/Nextdoor/collectd_plugins/blob/master/zookeeper/zookeeper.sh
#
#
# PLATFORMS:
#   Linux, BSD, Solaris
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# LICENSE:
# Sean Clemmer sczizzo@gmail.com
# Released under the same terms as Sensu (the MIT license); see LICENSE
#  for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'
require 'net/http'
require 'json'

class ZookeeperMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :exhibitor,
         description: 'exhibitor end node for status checks',
         short: '-e Exhibitor status end point',
         long: '--exhibitor status end point',
         default: 'http://localhost/exhibitor/v1/cluster/status'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metrics',
         long: '--scheme SCHEME',
         default: 'zookeeper'

  def dotted(*args)
    args.join('.')
  end

  def zk_command(four_letter_word, host, port)
    Socket.tcp(host, port) do |sock|
      sock.print "#{four_letter_word}\r\n"
      sock.close_write
      sock.read
    end
  end

  def exhibitor_status
    response = json = ''
    url = URI.parse(config[:exhibitor])
    req = Net::HTTP::Get.new(url.path)
    [1..3].each do
      Net::HTTP.new(url.host, url.port).start do |http|
        response = http.request(req)
      end
      next unless response.is_a? Net::HTTPRedirection
    end
    if response.is_a? Net::HTTPSuccess
          JSON.parse(response.body)
    else
          [false, json, ['exhibitor status is not http 200']]
    end
  end

  def run
    timestamp = Time.now.to_i

    json = exhibitor_status
    json.each do |zk|
      hostname = zk['hostname']
      response  = zk_command(:mntr, hostname, 2181)
      metrics   = {}

      if response =~ /^zk_avg_latency\s*(\d+)$/
        metrics[:zk_avg_latency] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_max_latency\s*(\d+)$/
        metrics[:zk_max_latency] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_min_latency\s*(\d+)$/
        metrics[:zk_min_latency] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_packets_received\s*(\d+)$/
        metrics[:zk_packets_received] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_packets_sent\s*(\d+)$/
        metrics[:zk_packets_sent] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_num_alive_connections\s*(\d+)$/
        metrics[:zk_num_alive_connections] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_outstanding_requests\s*(\d+)$/
        metrics[:zk_outstanding_requests] = Regexp.last_match(1).to_i
      end

      metrics[:zk_is_leader] = if response =~ /^zk_server_state\s*leader$/
                                 1
                               else
                                 0
                               end

      if response =~ /^zk_znode_count\s*(\d+)$/
        metrics[:zk_znode_count] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_watch_count\s*(\d+)$/
        metrics[:zk_watch_count] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_ephemerals_count\s*(\d+)$/
        metrics[:zk_ephemerals_count] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_approximate_data_size\s*(\d+)$/
        metrics[:zk_approximate_data_size] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_open_file_descriptor_count\s*(\d+)$/
        metrics[:zk_open_file_descriptor_count] = Regexp.last_match(1).to_i
      end

      if response =~ /^zk_max_file_descriptor_count\s*(\d+)$/
        metrics[:zk_max_file_descriptor_count] = Regexp.last_match(1).to_i
      end

      metrics[:zk_followers] = if response =~ /^zk_followers\s*(\d+)$/
                                 Regexp.last_match(1).to_i
                               else
                                 0
                               end

      metrics[:zk_synced_followers] = if response =~ /^zk_synced_followers\s*(\d+)$/
                                        Regexp.last_match(1).to_i
                                      else
                                        0
                                      end

      metrics[:zk_pending_syncs] = if response =~ /^zk_pending_syncs\s*(\d+)$/
                                     Regexp.last_match(1).to_i
                                   else
                                     0
                                   end

      metrics.each do |metric, value|
        output dotted(config[:scheme], hostname, metric), value, timestamp
      end
    end
    ok
  end
end
