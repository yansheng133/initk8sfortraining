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
    printf "${YEL}--OS Verified-- ${NC}\n"
else
    printf "${RED}==OS is not Verified, use ubuntu 18.0==${NC}\n"
    exit 0
fi

# check fstab
printf "${GRN}--check FSTAB for swap-- ${NC}\n"

# backup fstab
printf "${GRN}--backup fstab to fstab.bck-- ${NC}\n"
sudo cp /etc/fstab /etc/fstab.bck

printf "${GRN}--swap off-- ${NC}\n"
sudo swapoff -a

# modify fstab
sudo sed -ri.bak ':a;N;$!ba;s/#===swap===#.+#===swap===#//' /etc/fstab

# remount all
sudo mount -a

printf "${GRN}==Phase 1 Complete==${NC}\n"
printf "${GRN}==Phase 2: update system and install kubernetes==${NC}\n"
sleep 1

printf "${GRN}--update system-- ${NC}\n"
sudo apt-get update && sudo apt-get upgrade -y

printf "${GRN}--install nfs package-- ${NC}\n"
sudo apt -y install nfs-common
sudo sed -i 's/# Domain = localdomain/Domain = training.inwinstack/g' /etc/idmapd.conf

printf "${GRN}--Install Docker-- ${NC}\n"
sleep 1

sudo apt-get install -y docker.io
printf "${GRN}--install kubeadm, kubelet, and kubectl-- ${NC}\n"
sleep 1

sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"

sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"

sudo apt-get update

sudo apt-get install -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00

printf "${YEL}--LOCK kubelet kubeadm kubectl version-- ${NC}\n"
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --kubernetes-version 1.20.1 --pod-network-cidr 10.6.0.0/16 |tee kubeadminfo.txt

printf "${GRN}==Installation Completed==${NC}\n"
