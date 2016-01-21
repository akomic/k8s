#!/bin/bash

KUBECTL="kubectl"
K8S_PROJECT="<GCE_PROJECT>"
PROJECT_NAME="webfront"

if [ -z $1 ];then
        echo "Usage: $0 <tag>"
        exit 1
fi

TAG_NAME=$1

function myprint {
        RED='\033[0;31m'
        NC='\033[0m'
        printf "${RED}${1}${NC}\n"
}

LATEST_CREATED_IMAGE=$(docker images gcr.io/${K8S_PROJECT}/k8s-${PROJECT_NAME} |head -2|tail -1|awk '{print $2}')
if [ "${LATEST_CREATED_IMAGE}" == "${TAG_NAME}" ];then
        myprint "===> Using already compiled image gcr.io/${K8S_PROJECT}/k8s-${PROJECT_NAME}:${TAG_NAME} ..."
else
        myprint "===> Building image gcr.io/${K8S_PROJECT}/k8s-${PROJECT_NAME}:${TAG_NAME} ..."
        docker build --force-rm=true --no-cache=true -t gcr.io/${K8S_PROJECT}/k8s-${PROJECT_NAME}:${TAG_NAME} . || exit 1
fi

myprint "===> Pushing image to repository ..."
gcloud docker push gcr.io/$K8S_PROJECT/k8s-${PROJECT_NAME}:${TAG_NAME} || exit 1

sed -i '' "s/k8s-${PROJECT_NAME}\:.*$/k8s-${PROJECT_NAME}:${TAG_NAME}/g" "controller.yaml"

myprint "===> Deploying ..."
${KUBECTL} describe rc "${PROJECT_NAME}"

if [ $? -ne 0 ];then
	${KUBECTL} create -f controller.yaml
else
	${KUBECTL} rolling-update ${PROJECT_NAME} --image=gcr.io/${K8S_PROJECT}/k8s-${PROJECT_NAME}:${TAG_NAME} || exit 1
fi
