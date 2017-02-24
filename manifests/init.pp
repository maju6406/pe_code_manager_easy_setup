# Class: pe_code_manager_easy_setup
# ===========================
#
# This module will:
# * create the appropriate RBAC users for code manager
# * configure the PE Master node group for code manager
# * generate the deployment key to be placed into github/gitlab
# * generate the webhook URL to placed into github/gitlab
#
# Parameters
# ----------
#
#  r10k_remote_url: git url to your control repo, ex'git@gitlab:puppet/control-repo.git',
#  git_management_system: 'gitlab' (Default) or 'github'
#
# Examples
# --------
#
# @example
#    class { 'pe_code_manager_easy_setup':
#      r10k_remote_url => 'git@gitlab:puppet/control-repo.git',
#    }
#
# Output
# --------
# If successful, this module generates 2 files on the master:
# /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt - contains the webhook url to be put in gitlab/github
# /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub - contents of file should be added as a deploy key in gitlab/github
#
# Authors
# -------
#
# Author Name Abir Majumdar <abir@puppet.com>
#
# Copyright
# ---------
#
# Copyright 2017 Abir Majumdar, unless otherwise noted.
#
class pe_code_manager_easy_setup (
  $r10k_remote_url = 'git@gitlab:puppet/control-repo.git',
  $git_management_system = 'gitlab',
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
      git_management_system => $git_management_system,
      create_and_manage_git_deploy_key => false,
      manage_git_webhook               => false,
      require => Node_group['PE Master'],
    }

    chown_r { '/etc/puppetlabs/code/'':
      want_user  => 'pe-puppet',
      want_group => 'pe-puppet',
      require    => Class['pe_code_manager_webhook::code_manager'],
    }
}
