all:
	clear
	curl http://127.0.0.1:8000/ansible/site.yml > site.yml
	ansible-playbook site.yml --connection=local -i inventory --diff --check

.PHONY: all
