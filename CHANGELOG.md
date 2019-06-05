# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Our CHANGELOG Guidelines ](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md).
Which is based on [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

## [2.0.1] - 2019-06-05
### Added
- check-znode.rb: added flag of `--check_child|-c` to allow for checking for child node(s) against a regex. (@mattboston)

## [2.0.0] - 2018-01-18
### Security
- updated rubocop dependency to `~> 0.51.0` per: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8418. (@thomasriley)

### Breaking Changes
- removed < ruby 2.1 support which was pulled as part of security updates (@thomasriley)

### Changed
- Various amendments to comply with Rubocop (@thomasriley)

## [1.5.0] - 2017-12-06
### Added
- check-netty-zookeeper-cluster.rb: new script to check if a zookeeper v. 3.5 cluster is OK (@duncaan)

## [1.4.0] - 2017-10-31
### Added
- Added zookeeper port option to metrics-zookeeper-cluster.rb

### Fixed
- Fixed a return bug in case of an error on metrics-zookeeper-cluster.rb

## [1.3.0] - 2017-09-09
### Added
- metrics-zookeeper-cluster.rb: new script to gather metrics from a zookeeper cluster (@fsniper)

### Changed
- metrics-zookeeper-cluster.rb: use the plugin name + version as the default user agent over some arbitrary version of curl (@majormoses)
- updated PR template and CHANGELOG with new CHANGELOG guideline location (@majormoses)

### Fixed
- spelling in PR template (@majormoses)

## [1.2.0] - 2017-08-28
### Added
- check-zookeper-cluster
- Ruby 2.4.1 testing

## [1.1.0] - 2017-03-23
- add `check-zookeeper-mode` to check if zookeeper is in the expected mode (@karthik-altiscale)

## [1.0.0] - 2017-03-21
### Added
- check-zookeeper-reqs (@grem11n)
- check-zookeeper-latency (@grem11n)
- check-zookeeper-file-descriptors (@grem11n)
- support for Ruby 2.3.0 (@eheydrick)
- `metrics-zookeeper.rb`: Switch to using the `mntr` command to gather metrics and add additional metrics (@jasiek191)

### Removed
- support for Ruby 1.9.3 (@eheydrick)

## [0.1.0] - 2016-03-05
### Added
- check-zookeeper-ruok

## [0.0.4] - 2015-12-10
### Added
- check-znode
- metrics-zookeeper

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.5.0...2.0.0
[1.5.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/0.1.0...1.0.0
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/0.0.4...0.1.0
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-zookeeper/compare/0.0.1...0.0.2
