# azscadeploy
deploy an sca in azure with terraform and ansible

to deploy SCA, do the following.  I use cloudshell for this:

```bash
git clone <this repository>
  
change directory to the repository dir
  
terraform init
terraform plan -out main.tfplan
terraform apply "main.tfplan"
terraform output -raw tls_private_key >pkey.out
chmod 600 pkey.out

#get the ip address of the created vm
az vm show -d -g scaResourceGroup -n scaVM --query publicIps -o tsv
#update inventory.ini with the IP address of the VM
ansible-playbook sca.yml
```

to remove, do
```
terraform destroy 
```

to ssh to your VM, do
```
ssh -i pkey.out azureuser:<your ip address>
```
