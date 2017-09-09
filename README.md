## Sensu-Plugins-Zookeeper

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-zookeeper.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-zookeeper)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-zookeeper.svg)](http://badge.fury.io/rb/sensu-plugins-zookeeper)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-zookeeper.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-zookeeper)

## Functionality

## Files

* check-znode.rb - Check if zookeeper znode exists and optionally match its contents
* check-zookeeper-file-descriptors.rb - Check if Zookeeper has normal opened file descriptors rate
* check-zookeeper-latency.rb - Check average latency on Zookeeper node
* check-zookeeper-reqs.rb - Check if Zookeeper node has reliable number of outstanding requests
* check-zookeeper-ruok.rb - Check if Zookeeper node responds to 'ruok' query succesfully
* check-zookeeper-mode.rb - Check if Zookeeper node is in standalone or cluster(leader or follower) mode
* check-zookeeper-cluster.rb - Check if a exhibitor managed Zookeeper cluster is OK.
* metrics-zookeeper.rb - Gather metrics from Zookeeper
* metrics-zookeeper-cluster.rb - Gather metrics from An Exhibitor run Zookeeper cluster

## Usage

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
