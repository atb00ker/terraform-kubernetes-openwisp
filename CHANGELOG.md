# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0-alpha.2] - 2020-02-12
### Added
- module input: infrastructure_provider.nodes_cidr_range

### Changed
- module input: infrastructure_provider.cluster_ip_range -> infrastructure_provider.services_cidr_range
- module input: infrastructure_provider.pod_ip_range -> infrastructure_provider.pods_cidr_range
- updated terraform = "~> 0.12.18"
- version lock issue for null   = "~> 2.1.0"

### Fixed
- bug due to version lock issue for kubernetes = "~> 1.10.0"

## [0.1.0-alpha.1] - 2020-02-01
- Basic deployment of docker-openwisp on kubernetes cluster
