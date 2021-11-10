#!/bin/bash

terraform init
terraform plan -out main.tfplan
terraform apply "main.tfplan"
terraform output -raw tls_private_key >pkey.out
chmod 600 pkey.out
az vm show -d -g scaResourceGroup -n scaVM --query publicIps -o tsv > scaIP.txt
SCAIP=`cat scaIP.txt`
SEDCMD="s/20.83.123.73/$SCAIP/g"
cat inventory.ini.sample | sed $SEDCMD > inventory.ini
ansible-playbook -i ./inventory.ini sca.yml
