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

* Installs and configures an MCollective user for a local Unix user
* MCollective user and local unix user must be identically named (PE-11416)

### Setup Requirements

* You *MUST* have accurate timekeeping on all machines your interacting with

## Usage

### A new MCollective user on a machine managed by the same puppet master
```puppet
mcollective_user::client { "git":
    local_user_dir   => "/home/git",
    activemq_brokers => [ "localhost" ],
}
```
Install the MCollective client for a local Unix user `git` in their home directory at `/home/git`.  `activemq_brokers` is normally the hostname of the Puppet Master, or localhost if its on the same machine.  


### A new MCollective user on a machine managed by an EXTERNAL puppet master
```puppet
mcollective_user::external_client { "mco-2":
  stomp_port                      => 61613,
  log_file                        => "/var/log/mco-2.log",
  home_dir                        => "/home/mco-2",
  activemq_servers                => ["pe-puppet.localdomain"],

  machine_fqdn                    => "puppet1.localdomain",

  external_stomp_password         => hiera("external_stomp_password"),

  external_ca_cert_pem            => hiera('external_ca_cert_pem'),
  external_mco_server_name        => hiera("external_mco_server_name"),
  external_mco_server_public_key  => hiera("external_mco_server_public_key"),

  mcollective_user_private_key    => hiera('mcollective_user_private_key'),
  mcollective_user_public_key     => hiera('mcollective_user_public_key'),
  machine_cert                    => hiera('machine_cert'),
  machine_private_key             => hiera('machine_private_key'),

}
```
In this example, we install the an MCollective client for a local Unix user `mco-2` at `/home/mco-2`.  There are a bunch of hiera lookups - these represent data that needs to be retrieved from the *external* Puppet Master and placed in hiera.  Doing so will grant access to this external message bus.  Note that most of these hiera lookups are keys and certificates, eg complete files!  See theory section for details.

## External clients:  The theory
PE-11461 effectively prevents the certificate request process from working
correctly so we must manually generate all required certificates on the master
and copy them to the client.

To do this we must generate a certificate, public key and private key for:
* The machine name:  `puppet cert generate FQDN_OF_CLIENT_MACHINE`
_AND_
* The MCollective username `puppet cert generate MCOLLECTIVE_USERNAME`

### Example certificate creation (on the external puppet master)
```shell
puppet cert generate jenkins.megacorp.com
puppet cert generate r10k-deploy
```

Once the above steps have been performed, we need to copy a bunch of files from the external puppet master to the client machine and this is where this module comes in.

*We must also copy the MCOLLECTIVE_USERNAME public key to mcollective's public key area*

### Files we will need:
The contents of the following files should be loaded into hiera so they can be made available as variables
* The MCollective CA certificate from `/etc/puppetlabs/mcollective/ssl/ca.cert.pem`
* MCollective user private key from `/etc/puppetlabs/puppet/ssl/private_keys/USERNAME.pem`
* MCollective user public key from `/etc/puppetlabs/puppet/ssl/public_keys/USERNAME.pem`
* Machine certificate from `/etc/puppetlabs/puppet/ssl/certs/FQDN_OF_CLIENT_MACHINE.pem`
* Machine private key from `/etc/puppetlabs/puppet/ssl/private_keys/FQDN_OF_CLIENT_MACHINE.pem`
* MCollective public key from `/etc/puppetlabs/mcollective/ssl/mcollective-public.pem`

### Information we will need:
* Stomp password from `/etc/puppetlabs/mcollective/credentials`
* MCollective broker port (61613)
* hostname of external puppet master

*This is all really confusing which is why the `mcollective_user::external_client` resource installs the `mco_path.rb` file in /usr/local/bin on nodes its applied to.  This script will compute the files you need to cut'n'paste into hiera to make your life easier.  Don't forget to encrypt with hiera-eyaml!*

## Reference

* `mcollective_user::client` - setup an MCollective client talking to the Puppet Master managing this node
* `mcollective_user::external_client` - setup and MCollective client talking to a Puppet Master that is external, e.g., not managing this node
* `mcollective_user::install_pk` - Used internally to manage private keys (equivalent to _private_)
* `mcollective_user::register` - Register a new MCollective user

## Limitations

This module is not supported by Puppet Labs.  Use at own risk.  Only tested on RHEL7.  Requires Puppet Enterprise to work.  Only one external client per machine or you will get duplicate resource errors.  This is fixable but probably not a problem given that connecting to external puppet masters for MCollective is an edge case at best.

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
