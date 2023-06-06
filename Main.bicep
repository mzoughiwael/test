// Déclaration des paramètres
param location string = resourceGroup().location
param rgName string = 'waelaz900'
param vnetName string = 'waelTestVnet'
param subnetName string = 'waelTestSubnet'
param vmName string = 'waelTestVm'
param adminUsername string = 'waelUserName'
@secure()
param adminPassword string 
param diskSizeGb int = 128
param nsgName string = 'waelNSG'

// Création Resource Group
resource rg 'Microsoft.Storage/storageAccounts@2022-09-01'= {
  name: rgName
  location: location
  kind: 'StorageV2'
  sku: {
      name: 'Standard_LRS'
    }
  
}

// Création Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

// Création Subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${vmName}-publicip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: '${vmName}-nic'
  location: location
  
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

// Création virtual Machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: diskSizeGb
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
