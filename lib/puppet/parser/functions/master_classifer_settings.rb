# Master Classifier Helper Function
module Puppet::Parser::Functions
  newfunction(:master_classifer_settings, type: :rvalue) do |args|
# Ignore next line. args isn't used but is there for backwards compatibility
    args = ""
    function_parseyaml([function_file([File.join(lookupvar('settings::confdir').to_s, 'classifier.yaml')])])
  end
end
