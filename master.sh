sudo mount bpffs -t bpf /sys/fs/bpf
mkdir /home/vagrant/apiserver-details
sudo chown -R $USER:$USER /home/vagrant/apiserver-details

export MASTER_IP=$(ip a | grep global | grep -v '10.0.2.15' | awk '{print $2}' | cut -f1 -d '/')
echo $MASTER_IP > /home/vagrant/apiserver-details/master-ip

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --disable=servicelb --disable=traefik --node-ip=${MASTER_IP} --node-external-ip=${MASTER_IP} --bind-address=${MASTER_IP}" sh -


sudo chown $USER:$USER /etc/rancher/k3s/k3s.yaml
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/apiserver-details/k3s.yaml
sudo chown $USER:$USER /home/vagrant/apiserver-details/k3s.yaml

sudo sed -i -e "s/127.0.0.1/${MASTER_IP}/g" /home/vagrant/apiserver-details/k3s.yaml

sudo cp /var/lib/rancher/k3s/server/node-token /home/vagrant/apiserver-details/node-token
sudo chown $USER:$USER /home/vagrant/apiserver-details/node-token


