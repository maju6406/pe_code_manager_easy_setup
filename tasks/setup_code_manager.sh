#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi

echo r10k_remote_url : $PT_r10k_remote_url
echo git_management_system : $PT_git_management_system

puppet resource package puppetclassify ensure=present provider=puppet_gem
echo "Applying Changes to Puppet Master..."
puppet_command="class { 'pe_code_manager_easy_setup': r10k_remote_url => '$PT_r10k_remote_url', git_management_system => '$PT_git_management_system'}" >/tmp/cm.pp
#echo "class { 'pe_code_manager_easy_setup': r10k_remote_url => 'https://github.com/maju6406/control-repo.git', git_management_system => 'github'}" 
echo $puppet_command
puppet apply --test /tmp/cm.pp 2>&1
echo "Apply Exit code:$?" 
echo "Running Puppet on Puppet Master..."
puppet agent -t 2>&1
echo "Run1 Exit code:$?"
puppet agent -t 2>&1
echo "Run2 Exit code:$?"
echo "Done!"
echo "Put this generated Public SSH Key in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)
echo "Put this webhook URL in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt)