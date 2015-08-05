# Install a public key from Puppet's CA into MCollectives known public keys dir
#
# Params
# [*title*] 
#   cert_name or arbitrary string if both specified
# [*cert_name*]
#   The client name to use (AKA mcollective user).  Defaults to title
define mcollective_user::install_pk($cert_name = $title) {
  include puppet_enterprise::params
  $mco_clients_cert_dir = $puppet_enterprise::params::mco_clients_cert_dir
  file { "${mco_clients_cert_dir}/${cert_name}-public.pem":
    content => file("${::settings::ssldir}/public_keys/${cert_name}.pem",
                    "${mco_clients_cert_dir}/${cert_name}-public.pem",
                    '/dev/null'),
  }
}
