#!/bin/bash

update_system() {
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get install -y debian-keyring debian-archive-keyring jq git ssh-import-id apt-transport-https ca-certificates curl software-properties-common unzip
}

install_vault() {
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get install -y vault
}

write_vault_config() {
  if [ -f /etc/vault/config.hcl ]; then
    echo "vault config already exists, removing it"
    rm -f /etc/vault/config.hcl
    return
  fi

cat <<EOF > /etc/vault/config.hcl
api_addr      = "http://${load_balancer_ip}:8200"
cluster_addr  = "https://${load_balancer_ip}:8201"
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable = 1
}
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "${instance_hostname}"
}
ui = true

EOF
}

echo "starting system update"
update_system

echo "installing vault"
install_vault

echo "write vault config"
write_vault_config

echo "Enabling vault on boot"
systemctl enable vault

echo "install complete"