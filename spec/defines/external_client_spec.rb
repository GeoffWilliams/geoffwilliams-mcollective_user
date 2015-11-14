require 'spec_helper'
describe 'mcollective_user::external_client', :type => :define do

  context 'should compile' do
    let :title do
      "mco-2"
    end
    let :params do
      {
        :stomp_port                     => 61613,
        :log_file                       => "/var/log/mco-2.log",
        :home_dir                       => "/home/mco-2",
        :activemq_servers               => ["pe-puppet.localdomain"],

        :machine_fqdn                   => "puppet1.localdomain",

        # strings prefixed heira_ are normally looked up directly...
        :external_stomp_password        => "hiera_external_stomp_password",

        :external_ca_cert_pem           => "hiera_external_ca_cert_pem",
        :external_mco_server_name       => "hiera_external_mco_server_name",
        :external_mco_server_public_key => "hiera_external_mco_server_public_key",

        :mcollective_user_private_key   => "hiera_mcollective_user_private_key",
        :mcollective_user_public_key    => "hiera_mcollective_user_public_key", 
        :machine_cert                   => "hiera_machine_cert",
        :machine_private_key            => "hiera_machine_private_key",

      }
    end
    it { should compile }
  end
end
