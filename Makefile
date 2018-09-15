docker:
	docker build -t myapp --target=production .

pdb-docker:
	docker build -t myapp --target=debug .
