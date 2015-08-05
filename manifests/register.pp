# Generate and sign a new mcollective user certificate, then copy it to
# MCollective's public key directory
define mcollective_user::register(
    $cert_name = $title
) { 


  # generata and accept a certificate for r10k user
  exec { "r10k_mco_cert":
    command  => "puppet certificate generate ${cert_name} --ca-location local && puppet cert sign ${cert_name}",
    creates  => "${::settings::ssldir}/ca/signed/${cert_name}.pem",
    path     => [
      "/opt/puppetlabs/puppet/bin",
      "/opt/puppet/bin",
      "/usr/bin",
      "/bin",
    ],
  }

  # Once generated, copy the private key into MCollective's known public keys dir
  mcollective_user::install_pk { $cert_name: }
}
