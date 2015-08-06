# Install a public key from Puppet's CA into MCollectives known public keys dir
#
# Params
# [*title*] 
#   cert_name or arbitrary string if both specified
# [*cert_name*]
#   The client name to use (AKA mcollective user).  Defaults to title
# [*content*]
#   Use this content for public key instead of reading off server
# [*local_system_user*]
#   Override the default username `$cert_name` and set the file owner to this
#   user instead
define mcollective_user::install_pk(
    $cert_name         = $title,
    $content           = false,
    $local_system_user = false,
) {
  include puppet_enterprise::params
  $mco_clients_cert_dir = $puppet_enterprise::params::mco_clients_cert_dir

  # PE-11416 -- names must be the same
  $client_name = $cert_name

  if $local_system_user {
    $file_owner = $local_system_user
  } else {
    $file_owner = $client_name
  }

  File {
    owner => $file_owner,
    group => $file_owner,
    mode  => "0600",
  }
 
  if $content {
    $_content = $content
  } else {
    $_content = file(
      "${::settings::ssldir}/public_keys/${cert_name}.pem",
      "${mco_clients_cert_dir}/${cert_name}-public.pem",
      '/dev/null'
    )
  }

  file { "${mco_clients_cert_dir}/${cert_name}-public.pem":
    content => $_content,
  }
}
