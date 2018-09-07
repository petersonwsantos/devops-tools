#!/bin/bash
set -e

echo ""
echo "# dev tools and misc"

if `hub version &>  /dev/null`; then
    echo "install_hub=$(hub version | grep ^'hub version ' | awk '{print $3}')"
else 
    echo 'install_hub=""'
fi

if [ -e "/home/vagrant/.ssh/id_rsa" ]; then
    echo 'gen_ssh_keys="yes"'
else 
    echo 'gen_ssh_keys="no"'        
fi 

if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo 'install_oh_my_zsh="yes"'
else 
    echo 'install_oh_my_zsh="no"'
fi

echo " "
echo "# Cloud Providers"

if `aws help &>  /dev/null`; then
    echo "awscli install_awscli=\"yes\"               # awscli `aws --version  | awk '{print $1}' | cut -d/ -f2`"
else 
    echo 'awscli install_awscli="no"'
fi


if `gcloud --version  &>  /dev/null`; then
    echo "install_google_cloud_cli=\"yes\"            # gcloud  `gcloud --version | grep ^'Google Cloud SDK' | awk '{print $4}' 2&> /dev/null `"
else 
    echo 'install_google_cloud_cli="no"'
fi

echo ""
echo "# docker tools"
if `docker version  &>  /dev/null`; then
    echo "install_docker=\"yes\"                # version `docker version | grep ^'  Version:' | awk '{print $2}'` "
else 
    echo 'install_docker="no"'
fi

# Docker Compose
if `docker-compose version  &>  /dev/null`; then
    echo "install_compose=`docker-compose version | grep ^'docker-compose' | awk '{print $3}' | sed 's/,//g'` "
else 
    echo 'install_compose=""'
fi

# --------------------------------
echo ""
echo "# Kubernetets tools"

# Kubectl 
if `kubectl  &>  /dev/null`; then
    echo "install_kubectl=\"yes\"                # version `kubectl version --client=true | cut -d , -f 3 | grep -v ^'The connection' | sed 's/GitVersion:"v//g' | sed 's/"//g'` "
else 
    echo 'install_kubectl="no"'
fi

# Helm
if `helm &>  /dev/null`; then
    echo "install_helm=`helm version --client | cut -d, -f1 | cut -d: -f3 | sed 's/"//g' | sed 's/v//g'` "
else 
    echo 'install_kubectl=""'
fi

echo "install_kubens_keubectx=\"yes\"" 



# echo "install_awscli=`aws --version  | awk '{print $1}' | cut -d/ -f2`"
# gcloud --version | grep ^'Google Cloud SDK'
# echo "Docker `docker version | grep ^'  Version:' | awk '{print $2}'`"
# echo "Docker-Compose `docker-compose version | grep ^'docker-compose version' | awk '{print $3}' | sed 's/,//g'`"
# echo "Kubectl `kubectl version --client=true | cut -d , -f 3 | grep -v ^'The connection' | sed 's/GitVersion:"v//g' | sed 's/"//g'`"
