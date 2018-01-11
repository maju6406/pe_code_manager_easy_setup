[![Build Status](https://travis-ci.org/maju6406/pe_code_manager_easy_setup.svg?branch=master)](https://travis-ci.org/maju6406/pe_code_manager_easy_setup)  

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with pe_code_manager_easy_setup](#setup)
    * [What pe_code_manager_easy_setup affects](#what-pe_code_manager_easy_setup-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_code_manager_easy_setup](#beginning-with-pe_code_manager_easy_setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description
This module and task makes it easy to install code manager.  
## Task
Using the task is highly recommended if you are running PE 2017.3 or are using Bolt. It is much simpler than using the module.
### Usage
First, install this module by running these command on the master as root:  
`puppet module install beersy-pe_code_manager_easy_setup`  
Set `r10k_remote_url` to git url of control repo (default: git@gitlab:puppet/control-repo.git). Both ssh and https url's are accepted. Ex:  
![screenshot](https://github.com/maju6406/pe_code_manager_easy_setup/raw/master/img/screenshot.png)  
If something goes wrong, check the /tmp/ez*.log's for more information. The task will fail if it is run on a node that is not a master.
After you run the task, check the output for the public ssh key and webhook url. You will need to manually put them in your version control system. **NOTE** The task can take a few minutes to run.
## Module Setup
### What pe_code_manager_easy_setup affects
This module will:
* create the appropriate RBAC users for code manager
* configure the PE Master node group for code manager
* generate the deployment key to be placed into github/gitlab
* generate the webhook URL to placed into github/gitlab

### Setup Requirements
This module assumes gem, git, and Puppet Enterprise are already installed.

### Usage
Install this module by running these command on the master as root:  
`puppet module install beersy-pe_code_manager_easy_setup`  
`puppet resource package puppetclassify ensure=present provider=puppet_gem`  
`puppet apply -e "class { 'pe_code_manager_easy_setup': r10k_remote_url => 'GIT_REPO_URL', git_management_system => 'GMS'}"`  
Run the above `puppet apply` command again.
Run `puppet agent -t`

Replace these values before running:
* **GIT_REPO_URL**: set to git url of control repo (default: git@gitlab:puppet/control-repo.git)
* **GMS**:  set to 'gitlab' or 'github' (default:'gitlab')


### Post-Install steps
If successful, this module generates 2 files on the master:  

1 `/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub`
Paste the contents of file as a deploy key:  
Gitlab:  
http://**PATH_TO_CONTROL_REPO**/deploy_keys (ex: http://gitlab/puppet/control-repo/deploy_keys)

Github:  
https://**PATH_TO_CONTROL_REPO**/settings/keys
(ex: https://github.com/puppetlabs/control-repo/settings/keys)  

2 `/etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt`  
Gitlab instructions:
* Go to: http://**PATH_TO_CONTROL_REPO**/hooks
  * URL: URL from webhook_url.txt
  * Trigger: Enable "Push events"
  * SSL verification: Enable "Enable SSL verification"

Github instructions:
* Go to: https://**PATH_TO_CONTROL_REPO**/settings/hooks/new
  * Payload URL: URL from webhook_url.txt
  * Content type: "application/json"
  * Which events would you like to trigger this webhook?:"Just the push event."

## Limitations
This modules assumes that you are running:
* Puppet Enterprise 2015.3 or higher
* Gitlab 8.5 or higher
* gem, git are already installed

## Release Notes/Contributors/Etc.
2.0.1 - Fixed bug related to access token, and improved execution time.  
2.0.0 - Added task  
1.0.1 - Changed to adhere to pdk standards. Added tests  
1.0.0 - Initial release  
0.1.4 - Removing unnecessary puppet_gem dependency  
0.1.3 - Typo fix  
0.1.2 - Readme fix  
0.1.1 - Code cleanup, added readme and other docs  
0.1.0 - Initial Release
