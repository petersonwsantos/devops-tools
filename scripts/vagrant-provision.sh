#!/bin/bash
set -e
set -o pipefail

blue=$'\e[1;34m'


# dev tools and misc
install_hub="2.5.0"                     # version or latest
gen_ssh_keys="yes"                      # yes/no
install_oh_my_zsh="yes"                 # yes/no

#cloud_providers
install_awscli="yes"                    # yes/no     
install_google_cloud_cli="yes"          # yes/no  

# docker tools
install_docker="yes"                    # yes/no
install_compose="1.22.0"                # version or latest


# Kubernetets tools
install_kubectl="yes"                   # yes/no   
install_helm="v2.10.0-rc.1"             # only helm version
install_kubens_keubectx="yes"           # yes/no
install_skaffold="latest"               # version or latest
install_kops="latest"                   # version or latest
install_heptio_authenticator="0.3.0"    # only version 
install_kompose="1.16.0"                # version or latest


# automation
install_packer="1.2.5"                  # only version 
install_terraform="latest"              # version or latest
# CI/CD
install_jenkins_x="v1.3.89"             # version or latest
#PuppetLabs
install_puppet_agent="yes"              # yes/no    
install_puppet_pdk="yes"                # yes/no
install_puppet_beaker="yes"             # yes/no


# Essential
apt-get update
apt-get upgrade -y
apt-get -y install apt-transport-https vim unzip curl wget jq make zsh vim openjdk-8-jre apache2-utils


# create new ssh key
if [[ "$gen_ssh_keys" == "yes" ]]; then
    if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        mkdir -p /home/vagrant/.ssh
        ssh-keygen -f /home/vagrant/.ssh/id_rsa -N ''
        chown -R vagrant:vagrant /home/vagrant/.ssh
    fi
fi

# awscli and ebcli
if [[ "$install_awscli" == "yes" ]]; then
    # pip install -U pip
    # pip3 install -U pip
    # if [[ $? == 127 ]]; then
    #     wget -q https://bootstrap.pypa.io/get-pip.py
    #     python get-pip.py --user
    #     python3 get-pip.py --userexit
    # fi
    # pip install -U awscli   --user
    # pip install -U awsebcli --user
    apt-get install awscli -y
fi

if [[ "$install_heptio_authenticator" != ""  ]]; then
    heptio_authenticator_version=$install_heptio_authenticator
    wget -q  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${heptio_authenticator_version}/heptio-authenticator-aws_${heptio_authenticator_version}_linux_amd64
    chmod +x heptio-authenticator-aws_${heptio_authenticator_version}_linux_amd64
    sudo mv  -fv heptio-authenticator-aws_${heptio_authenticator_version}_linux_amd64 /usr/local/bin/heptio-authenticator-aws
fi


 # Hub
if [[ "$install_hub"  != "" ]]; then
    if [[ "$install_hub" == "latest"  ]]; then
        hub_ver=$(curl -sS https://api.github.com/repos/github/hub/releases/latest | jq -r .tag_name | sed -e 's/^v//')
    else     
        hub_ver=$install_hub
    fi   
    wget -q -O hub.tgz https://github.com/github/hub/releases/download/v${hub_ver}/hub-linux-amd64-${hub_ver}.tgz
    tar xvzf hub.tgz
    sudo bash ./hub-linux-amd64-${hub_ver}/install
    rm -rfv hub-linux-amd64-${hub_ver} hub.tgz
fi

# docker
if [[ "$install_docker" == "yes"  ]]; then
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker vagrant
fi


# Docker compose 
if [[ "$install_compose"  != "" ]]; then
    if [[ "$install_compose" == "latest"  ]]; then
        compose_ver=$(curl -sS https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name | sed -e 's/^v//')
    else     
        compose_ver=$install_compose
    fi   
    curl -L "https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Kompose - convert compose to kubernettes yaml
if [[ "$install_kompose"  != "" ]]; then
    if [[ "$install_kompose" == "latest"  ]]; then
        kompose_ver=$(curl -sS https://api.github.com/repos/kubernetes/kompose/releases/latest | jq -r .tag_name | sed -e 's/^v//')
    else     
        kompose_ver=$install_kompose
    fi   
    curl -L https://github.com/kubernetes/kompose/releases/download/v${kompose_ver}/kompose-linux-amd64 -o kompose
    chmod +x kompose
    mv ./kompose /usr/local/bin/kompose
fi



# kubectl
if [[ "$install_kubectl" == "yes"  ]]; then

  curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg -o apt-key.gpg
  apt-key add apt-key.gpg
  #sleep 21
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get -y install kubectl
fi

# Helm
if [[ "$install_helm" != "" ]]; then
    wget -q https://storage.googleapis.com/kubernetes-helm/helm-${install_helm}-linux-amd64.tar.gz
    tar xvzf helm-${install_helm}-linux-amd64.tar.gz
    chmod +x linux-amd64/helm
    sudo cp linux-amd64/helm /usr/local/bin
    rm helm-* linux-amd64 -rfv
fi



# gcloud
if [[ "$install_google_cloud_cli" == "yes"  ]]; then
    curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update
    apt-get install google-cloud-sdk -y
fi

#terraform
if [[ "install_terraform" != ""  ]]; then
    if [[ $install_terraform == "latest"  ]]; then
        terraform_version="$(curl -sS https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name | sed -e 's/^v//')"
    else
        terraform_version=$install_terraform
    fi
    wget -q  "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" -O terraform.zip
    sudo unzip -o terraform.zip -d /usr/local/bin
    rm terraform.zip
    # terrafrom graph export
    sudo apt-get -y install graphviz
fi

#jenkins-x
if [[ "$install_jenkins_x" != ""  ]]; then
    if [[ $install_jenkins_x == "latest"  ]]; then
        jenkins_x_version="$(curl -sS https://api.github.com/repos/jenkins-x/jx/releases/latest | jq -r .tag_name)"
    else
        jenkins_x_version=$install_jenkins_x
    fi
    curl -sSL "https://github.com/jenkins-x/jx/releases/download/${jenkins_x_version}/jx-linux-amd64.tar.gz"  | tar xzv
    sudo mv  -fv jx /usr/local/bin
fi

# kops
if [[ "$install_kops" != ""  ]]; then
    if [[ $install_kops == "latest"  ]]; then
        kops_version="$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)"
    else
        kops_version=$install_kops
    fi
    wget -q  -O kops https://github.com/kubernetes/kops/releases/download/${kops_version}/kops-linux-amd64
    chmod +x ./kops
    sudo mv  -fv ./kops /usr/local/bin/
fi


# Skafold
if [[ "$install_skaffold" != ""  ]]; then
    if [[ $install_skaffold == "latest"  ]]; then
        skaffold_version="$(curl -sS https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest | grep tag_name  | cut -d '"' -f 4)"
    else
        skaffold_version=$install_skaffold
    fi
    curl -sSo skaffold https://storage.googleapis.com/skaffold/releases/${skaffold_version}/skaffold-linux-amd64
    chmod +x skaffold
    sudo mv  -fv skaffold /usr/local/bin
fi

# kubens and keubectx (https://github.com/ahmetb/kubectx)
if [[ "$install_kubens_keubectx" == "yes"  ]]; then
  rm -rf /opt/kubectx
  rm -f /usr/local/bin/kubectx
  rm -f /usr/local/bin/kubens
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
  sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

# puppet agent 
if [[ "$install_puppet" == "yes"  ]]; then
    wget -q https://apt.puppetlabs.com/puppet5-release-xenial.deb
    dpkg -i puppet5-release-xenial.deb
    apt update
    apt install -y puppet
    rm puppet5-release-xenial.deb
fi 

# Puppet Development Kit
if [[ "$install_puppet_pdk" == "yes"  ]]; then
    wget -q https://puppet-pdk.s3.amazonaws.com/pdk/1.7.0.0/repos/deb/xenial/PC1/pdk_1.7.0.0-1xenial_amd64.deb
    dpkg -i pdk_1.7.0.0-1xenial_amd64.deb
    apt -f install 
    rm pdk_1.7.0.0-1xenial_amd64.deb
fi 

# Beaker
if [[ "$install_puppet_beaker" == "yes"  ]]; then
    apt-get install -y ruby-dev libxml2-dev libxslt1-dev g++ zlib1g-dev
    gem install beaker
fi 

# Packer 
if [[ "$install_packer" != ""  ]]; then
    packer_version=$install_packer
    wget -q https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
    unzip packer_${packer_version}_linux_amd64.zip
    mv  -fv packer /usr/local/bin/
fi



if [[ "$install_oh_my_zsh" == "yes"  ]]; then
    ls /home/vagrant/.oh-my-zsh &> /dev/null && rm -rf /home/vagrant/.oh-my-zsh
    ls /home/vagrant/.zshrc     &> /dev/null && rm -f /home/vagrant/.zshrc
    mkdir /home/vagrant/.oh-my-zsh
    git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
    cp /vagrant/scripts/zshrc /home/vagrant/.zshrc -v
    chown vagrant:vagrant /home/vagrant/.oh-my-zsh -R
    chown vagrant:vagrant /home/vagrant/.zshrc
fi 


