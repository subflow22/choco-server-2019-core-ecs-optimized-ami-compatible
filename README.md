# Simple Chocolatey Server, SSL-ready, compatible with ECS Optimized 2019 Core 10.0.17763 AMI

Simple Chocolatey Server intended for ECS deployment or can be used locally as well.  Generates and installs a self-signed certificate for localhost which must be imported into the computer cert store to enable package push for local development.  OS version is compatible with the latest ECS-Optimized 2019 Server Core AMI provided by AWS as of 10/28/2020 - 10.0.17763.  Self-Signed cert does not interfere with SSL termination for an AWS ACM cert attached to an ALB.

API key can be supplied via CHOCOLATEY_API custom environment variable.  This is to support integration with Secrets Manager or Parameter Store.  If null, API key is 'default'.  This is defined as apiKey in C:\tools\chocolatey.server\web.config.  The helper script is embedded in the Dockerfile.

For localhost development: \
1.) docker pull subflow22/choco-server-2019-core-ecs-optimized-ami-compatible:latest \
2.) docker run -dp 0.0.0.0:8443:8443 subflow22/choco-server-2019-core-ecs-optimized-ami-compatible:latest \
3.) https://localhost:8443 \
4.) Download the certificate from your browser and save it to a file. \
5.) Double click the certificate file to import the certificate into the local machine trusted root certificate store.

Chocolatey package push is now enabled for the local container: \
https://chocolatey.org/docs/commands-push 

For Docker Desktop users, don't forget to enable Windows containers! \
Search 'Experimental Features' below: \
https://docs.docker.com/docker-for-windows/
