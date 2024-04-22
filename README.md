# laravel-with-LAMP-ansible



1. ` write up the bash script and ansible playbook to deploy the Laravel application and log Uptime`

Bash script - [bash script](./deploy_laravel.sh) 

Ansible playbook - [ansible playbook](./execute_script.yml) 

2. `install ansible on master node`

[install ansible](./img/02_ansible-on-master.png)

3. `verify ansible installation`

[verify ansible installation](./img/03_verify-ansible-inst.png)

4. `add the IP address of the slave VM to an inventory file`

[inventory file](./img/04_add_slave_to_inventory_file.png)

5. `run an ansible ping test to confirm connection to slave node`

[ansible ping test](./img/05_ansible-ping-test.png)

6. `run the ansible playbook`

[run playbook](./img/06_run%20ansible%20playbook.png)

7. `playbook adds crontab to log uptime`

[cronjob](./img/07_adding-crontab.png)

8. `playbook gets server response (200) from the Laravel application to show it works`

[server response](./img/08_getting-server-response.png)

9. `ensure there are no errors from running the playbook`

[no errors](./img/09_no-error-on-playbook.png)

10. `input the IP address into a browser window to view the Laravel application`

[laravel app](./img/10_laravel-app-working.png)

11. `confirm if cronjob was added to crontab` 

[cronjob added](./img/11_cronjob-added.png)
