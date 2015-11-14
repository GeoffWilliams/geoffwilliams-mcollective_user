require 'spec_helper'
describe 'mcollective_user::register', :type => :define do

  context 'should compile' do
    let :title do
      "git"
    end
    it { should compile }
  end
end
