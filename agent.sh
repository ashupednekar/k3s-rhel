export AGENT_IP=$(ip a |grep global | grep -v '10.0.2.15' | awk '{print $2}' | cut -f1 -d '/')
export MASTER_IP=$(cat /home/vagrant/apiserver-details/master-ip)
export NODE_TOKEN=$(cat /home/vagrant/apiserver-details/node-token)

sudo mount bpffs -t bpf /sys/fs/bpf


curl -sfL https://get.k3s.io | sh -s - agent --server "https://$MASTER_IP:6443" --token "$NODE_TOKEN"
