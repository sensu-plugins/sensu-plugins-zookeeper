#!/usr/bin/env ruby
#  encoding: UTF-8
#
#  check-zookeeper-cluster
#
# DESCRIPTION:
#   Check if a exhibitor managed Zookeeper cluster is OK.
#
#   This check will get exhibitor status information,
#   and check each seperate node for ruok.
#   This check also will compare cluster node count with a spesific value,
#   avg latency from mntr for a threshold value, and If the cluster
#   has a leader.
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
#  Cluster should have 3 nodes, exhibitor status endpoint is not default, and average latency threshold should be 10
#  ./check-zookeeeper-cluster.rb -c 3 -e http://localhost:8181/exhibitor/v1/cluster/status -l 10
#

require 'sensu-plugin/check/cli'
require 'socket'
require 'net/http'
require 'json'

class CheckZookeeperCluster < Sensu::Plugin::Check::CLI
  option :count,
         description: 'Zookeeper cluster node count',
         short: '-c count',
         long: '--count count',
         default: 3,
         proc: proc(&:to_i)

  option :zk_port,
         description: 'Zookeeper nodes\' listen port',
         short: '-p port',
         long: '--port port',
         default: 2181,
         proc: proc(&:to_i)

  option :count,
         description: 'Zookeeper cluster node count',
         short: '-c count',
         long: '--count count',
         default: 3,
         proc: proc(&:to_i)

  option :exhibitor,
         description: 'exhibitor end node for status checks',
         short: '-e Exhibitor status end point',
         long: '--exhibitor status end point',
         default: 'http://localhost/exhibitor/v1/cluster/status'

  option :latency,
         description: 'Critical threshold for Zookeeper average latency',
         short: '-l TICKS',
         long: '--latency TICKS',
         proc: proc(&:to_i),
         default: 10

  option :timeout,
         description: 'How long to wait for a reply in seconds.',
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         default: 5

  def zookeeper_latency(server, port)
    l = 0
    TCPSocket.open(server, port) do |socket|
      socket.write 'mntr'
      ready = IO.select([socket], nil, nil, config[:timeout])
      if ready.nil?
        critical %(Zookeeper did not respond to 'mntr' within #{config[:timeout]} seconds)
      end
      l = ready.first.first.read.chomp.split("\n")[1].split("\t")[1].to_i
    end
  end

  def check_ruok(server, port)
    result = false
    TCPSocket.open(server, port) do |socket|
      socket.write 'ruok'
      ready = IO.select([socket], nil, nil, config[:timeout])

      if ready.nil?
        critical %(Zookeeper did not respond to 'ruok' within #{config[:timeout]} seconds)
      end

      result = ready.first.first.read.chomp
    end
    result == 'imok'
  end

  def _leader_count(json)
    l_count = max_latency = 0
    json.each do |zk|
      l_count += 1 if zk['isLeader']
      l = zookeeper_latency(zk['hostname'], config[:zk_port])
      max_latency = [max_latency, l].max
    end
    [l_count, max_latency]
  end

  def _check_leader(json)
    e = []
    l_count, max_latency = _leader_count(json)
    unless l_count == 1
      e.push("cluster should have a leader (#{l_count})")
    end
    if max_latency > config[:latency]
      e.push("cluster should have a lower latecy #{max_latency}")
    end
    return [true, e] if l_count == 1 && max_latency < config[:latency]
    [false, e]
  end

  def check_exhibitor_endpoint(response)
    json = JSON.parse(response.body)
    e = []
    r = false
    if json.length == config[:count]
      r, e = _check_leader(json)
    else
      e = ["cluster size mismatch (#{json.length}!=#{config[:count]})"]
    end
    [r, json, e]
  end

  def check_exhibitor
    response = ''
    json = ''
    url = URI.parse(config[:exhibitor])
    req = Net::HTTP::Get.new(url.path)
    Net::HTTP.new(url.host, url.port).start do |http|
      response = http.request(req)
    end
    return [false, json, ['exhibitor status is not http 200']] unless
      response.is_a? Net::HTTPSuccess
    r, json, e = check_exhibitor_endpoint(response)
    [r, json, e]
  end

  def check_each_zk(json)
    r = true
    hosts = []
    json.each do |zk|
      r = check_ruok(zk['hostname'], config[:zk_port])
      hosts.push(zk['hostname'])
      return [false, ["#{zk['hostname']} is not ok"]] unless r
    end
    [true, hosts]
  end

  def run
    result, json, errors = check_exhibitor
    result, errors = check_each_zk(json) if result
    message errors.join(', ')
    ok if result
    critical
  end
end
