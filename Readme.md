# Create a Virtual Machine in Azure using CLI

This guide provides step-by-step instructions to create a virtual machine (VM) in Azure using the Azure Command-Line Interface (CLI).

Prerequisites
Ensure you have the Azure CLI installed on your local machine. You can download it from Azure CLI installation guide.


## Key Features

- **Cost-Effective**: Minimizes costs while delivering essential services.
- **High-Performance Hardware**: Optimized VM configurations for reliability.
- **Simplified Security**: Network Security Groups (NSG) for secure access.
- **Easy Deployment**: Simple Azure CLI commands for setup.
- **All-in-One Stack**: Integrates VM, VNet, and NSG seamlessly.
- **SSH Control**: Restricted access to specified public IP addresses.
- **Auto-Shutdown**: Saves costs by turning off VMs after hours.
- **Flexible Scaling**: Easily scale resources as needed.

## Project Goals

- Provide an affordable hosting solution.
- Prioritize security without sacrificing usability.
- Enhance user experience for developers and IT admins.







## Steps to Create a VM
Create a Resource Group
First, create a resource group to organize your resources. Run the following command:
```bash
az group create --name rg-vm --location westeurope
```

You can verify the resource group was created by listing all resource groups:
```bash
az group list --output table
```

## Step 2: Create a Virtual Network (VNet)
Create a virtual network (VNet) and a subnet for your VM:
```bash
az network vnet create \
  --resource-group rg-vm \
  --name vmx-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name mySubnet \
  --subnet-prefix 10.0.0.0/24
  ```

you can verify the VNet was created by listing all VNets in the resource group:
```bash
az network vnet list --resource-group rg-vm --output table
```

## Step 3: Create a Virtual Machine
Now, create the VM. Replace MySecurePassword123! with a secure password of your choice.
```bash
az vm create \
  --resource-group rg-vm \
  --name linux-server \
  --image Ubuntu2204 \
  --admin-username myadmin \
  --admin-password MySecurePassword123! \
  --authentication-type password \
  --public-ip-sku Basic \
  --size Standard_B1s \
  --vnet-name vmx-vnet \
  --subnet mySubnet \
  --output json
```

## Step 4: Set Up Auto-Shutdown
To save costs, set up an auto-shutdown schedule for your VM:
```bash
az vm auto-shutdown \
  --resource-group rg-vm \
  --name linux-server \
  --time 19:00
```

## Step 5: Retrieve the VM's IP Address
To connect to your VM, you need to know its IP address:
```bash
az vm list-ip-addresses --resource-group rg-vm --name linux-server --output table
```
## Step 6: Open SSH Port (22)
Create a network security group rule to allow SSH access:
```bash
az network nsg rule create \
  --resource-group rg-vm \
  --nsg-name nsg-vm \
  --name Allow-SSH \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes '*' \
  --description "Allow SSH access"
```

## Step 7: Connect to the VM via SSH
Finally, connect to your VM using SSH. Replace 10.0.0.4 with your VM's private IP address obtained in step 5:
```bash
ssh myadmin@10.0.0.4
```

# Create NSG Rule for Your Public IP
Now, add a rule to allow SSH access only from your public IP address:
```bash
az network nsg rule create \
  --resource-group rg-vm \
  --nsg-name nsg-vm \
  --name Allow-SSH-MyIP \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes 105.179.177.152/32 \
  --description "Allow SSH access only from my public IP"
```

## Step 3: Deny All Other Inbound Traffic
To ensure that no other IPs can access your VM via SSH, you should create a rule to deny all other inbound traffic on port 22:
```bash
az network nsg rule create \
  --resource-group rg-vm \
  --nsg-name nsg-vm \
  --name Deny-SSH-All \
  --priority 2000 \
  --direction Inbound \
  --access Deny \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes '*' \
  --description "Deny SSH access from all other IPs"
```