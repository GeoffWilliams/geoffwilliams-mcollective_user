require 'spec_helper'
describe 'mcollective_user' do

  context 'with defaults for all parameters' do
    it { should contain_class('mcollective_user') }
  end
end
