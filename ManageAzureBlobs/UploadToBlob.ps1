$Subscription = 'LastWordInNerd'
Add-AzureRmAccount
$SubscrObject = Get-AzureRmSubscription -SubscriptionName $Subscription
Set-AzureRmContext -SubscriptionObject $SubscrObject

$ResourceGroupName = 'nrdcfgstore'
$StorageAccountName = 'nrdcfgstoreacct'
$ContainerName = 'json'

#region Access blob container

$StorAcct = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$StorKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $StorAcct.ResourceGroupName -Name $StorAcct.StorageAccountName).where({$PSItem.KeyName -eq 'key1'})


Add-AzureAccount
$AzureSubscription = ((Get-AzureSubscription).where({$PSItem.SubscriptionName -eq $SubscrObject.Name})) 
Select-AzureSubscription -SubscriptionName $AzureSubscription.SubscriptionName -Current
$StorContext = New-AzureStorageContext -StorageAccountName $StorAcct.StorageAccountName -StorageAccountKey $StorKey.Value

Try{
    $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorContext -ErrorAction Stop
}
Catch [System.Exception]{
    Write-Output ("The requested container doesn't exist.  Creating container " + $ContainerName)
    $Container = New-AzureStorageContainer -Name $ContainerName -Context $StorContext -Permission Off
}
    

#endregion

#region upload zip files

$FilesToUpload = Get-ChildItem -Path .\ -Filter *.json

ForEach ($File in $FilesToUpload){

        Set-AzureStorageBlobContent -Context $StorContext -Container $Container.Name -File $File.FullName -Force -Verbose
        
}


#endregion