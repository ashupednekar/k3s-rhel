sudo mount bpffs -t bpf /sys/fs/bpf
mkdir /home/vagrant/apiserver-details
sudo chown -R $USER:$USER /home/vagrant/apiserver-details

export MASTER_IP=$(ip a | grep global | grep -v '10.0.2.15' | awk '{print $2}' | cut -f1 -d '/')
echo $MASTER_IP > /home/vagrant/apiserver-details/master-ip

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none --disable-network-policy --disable traefik --disable metrics-server' sh -

#apiserver details
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/apiserver-details/k3s.yaml
sudo chown $USER:$USER /home/vagrant/apiserver-details/k3s.yaml
sudo chown $USER:$USER /etc/rancher/k3s/k3s.yaml

sudo sed -i -e "s/127.0.0.1/${MASTER_IP}/g" /home/vagrant/apiserver-details/k3s.yaml

sudo cp /var/lib/rancher/k3s/server/node-token /home/vagrant/apiserver-details/node-token
sudo chown $USER:$USER /home/vagrant/apiserver-details/node-token

#open 6443
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --reload

#helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#cilium
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install --version 1.16.6 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
cilium status --wait
