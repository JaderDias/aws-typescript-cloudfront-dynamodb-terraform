aws_region=eu-west-2
test:
	cd typescript/lambda-at-edge/viewer-request && \
	npm install && \
	npm test
transpile:
	cd typescript/lambda-at-edge/viewer-request && \
	npm install && \
	npx tsc
deploy-tf:
	cd terraform && \
	terraform init && \
	terraform fmt && \
	terraform apply --auto-approve \
    	--var "aws_region=$(aws_region)"
deploy:transpile deploy-tf
destroy:
	cd terraform && \
	terraform apply -destroy \
	--var "aws_region=$(aws_region)"
