#! /usr/bin/env ruby
#
#  check-znode
#
# DESCRIPTION:
#   check if zookeeper znode exists and optionally match its contents
#
# OUTPUT:
#   check status (ok or critical)
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: zookeeper
#
# USAGE:
#  check if znode /test exists with value starting with 'test'
#  ./check-znode.rb -s localhost:2181 -z /test -v '^test.*'
#  ./check-znode.rb -s localhost:2181 -z /test -c '^test.*'
#
# NOTES:
#  Multiple zk servers are accepted, e.g. zk01:2181,zk02:2181,zk03:2181
#
# LICENSE:
#   Raghu Udiyar <raghusiddarth@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'zookeeper'

class CheckZnode < Sensu::Plugin::Check::CLI
  option :server,
         description: 'zk address to connect to',
         short: '-s',
         long: '--servers zk-address',
         required: true

  option :znode,
         description: 'znode to check',
         short: '-z',
         long: '--znode ZNODE',
         required: true

  option :check_value,
         description: 'Optionally check the znode value against a regex',
         short: '-v',
         long: '--check_value REGEX'

  option :check_child,
         description: 'Optionally check for child node against a regex',
         short: '-c',
         long: '--check_child REGEX'
  
  def znode_status
    zk = Zookeeper.new(config[:server])
    znode = zk.get(path: config[:znode])
    children = config[:check_child] ? "#{zk.get_children(path: config[:znode])[:children]}" : null

    if znode[:stat].exists?
      if config[:check_value]
        if Regexp.new(config[:check_value]).match(znode[:data])
          ok "#{config[:znode]} value matched regexp '#{config[:check_value]}'"
        elsif config[:check_child]
          if children.include?(config[:check_child])
            ok "#{config[:znode]} has child regexp match for '#{config[:check_child]}'"
          else
            critical "#{config[:znode]} doesn't have child regexp match for '#{config[:check_child]}'"
          end
        else
          critical "#{config[:znode]} value didn't match regexp '#{config[:check_value]}'"
        end
      else
        ok "znode #{config[:znode]} exists"
      end
    else
      critical "znode #{config[:znode]} does not exist"
    end
  end

  def run
    znode_status
  end
end
