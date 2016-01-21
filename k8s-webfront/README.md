# NGINX reverse proxy docker container for Rails

Installation and deployment script for NGinx frontend for Rails

## Prerequisites

For this to work you'll need:
- Docker daemon on local machine
- Google Container Engine with created cluster
- Configured gcloud and kubectl
- Reserved IP address for the LoadBalancer on GCE
- Key and cert already created
- Deployed rails application in the same cluster. Instructions for that are here.

## Let's start

### Edit:
- Dockerfile - Enter correct name of the key and crt
- config-and-run.sh - Replace MYAPP with the name of the rails application service previously created. Instructions for that are here.
- service.yaml - Enter already reserved IP address for the LoadBalancer
- deploy.sh - Edit K8S_PROJECT

## Deploy

Run

```
$ ./deploy.sh
```
