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

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metrics',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.zookeeper"

  def dotted(*args)
    args.join('.')
  end

  def zk_command(four_letter_word)
    Socket.tcp(config[:host], config[:port]) do |sock|
      sock.print "#{four_letter_word}\r\n"
      sock.close_write
      sock.read
    end
  end

  def run
    timestamp = Time.now.to_i
    response  = zk_command(:srvr) + zk_command(:wchs)
    metrics   = {}

    if response =~ /^Sent: (\d+)$/
      metrics[:sent] = Regexp.last_match(1).to_i
    end

    if response =~ /^Received: (\d+)$/
      metrics[:received] = Regexp.last_match(1).to_i
    end

    if response =~ /^Connections: (\d+)$/
      metrics[:connections] = Regexp.last_match(1).to_i
    end

    if response =~ /^Outstanding: (\d+)$/
      metrics[:outstanding] = Regexp.last_match(1).to_i
    end

    if response =~ /^Node count: (\d+)$/
      metrics[:node_count] = Regexp.last_match(1).to_i
    end

    if response =~ /^Latency min\/avg\/max: (\d+)\/(\d+)\/(\d+)$/
      metrics[:latency_min] = Regexp.last_match(1).to_i
      metrics[:latency_avg] = Regexp.last_match(2).to_i
      metrics[:latency_max] = Regexp.last_match(3).to_i
    end

    if response =~ /^Total watches:\s*(\d+)$/
      metrics[:watches_total] = Regexp.last_match(1).to_i
    end

    if response =~ /watching (\d+) paths/
      metrics[:watches_paths] = Regexp.last_match(1).to_i
    end

    metrics.each do |metric, value|
      output dotted(config[:scheme], metric), value, timestamp
    end

    ok
  end
end
