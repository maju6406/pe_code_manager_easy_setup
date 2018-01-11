#!/usr/bin/env bash
if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the master node."; 
  exit 1
fi
#puppet resource package puppetclassify ensure=present provider=puppet_gem &>/tmp/ez_puppet_resource.log
puppet_command="class { 'pe_code_manager_easy_setup': r10k_remote_url => '$PT_r10k_remote_url', git_management_system => 'github'}"
echo $puppet_command >/tmp/cm.pp 
puppet apply /tmp/cm.pp &>/tmp/ez_puppet_apply1.log
puppet apply /tmp/cm.pp &>/tmp/ez_puppet_apply2.log
echo "Successfully applied changes to Puppet Master."
puppet agent -t &>/tmp/ez_puppet_agent_run1.log
echo "Successfully ran puppet on Puppet Master..."
echo "Finished!"
echo ""
echo "Now, put this generated Public SSH Key in your version control system:"
echo $(head -n 1 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)
echo ""
echo "Also, put the appropriate webhook URL's in your version control system:"
webhook_url=$(head -n 1 /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt)
echo "github:" ${webhook_url}
echo "gitlab:" ${webhook_url/github/gitlab}
echo "stash:" ${webhook_url/github/stash}
echo "bitbucket:" ${webhook_url/github/bitbucket}
echo "tfs-git:" ${webhook_url/github/tfs-git}
echo "More information about webhook url's and all their parameters can be found here:"
echo "https://puppet.com/docs/pe/2017.3/code_management/code_mgr_webhook.html#triggering-code-manager-with-a-webhook"