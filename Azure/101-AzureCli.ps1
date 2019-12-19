# Install Azure CLI
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
sudo tee /etc/apt/sources.list.d/azure-cli.list

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

# Check version
az --version
# Login to Azure
az login

# Search command
az find -q "az vm"

# some basic commands
az vm list
az group list
az storage account list

# Create Resource group
az group create -n "MSLearnTest01" -l "West US"

# Format output
az group list --output table

# Create VM
az vm create \
  --resource-group CrmTestingResourceGroup \
  --name CrmUnitTests \
  --image UbuntuLTS


