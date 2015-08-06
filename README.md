# mcollective_user

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mcollective_user](#setup)
    * [What mcollective_user affects](#what-mcollective_user-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mcollective_user](#beginning-with-mcollective_user)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Allows creation of additional MCollective users EASILY.
## Module Description

Provides support for:
* Registering new MCollective users on machines managed by the puppet master
  running MCollective
* Installing an MCollective client to an external MCollective server (puppet master)
## Setup

### What mcollective_user affects

* Installs and configures an mcollective user for a local unix user
* MCollective user and local unix user must be identically named (PE-11416)

### Setup Requirements **OPTIONAL**

* You *MUST* have accurate timekeeping on all machines your interacting with

## Usage

### A new MCollective user on a machine managed by the same puppet master

### A new MCollective user on a machine managed by an EXTERNAL puppet master

#### The theory
PE-11461 effectively prevents the certificate request process from working
correctly so we must manually generate all required certificates on the master
and copy them to the client.

To do this we must generate a certificate, public key and private key for:
* The machine name:  `puppet cert generate FQDN_OF_CLIENT_MACHINE`
_AND_
* The MCollective username `puppet cert generate MCOLLECTIVE_USERNAME`

##### Example certificate creation (on the external puppet master)
```shell
puppet cert generate jenkins.megacorp.com
puppet cert generate r10k-deploy
```

Once the above steps have been performed, we need to copy a bunch of files from the external puppet master to the client machine and this is where this module comes in.

*We must also copy the MCOLLECTIVE_USERNAME public key to mcollective's public key area*

##### Files we will need:
The contents of the following files should be loaded into hiera so they can be made available as variables
* The MCollective CA certificate from `/etc/puppetlabs/mcollective/ssl/ca.cert.pem`
* MCollective user private key from `/etc/puppetlabs/puppet/ssl/private_keys/USERNAME.pem`
* MCollective user public key from `/etc/puppetlabs/puppet/ssl/public_keys/USERNAME.pem`
* Machine certificate from `/etc/puppetlabs/puppet/ssl/certs/FQDN_OF_CLIENT_MACHINE.pem`
* Machine private key from `/etc/puppetlabs/puppet/ssl/private_keys/FQDN_OF_CLIENT_MACHINE.pem`
* MCollective public key from `/etc/puppetlabs/mcollective/ssl/mcollective-public.pem`

##### Information we will need:
* Stomp password from `/etc/puppetlabs/mcollective/credentials`
* MCollective broker port (61613)
* hostname of external puppet master



#### On the client


## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This module is not supported by Puppet Labs.  Use at own risk.  Only tested on RHEL7.  Requires Puppet Enterprise to work.

## Troubleshooting
Things to check if doesn't work:
* checksums match on the all of the above listed files on both the master and agent
* Ports are open (check that you can open a socket)
* Clocks are accurate

## Important note
* You must NEVER store the *private* keys in hiera in plain-text as they grant access to your MCollective system
* Encrypt them using [hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml)!


## Development

PRs welcome
