#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi

echo r10k_remote_url : $PT_r10k_remote_url
echo git_management_system : $PT_git_management_system

puppet resource package puppetclassify ensure=present provider=puppet_gem
echo "Applying Changes to Puppet Master..."
puppet_command="class { 'pe_code_manager_easy_setup': r10k_remote_url => '$PT_r10k_remote_url', git_management_system => '$PT_git_management_system'}"
echo "class { 'pe_code_manager_easy_setup': r10k_remote_url => 'https://github.com/maju6406/control-repo.git', git_management_system => 'gitlab'}"
echo $puppet_command
puppet apply --test -e "$puppet_command" 2>&1
echo "Running Puppet on Puppet Master..."
puppet agent -t 2>&1
puppet agent -t 2>&1
echo "Done!"
echo "Put this generated Public SSH Key in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)
echo "Put this webhook URL in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt)