# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------
Param(
    [string]
    [Parameter(mandatory=$true)]
    $ApplicationName,  

    [string]
    [Parameter(mandatory=$false)]
    $Location = 'westeurope'
)

$resourceGroupName="rg$ApplicationName"
$aksName="aks$ApplicationName"
$acrName="acr$ApplicationName"
$aksServicePrincipalName=$ApplicationName

# ----- Create Resource Group
Write-Host "Create Resoure Group"
az group create --name $resourceGroupName --location $Location

# ----- Create ACR
Write-Host "Create ACR"
az acr create --resource-group $resourceGroupName --name $acrName --sku Basic

# ----- Create AKS Service Principals
Write-Host "Create AKS Service Principals"
$aksServicePrincipal = (az ad sp create-for-rbac -n $aksServicePrincipalName) | ConvertFrom-Json

# Sleep to allow SP to be replicated across AAD instances.
# TODO: Update this to be more deterministic.
Start-Sleep -s 30

$aksClientId = $aksServicePrincipal.appId
$aksObjectId = (az ad sp show --id $aksServicePrincipal.appId | ConvertFrom-Json).id
$aksClientSecret = $aksServicePrincipal.password

az aks create `
    --resource-group $resourceGroupName `
    --name $aksName `
    --node-count 1 `
    --generate-ssh-keys `
    --attach-acr $acrName `
    --service-principal $aksClientId `
    --client-secret $aksClientSecret

az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview"
az feature show --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview"

az aks nodepool add `
    --resource-group $resourceGroupName `
    --cluster-name $aksName `
    --name mywasipool `
    --node-count 1 `
    --workload-runtime WasmWasi

az aks get-credentials --admin --name $aksName --resource-group $resourceGroupName --overwrite-existing

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
kubectl create namespace redis
kubectl apply -f ./redis-pod.yaml -n redis

