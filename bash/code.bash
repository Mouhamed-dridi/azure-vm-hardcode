#!/bin/bash

# Step 1: Create a Resource Group
az group create --name rg-vm --location westeurope

# Verify the resource group creation
az group list --output table 

# Step 2: Create a Virtual Network (VNet)
az network vnet create \
  --resource-group rg-vm \
  --name vmx-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name mySubnet \
  --subnet-prefix 10.0.0.0/24

# Verify the VNet creation
az network vnet list --resource-group rg-vm --output table

# Step 3: Create a Virtual Machine (VM)
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

# Step 4: Set up Auto-Shutdown
az vm auto-shutdown \
  --resource-group rg-vm \
  --name linux-server \
  --time 19:00

# Step 5: Show VM IP Address
az vm list-ip-addresses --resource-group rg-vm --name linux-server --output table

# Step 6: Create NSG Rule for SSH
az network nsg rule create \
  --resource-group rg-vm \
  --nsg-name nsg-vm \
  --name Allow-SSH \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes '105.179.177.152' \
  --description "Allow SSH access"

# Step 7: Access the VM via SSH
echo "Access your VM using: ssh myadmin@<your_private_ip>"
