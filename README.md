## Sensu-Plugins-Zookeeper

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-zookeeper.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-zookeeper)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-zookeeper.svg)](http://badge.fury.io/rb/sensu-plugins-zookeeper)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-zookeeper)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-zookeeper.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-zookeeper)
[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-zookeeper)

## Sensu Asset
The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator or handler), make sure you include the corresponding Sensu Ruby runtime asset in the list of assets needed by the resource. The current ruby-runtime assets can be found [here](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the [Bonsai Asset Index](bonsai.sensu.io).

## Functionality

## Files

* check-znode.rb - Check if zookeeper znode exists and optionally match its contents
* check-zookeeper-file-descriptors.rb - Check if Zookeeper has normal opened file descriptors rate
* check-zookeeper-latency.rb - Check average latency on Zookeeper node
* check-zookeeper-reqs.rb - Check if Zookeeper node has reliable number of outstanding requests
* check-zookeeper-ruok.rb - Check if Zookeeper node responds to 'ruok' query succesfully
* check-zookeeper-mode.rb - Check if Zookeeper node is in standalone or cluster(leader or follower) mode
* check-zookeeper-cluster.rb - Check if a exhibitor managed Zookeeper cluster is OK.
* check-netty-zookeeper-cluster.rb - Check if a zookeeper 3.5 cluster is OK.
* metrics-zookeeper.rb - Gather metrics from Zookeeper
* metrics-zookeeper-cluster.rb - Gather metrics from An Exhibitor run Zookeeper cluster

## Usage
```
$ check-znode.rb --help
Usage: ./bin/check-znode.rb (options)
    -v, --check_value REGEX          Optionally check the znode value against a regex
    -s, --servers zk-address         zk address to connect to (required)
    -z, --znode ZNODE                znode to check (required)
```

```
$ check-zookeeper-file-descriptors.rb --help
Usage: ./bin/check-zookeeper-file-descriptors.rb (options)
    -d DESCRIPTORS,                  Critical threshold for Zookeeper open files descriptors
        --file-descriptors
    -p, --port PORT                  Zookeeper port to connect to.
    -s, --server HOSTNAME            Zookeeper hostname to connect to.
    -t, --timeout SECS               How long to wait for a reply in seconds.

```

```
$ check-zookeeper-cluster.rb --help
Usage: ./bin/check-zookeeper-cluster.rb (options)
    -c, --count count                Zookeeper cluster node count
    -e, --exhibitor status end point exhibitor end node for status checks
    -l, --latency TICKS              Critical threshold for Zookeeper average latency
    -t, --timeout SECS               How long to wait for a reply in seconds.
    -p, --port port                  Zookeeper nodes' listen port

```

```
$ check-netty-zookeeper-cluster.rb --help
Usage: ./bin/check-netty-zookeeper-cluster.rb (options)
    -c, --count count                Zookeeper cluster follower count
    -l, --latency TICKS              Critical threshold for Zookeeper average latency
    -p, --port port                  Zookeeper nodes' listen port

```

```
$ metrics-zookeeper.rb --help
Usage: ./bin/metrics-zookeeper.rb (options)
        --host HOST                  ZooKeeper host
        --port PORT                  ZooKeeper port
        --scheme SCHEME              Metric naming scheme, text to prepend to metrics

```

```
$ metrics-zookeeper-cluster.rb --help
Usage: ./bin/metrics-zookeeper-cluster.rb (options)
    -e, --exhibitor status end point exhibitor end node for status checks
        --scheme SCHEME              Metric naming scheme, text to prepend to metrics
    -p, --port port                  Zookeeper nodes' listen port

```

```
$ check-zookeeper-ruok.rb --help
Usage: ./bin/check-zookeeper-ruok.rb (options)
    -p, --port PORT                  Zookeeper port to connect to.
    -s, --server HOSTNAME            Zookeeper hostname to connect to.
    -t, --timeout SECS               How long to wait for a reply in seconds.
```

```
$ check-zookeeper-reqs.rb --help
Usage: ./bin/check-zookeeper-reqs.rb (options)
    -r, --reqs REQS                  Critical threshold for Zookeeper outstanding requests
    -p, --port PORT                  Zookeeper port to connect to.
    -s, --server HOSTNAME            Zookeeper hostname to connect to.
    -t, --timeout SECS               How long to wait for a reply in seconds.
```

```
$ check-zookeeper-mode.rb --help 
Usage check-zookeeper-mode.rb (options)
    -m, --mode MODE                  Space separated expected modes. (required)
    -p, --port PORT                  Zookeeper port to connect to.
    -s, --server HOSTNAME            Zookeeper hostname to connect to.
    -t, --timeout SECS               How long to wait for a reply in seconds.
```

```
$ check-zookeeper-latency.rb --help 
Usage: ./bin/check-zookeeper-latency.rb (options)
    -l, --latency TICKS              Critical threshold for Zookeeper average latency
    -p, --port PORT                  Zookeeper port to connect to.
    -s, --server HOSTNAME            Zookeeper hostname to connect to.
    -t, --timeout SECS               How long to wait for a reply in seconds.

```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
