# Class: pe_code_manager_easy_setup
# ===========================
#
# Full description of class pe_code_manager_easy_setup here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'pe_code_manager_easy_setup':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class pe_code_manager_easy_setup (
  $r10k_remote_url = 'git@gitlab:puppet/control-repo.git',
){

    package { 'puppetclassify':
      ensure   => present,
      provider => puppet_gem,
    }

    Node_group {
      require => Package['puppetclassify'],
    }

    node_group { 'PE Master':
      ensure               => present,
      environment          => 'production',
      override_environment => false,
      parent               => 'PE Infrastructure',
      classes              => {
        'puppet_enterprise::profile::master' =>{
          'code_manager_auto_configure' => true,
          'r10k_remote'                 => $r10k_remote_url,
          'r10k_private_key'            => '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa' },
      },
    }

    class { 'pe_code_manager_webhook::code_manager':
      require => Node_group['PE Master'],
    }

    chown_r { "/etc/puppetlabs/code/":
      want_user  => 'pe-puppet',
      want_group => 'pe-puppet',
      require    => Class['pe_code_manager_webhook::code_manager'],
    }
}
