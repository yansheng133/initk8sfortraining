#!/bin/bash
RED='\033[1;31m' # alarm
GRN='\033[1;32m' # notice
YEL='\033[1;33m' # warning
NC='\033[0m' # No Color

printf "${GRN}==Prepare install kubernetes training environment for ubuntu 18.04==${NC}\n"

sleep 1

printf "${RED}==phase 1: modify file system==${NC}\n"

# get os info
OSVERSION=$(cat /etc/lsb-release |grep DISTRIB_CODENAME |cut -d '=' -f 2)

# verify os info
if [ "${OSVERSION}" = 'bionic' ];
then
    printf "${YEL} --OS Verified-- ${NC}\n"
else
    printf "${RED}==OS is not Verified, use ubuntu 18.0==${NC}\n"
    exit 0
fi

# check fstab
printf "${GRN} --check FSTAB for swap-- ${NC}\n"

# backup fstab
printf "${GRN} --backup fstab to fstab.bck-- ${NC}\n"
sudo cp /etc/fstab /etc/fstab.bck

printf "${GRN} --swap off-- ${NC}\n"
sudo swapoff -a

# modify fstab
sudo sed -ri.bak ':a;N;$!ba;s/#===swap===#.+#===swap===#//' /etc/fstab

# remount all
sudo mount -a

printf "${GEN}==Phase 1 Complete==${NC}\n"
printf "${GEN}==Phase 2: update system and install kubernetes==${NC}\n"
sleep 1

printf "${GEN} --update system-- ${NC}\n"
sudo apt-get update && sudo apt-get upgrade -y

printf "${GEN} --Install Docker-- ${NC}\n"
sleep 1

sudo apt-get install -y docker.io
printf "${GEN} --install kubeadm, kubelet, and kubectl-- ${NC}\n"
sleep 1

sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"

sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"

sudo apt-get update

sudo apt-get install -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00

printf "${YEL} --LOCK kubelet kubeadm kubectl version-- ${NC}\n"
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --kubernetes-version 1.20.1 --pod-network-cidr 10.6.0.0/16 |tee kubeadminfo.txt

printf "${GEN} --if you lost token, check kubeadminfo.txt--${NC}\n"
printf "${GEN} --if you need join worker and token expired, regen it--${NC}\n"
printf "${GEN} --kubeadm --help will help--${NC}\n"

sleep 6

printf "${GEN} --config CLI environment-- ${NC}\n"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo 'source <(kubectl completion bash)' >>$HOME/.bashrc
echo "PS1='\[\033[01;32m\]student@master\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >>$HOME/.bashrc

source $HOME/.bashrc

printf "${GEN} --USE calico CNI-- ${NC}\n"
kubectl apply -f calico.yaml

printf "${GEN} --wait for pods READY for few seconds-- ${NC}\n"
sleep 1m
kubectl get node

printf "${GEN} --setup keypair-- ${NC}\n"
ssh-keygen -t dsa -N "" -f $HOME/.ssh/id_dsa

printf "${GEN}==Installation Completed==${NC}\n"

printf "${YEL}1. master node setup, run worker.sh to setup worker.${NC}\n"
printf "${YEL}2. if you need kubeadm info, check kubeadminfo.txt${NC}\n"
printf "${YEL}3. when worker.sh done, run join command below.${NC}\n"
printf "${GEN}==join worker command==${NC}\n"
tail kubeadminfo.txt -n 2
