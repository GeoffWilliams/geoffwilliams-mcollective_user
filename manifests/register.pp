# Generate and sign a new mcollective user certificate, then copy it to
# MCollective's public key directory
#
# Params
# [*title*]
#   cert_name (unique id) or arbiratry string if both specified    
# [*cert_name*]
#   unique id of user to register
# [*generate_cert*]
#   generate a new certifcate (on the puppet master)?
define mcollective_user::register(
    $cert_name     = $title,
    $generate_cert = true,
    $install_pk    = true,
) { 

  if $generate_cert {
    # generata and accept a certificate for r10k user
    exec { "${cert_name}_mco_cert":
      command  => "puppet cert generate ${cert_name}",
      creates  => "${::settings::ssldir}/ca/signed/${cert_name}.pem",
      path     => [
        "/opt/puppetlabs/puppet/bin",
        "/opt/puppet/bin",
        "/usr/bin",
        "/bin",
      ],
    }
  }

  if $install_pk {
    # Once generated, copy the private key into MCollective's known public keys dir
    mcollective_user::install_pk { $cert_name: 
      local_system_user => "root",
    }
  }
}
