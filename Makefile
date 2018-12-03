
.PHONY: install
install:
	# TODO use vault '--ask-vault-pass'
	ansible-playbook -i '127.0.0.1,' --ask-become-pass linux.yaml
