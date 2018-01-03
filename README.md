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
This module makes it easy to install code manager.
## Setup
### What pe_code_manager_easy_setup affects
This module will:
* create the appropriate RBAC users for code manager
* configure the PE Master node group for code manager
* generate the deployment key for github/gitlab
* generate the webhook URL for github/gitlab
* add webhook url and deployment key directly into gitlab/github via their API's

### Setup Requirements
This module assumes gem, git, and Puppet Enterprise are already installed.

### Usage
Install this module by running these command first on the master as root:  
`puppet module install beersy-pe_code_manager_easy_setup`  

Then add these values to your hiera file (ex, /etc/puppetlabs/code/environments/production/hieradata/common.yaml)

* pe_code_manager_easy_setup::r10k_remote_url:GIT_REPO_URL
* pe_code_manager_easy_setup::git_management_system:GMS
* pe_code_manager_easy_setup::gms_api_token:GMS_API_TOKEN
* pe_code_manager_easy_setup::control_repo_project_name:CONTROL_REPO_NAME
* pe_code_manager_easy_setup::gms_server_url:GIT_SERVER_URL  
then run this command **twice**  
`puppet apply -e "include ::pe_code_manager_easy_setup"`

If you are not using hiera you can specify the parameters at the command line:   
`puppet apply -e "class { 'pe_code_manager_easy_setup': r10k_remote_url => 'GIT_REPO_URL', git_management_system => 'GMS', gms_api_token=>'GMS_API_TOKEN',control_repo_project_name => 'CONTROL_REPO_NAME', gms_server_url=>'GIT_SERVER_URL'}"`  
Run the above command **twice**  

Finally, run 
`puppet agent -t`

Replace the values before running:
* **GIT_REPO_URL**: set to git url of control repo (default: git@gitlab:puppet/control-repo.git)
* **GMS**:  set to 'gitlab' or 'github' (default:'gitlab')
* **GMS_API_TOKEN**: Your github/gitlab personal access token (https://github.com/settings/tokens or http://davisgitlab/profile/personal_access_tokens)
* **CONTROL_REPO_NAME**: Typically <owner>/<control_repo>, ex puppet/control-repo
* **GIT_SERVER_URL**: HTTP URL to your git repo, ex 'http://gitlab' (Ignore this param if you're using github.com)

### Manual Post-Install steps (optional)
`gms_api_token`, `control_repo_project_name`, and `gms_server_url` are optional parameters. You can manually add the webhook URL and ssh key to gitlab/github using the following instructions:

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
1.1.0 - Added new options to directly update gitlab/github by specifying a API token, server url, and repo name  
1.0.0 - Initial release
0.1.4 - Removing unnecessary puppet_gem dependency  
0.1.3 - Typo fix  
0.1.2 - Readme fix  
0.1.1 - Code cleanup, added readme and other docs  
0.1.0 - Initial Release
