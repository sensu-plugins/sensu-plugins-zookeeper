#!/usr/bin/env ruby
#
# metrics-zookeeper.rb
#
# Collect ZooKeeper metrics
# ===
#
# DESCRIPTION:
# This plugin gathers metrics from ZooKeeper, based on the collectd plugin:
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

class ZookeeperMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
         description: 'ZooKeeper host',
         long: '--host HOST',
         default: 'localhost'

  option :port,
         description: 'ZooKeeper port',
         long: '--port PORT',
         proc: proc(&:to_i),
         default: 2181

  option :timeout,
         description: 'How long to wait for a reply in seconds.',
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         default: 5

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metrics',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.zookeeper"

  def dotted(*args)
    args.join('.')
  end

  def zk_command(four_letter_word)
    TCPSocket.open(config[:server], config[:port]) do |socket|
      socket.write four_letter_word.to_s
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to '#{four_letter_word}' within #{config[:timeout]} seconds)
      end
      result = ready.first.first.read.chomp
      return result
    end
  end

  def run
    timestamp = Time.now.to_i
    response  = zk_command(:mntr)
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
      output dotted(config[:scheme], metric), value, timestamp
    end

    ok
  end
end
