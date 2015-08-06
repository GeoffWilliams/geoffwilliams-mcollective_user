# Install an mcollective client pointing to an external collective (eg a 
# completly separate puppet master).
#
# The mco command is provided in the puppet-agent package so does NOT need
# to be installed.  All we need to do is:
# * mcollective config file
# * external CA
# * other small details


define mcollective_user::external_client(
    $activemq_brokers,
    $logfile,
    $cert_name              = $title,
    $client_name            = $title,
    $keypair_name           = $title,
    $create_user            = $puppet_enterprise::params::mco_create_client_user,
    $home_dir               = "/var/lib/${title}",
    $main_collective        = 'mcollective',

    $external_stomp_password,
    $stomp_port             = $puppet_enterprise::mcollective_middleware_port,
    $stomp_user             = $puppet_enterprise::params::stomp_user,
    $collectives            = ['mcollective'],
    $manage_symlinks        = true,

    $machine_fqdn = $::fqdn,

    $external_ca_cert_pem,
    $external_mco_server_name,
    $external_mco_server_public_key,

    $mcollective_user_private_key,
    $mcollective_user_public_key,
    $machine_cert,
    $machine_private_key,
    

) {
  include puppet_enterprise::params
  $cert_dir = "${home_dir}/.mcollective.d"
  $mco_plugin_libdir = $puppet_enterprise::params::mco_plugin_libdir
  $ssl_dir = $puppet_enterprise::params::ssl_dir

  # the template calls the variable `stomp_password`.  Have prefixed our local
  # copy with `external_` to drive home the message that it needs to be looked
  # up on the other master
  $stomp_password = $external_stomp_password

  # copy the server name to what the template expects
  $mco_server_name = $external_mco_server_name
  
  File {
    owner => $client_name,
    group => $client_name,
    mode  => '0600'
  }

  if $manage_symlinks {
    File <| tag == 'pe-mco-symlinks' |>
  }

  if $create_user {
    puppet_enterprise::mcollective::client::user { $client_name:
      home_dir => $home_dir,
    }
  }

  file { $logfile:
    ensure => file
  }

  # Template uses:
  # - $activemq_brokers
  # - $cert_dir
  # - $cert_name
  # - $logfile
  # - $main_collective
  # - $stomp_password
  # - $stomp_port
  # - $stomp_user
  # - $collectives
  # - $mco_server_name
  # - $mco_plugin_libdir
  file { "${home_dir}/.mcollective":
    content => template('puppet_enterprise/mcollective/client.cfg.erb'),
  } 

  # Previous versions of PE used to lay down client.cfg in /etc/puppetlabs/mcollective/client.cfg
  # Remove it since its now placed in the clients homedir. Since this is a defined type, it could be used
  # multiple times on one node (for example an all in one master will have the profile console and peadmin).
  # to prevent duplicate declarations, check if this hasn't already been defined.
  if ! defined(File['/etc/puppetlabs/mcollective/client.cfg']) {
    file { '/etc/puppetlabs/mcollective/client.cfg':
      ensure => absent,
    }
  }
  include puppet_enterprise::mcollective::service

  
  # client cert stuff...
  file { $cert_dir:
    ensure => directory,
    mode    => '0700',
  }

  # CA cert
  file { "${cert_dir}/ca.cert.pem":
    content => $external_ca_cert_pem,
  }

  # external mco public key
  file { "${cert_dir}/${mco_server_name}-public.pem":
    content => $external_mco_server_public_key,
  }

  # MCO user private key
  file { "${cert_dir}/${client_name}-private.pem":
    content => $mcollective_user_private_key,
  }

  # MCO user public key
  file { "${cert_dir}/${client_name}-public.pem":
    content => $mcollective_user_public_key,
  }

  # machine cert (based on FQDN - not the same as $::clientcert as we not 
  # necessarily using THAT name as we have an external puppet master..:
  file { "${cert_dir}/${machine_fqdn}.cert.pem":
    content => $machine_cert,
  }

  # Machine private key - see note above
  file { "${cert_dir}/${machine_fqdn}.private_key.pem":
    content => $machine_private_key,
  }


  # ==== below needed??????

  # MCO public key to mcollective public keys area
  mcollective_user::install_pk { $external_mco_server_name:
    content           => $external_mco_server_public_key,
    local_system_user => $client_name,
  }

  # Agent public key to mcollective public keys area
  mcollective_user::install_pk { $cert_name: 
    content => $external_client_public_key_pem,
  }

}
