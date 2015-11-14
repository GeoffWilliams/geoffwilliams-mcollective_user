include puppet_enterprise::params
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
