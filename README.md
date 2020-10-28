# choco-server-2019-core-ecs-optimized-ami-compatible
Simple Chocolatey Server, SSL-ready, compatible with ECS Optimized 2019 Core 10.0.17763 AMI

Simple Chocolatey Server intended for ECS deployment. Generates and installs a self-signed certificate for localhost which must be imported into the computer cert store to enable package push. OS version is compatible with the latest ECS-Optimized 2019 Server Core AMI provided by AWS as of 10/28/2020 - 10.0.17763. Self-Signed cert does not interfere with SSL termination for an AWS ACM cert attached on an ALB and image can be used as-is for both AWS or local development.

API key can be supplied via CHOCOLATEY_API custom environment variable. This is to support integration with Secrets Manager or Parameter Store. If null, API key is 'default'.
