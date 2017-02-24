require 'spec_helper'
describe 'pe_code_manager_easy_setup' do
  context 'with default values for all parameters' do
    it { should contain_class('pe_code_manager_easy_setup') }
  end
end
