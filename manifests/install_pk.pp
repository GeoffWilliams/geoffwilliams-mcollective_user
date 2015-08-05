# Install a public key from Puppet's CA into MCollectives known public keys dir
#
# Params
#   [*title*] The certname to use (AKA mcollective user)
class mcollective_user::install_pk() {
  $certname = $title
  include puppet_enterprise::params
  $mco_clients_cert_dir = $puppet_enterprise::params::mco_clients_cert_dir
  file { "${mco_clients_cert_dir}/${certname}-public.pem":
    content => file("${::settings::ssldir}/public_keys/${certname}.pem",
                    "${mco_clients_cert_dir}/${certname}-public.pem",
                    '/dev/null'),
  }
}
