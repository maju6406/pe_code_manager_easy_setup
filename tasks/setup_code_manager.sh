#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
echo git_management_system : $PT_git_management_system

puppet resource package puppetclassify ensure=present provider=puppet_gem &>/tmp/ez_puppet_resource.log
echo "Applying Changes to Puppet Master..."
puppet_command="class { 'pe_code_manager_easy_setup': r10k_remote_url => 'github', git_management_system => '$PT_git_management_system'}"
echo $puppet_command >/tmp/cm.pp 
puppet apply /tmp/cm.pp &>/tmp/ez_puppet_apply.log
#echo "Apply Exit code:$?" 
echo "Running Puppet on Puppet Master..."
puppet agent -t &>/tmp/ez_puppet_agent_run1.log
#echo "Run1 Exit code:$?"
puppet agent -t &>/tmp/ez_puppet_agent_run2.log
#echo "Run2 Exit code:$?"
echo "Done!"
echo "Put this generated Public SSH Key in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)
echo "Example webhook URL's in your version control system:"
webhook_url=$(head -n 1 /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt)
echo "github:" ${webhook_url}
echo "gitlab:" ${webhook_url/github/gitlab}
echo "stash:" ${webhook_url/github/stash}
echo "bitbucket:" ${webhook_url/github/bitbucket}
echo "tfs-git:" ${webhook_url/github/tfs-git}
