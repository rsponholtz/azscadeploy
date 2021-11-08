# azscadeploy
deploy an sca in azure with terraform and ansible

to deploy SCA, do the following.  It is convenient to use cloudshell bash for this:

```bash
git clone <this repository>
  
#change directory to the repository dir
#inspect the sca.tf file, updating as you see fit, particularly
#the resource group name and the region to deploy in

terraform init
terraform plan -out main.tfplan
terraform apply "main.tfplan"
terraform output -raw tls_private_key >pkey.out
chmod 600 pkey.out

#get the ip address of the created vm
az vm show -d -g scaResourceGroup -n scaVM --query publicIps -o tsv
#update inventory.ini with the IP address of the VM
ansible-playbook -i ./inventory.ini  sca.yml
```

to remove, do

```
terraform destroy 
```

to ssh to your VM, do

```bash
ssh -i pkey.out azureuser@<your ip address>
```

you can generate a supportconfig file on your SUSE virtual machines by doing

```bash
hana1:~ # supportconfig
```

This puts the supportconfig output file in /var/log/scc_<hostname>...txz.  You'll need to transfer this file to your sca machines for analysis.  An efficient way to do this is to use a storage account in Azure.  You'll want to create a storage account with a blob container, and generate a shared access signature for your storage account.  After installing [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10), you can upload your supportconfig to the storage account like this:

```bash
azcopy cp "/var/log/scc_hana*.txz" "https://<storage-account-name>.blob.core.windows.net/supportconfigs?sp=rfaeddl&st=2021-09-28T23:22:28Z&se=2022-09-19T07:22:28Z&spr=https&sv=2020-08-04&sr=c&sig=JEQF%2DIdp5Wz0DkbjQDJUv%2Bw6zzn%2HGFUEhhvxaHHGvP%2BM%3D"
```

The next step will be getting the supportconfig file to your SCA appliance.  If it's in your storage account, you can download it using azcopy - this will be the most efficient mechanism.  Alternatively, you can upload supportconfig files to your VM with
```bash
scp <supportconfig file> -i pkey.out azureuser:<your ip address>:~/
```

to run the supportconfig analyzer on your supportconfig file, do

```bash
scatool scc_<your file name>.txz
```

This 
