# Laravel with LAMP Ansible Deployment

This repository contains an Ansible playbook for automating the deployment of a Laravel application on a LAMP (Linux, Apache, MySQL, PHP) stack. It also includes a cron job to log server uptime.

## Prerequisites

Before running the Ansible playbook, ensure that you have:

Two Ubuntu-based servers provisioned using Vagrant: one designated as the Master node and the other as the Slave node.
Ansible installed on the machine you will run the playbook from.


## Usage

1. Clone this repository to your local machine:

git clone https://github.com/AaRonStaRK019/laravel-with-LAMP-ansible.git

2. Navigate to the repository directory:

cd laravel-with-LAMP-ansible

3. Modify the host file - 'nodes' to include the IP address(es) or hostname of your Slave node.

4. Update the `deploy_laravel.sh` script with any changes you wish to make, if necessary.

5. Run the Ansible playbook:

ansible-playbook -i nodes execute_script.yml

6. Once the playbook execution completes successfully, your Laravel application should be deployed on the Slave node. You can access it via the Slave node's IP address.

## Additional Notes

You may need to customize the playbook and scripts according to your specific environment and requirements.

Feel free to contribute to this repository by submitting pull requests or reporting issues.

Find step by step process in [steps](./steps.md)