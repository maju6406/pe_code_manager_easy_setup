#!/usr/bin/env bash
if facter -p puppet_server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi

echo r10k_remote_url : $PT_r10k_remote_url
echo git_management_system : $PT_git_management_system

#puppet resource package puppetclassify ensure=present provider=puppet_gem
puppet_command="class { 'pe_code_manager_easy_setup': r10k_remote_url => '$PT_r10k_remote_url', git_management_system => '$PT_git_management_system'}"
printf '%s\n' "$puppet_command"
# puppet apply -e $puppet_command
# puppet agent -t
# puppet agent -t
echo "Done!"