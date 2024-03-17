##
# Ansible Makefile targets for Homelab
#
# @file
# @version 0.1

bootstrap-proxmox:
	ansible-playbook bootstrap_proxmox.yml -i inventory.ini -k

cloud-init:
	ansible-playbook cloud_init.yml -i inventory.ini -k

k3s-nodes:
	ansible-playbook k3s_nodes.yml -i inventory.ini --private-key ~/.ssh/ansible_homelab

# end
