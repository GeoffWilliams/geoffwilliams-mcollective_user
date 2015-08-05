# Install the MCollective client software, copy the certs from the server and 
# register the public key with the local MCollective server

# Params
# [*title*]
#   cert_name to use or arbitrary string if both specified
# [*cert_name*]
#   cert_name (AKA MCollective username) to use.  Defaults to $title
# [*local_user_name*]
#   local system user to configure for mcollective.  Defaults to $title
# [*local_user_dir*]
#   home directory for local user.  Defaults to /home/$title
# [*activemq_brokers*]
#   ActiveMQ broker to use, must be an array.  Usually the address of the 
#   puppet master
# [*logfile*]
#   MCollective logfile to use for this user.  Defaults to:
#   /var/log/mcollective_${title}/mcollective.log
# [*create_user*]
#   Ask the puppet-enterprise module to create the local system user for us. If
#   false you must manage this yourself
define mcollective_user::client(
    $cert_name = $title,
    $local_user_name = $title,
    $local_user_dir = "/home/${title}",
    $activemq_brokers,
    $logfile = false,
    $create_user = false,
) {

  include puppet_enterprise::params
  # If user supplies custom logdir use it and have user be responsible for
  # creating directory structure, etc.  Otherwise just create a directory
  # under /var/log and allow access
  if $logfile {
    $_logfile = $logfile
  } else {
    $logdir = "/var/log/mcollective_${cert_name}"
    $_logfile = "${logdir}/mcollective.log"
    file { $logdir:
      ensure => directory,
      owner  => $local_user_name,
      group  => $local_user_name,
      mode   => "0755",
    }
  }

  # MCO certifcates and client
  puppet_enterprise::mcollective::client { $local_user_name:
    activemq_brokers => $activemq_brokers,
    create_user      => $create_user,
    home_dir         => $local_user_dir,
    logfile          => $_logfile,
    cert_name        => $local_user_name,
    client_name      => $client_name,
  }

  # Copy the public key to local MCollective server's public keys area
  mcollective_user::install_pk { $cert_name: }

}
