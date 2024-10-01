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

# write_vault_config() {
#   cat <<EOF > /etc/vault/config.hcl

# EOF
# }

echo "starting system update"
update_system

echo "installing vault"
install_vault

echo "install complete"