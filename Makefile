build:
	docker build --force-rm -t safenetlabs/ansible:latest .

push:
	docker push safenetlabs/ansible:latest