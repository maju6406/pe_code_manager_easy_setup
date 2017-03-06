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
#  gms_server_url: HTTP URL to your git repo, ex 'http://gitlab' (Ignore this param if you're using github.com)
#  gms_api_token: Your github/gitlab personal access token (https://github.com/settings/tokens or http://davisgitlab/profile/personal_access_tokens)
#  control_repo_project_name: Typically <owner>/<control_repo>, ex puppet/control-repo
#
# Examples
# --------
#
# @example
#    class { 'pe_code_manager_easy_setup':
#      r10k_remote_url => 'git@davisgitlab:puppet/control-repo.git',
#      git_management_system => 'gitlab',
#      gms_server_url=>'http://davisgitlab',
#      control_repo_project_name => 'puppet/control-repo',
#      gms_api_token => 'HkXboXkyKXQsWH9ZLAy9'
#    }
#
#
# @example
#    class { 'pe_code_manager_easy_setup':
#      r10k_remote_url => 'git@github.com:maju6406/thisisasamplerepotest.git',
#      git_management_system => 'github',
#      control_repo_project_name => 'maju6406/thisisasamplerepotest',
#      gms_api_token => 'H3XboXkyKXQsWH9ZLAy8'
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
  String $r10k_remote_url = 'git@gitlab:puppet/control-repo.git',
  String $git_management_system = 'gitlab',
  Optional[String]  $gms_server_url = 'http://gitlab',
  String $gms_api_token = 'H3XboXkyKXQsWH9ZLAy8',
  String $control_repo_project_name = 'puppet/control-repo'
){

    package { 'puppetclassify':
      ensure   => present,
      provider => puppet_gem,
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
      require              => Package['puppetclassify'],
    }

    class { 'pe_code_manager_easy_setup::code_manager':
      git_management_system            => $git_management_system,
      create_and_manage_git_deploy_key => true,
      manage_git_webhook               => true,
      gms_server_url                   => $git_management_system ? {
                                            'gitlab' => $gms_server_url,
                                            'github' => undef,
                                            default  => undef,
                                          },
      gms_api_token                    => $gms_api_token,
      control_repo_project_name        => $control_repo_project_name,
      require                          => Node_group['PE Master'],
    }

    chown_r { '/etc/puppetlabs/code/':
      want_user  => 'pe-puppet',
      want_group => 'pe-puppet',
      require    => Class['pe_code_manager_easy_setup::code_manager'],
    }
}
