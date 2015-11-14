require 'spec_helper'
describe 'mcollective_user::client', :type => :define do

  context 'should compile' do
    let :title do
      "git"
    end
    let :params do
      {
        :local_user_dir   => "/home/git",
        :activemq_brokers => [ "localhost" ],
      }
    end
    it { should compile }
  end
end
