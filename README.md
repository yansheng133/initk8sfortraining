# this is training materials.
## install
1. git clone https://github.com/yansheng133/initk8sfortraining && cd initk8sfortraining
2. sudo ./nfs.sh && sudo ./master.sh
3. use sudo ./worker.sh to join workers at 'worker node'.
4. support ease join more workers.

you are ready, have fun :)

## notice
1. if your nis is not ens4, edit master.sh, worker.sh line 9 `ens4` and nfs.sh line 19 to your nic.
2. kubeadm info save at initk8sfortraining/kubeadminfo.txt
3. nfs info save at initk8sfortraining/nfs.info 

## environment recommand
1. kubernetes: 1.22.1
2. 1 master, 2 worker
3. 4 core, 8 G RAM 70G local Disk(recommand!)
4. storage: NFS@master
5. ingress controller: traefik
6. measure server installed

## reference
1. ingress controller: [traefik](https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/)
2. measure server: [here](https://github.com/kubernetes-sigs/metrics-server)
