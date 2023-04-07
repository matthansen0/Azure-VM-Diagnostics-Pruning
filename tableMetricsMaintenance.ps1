## Set information & Connect
$TenantId = Read-Host -Prompt "Input the primary tenant ID"
$SubscriptionId = Read-Host -Prompt "Input the primary subscription ID"
Connect-AzAccount
Set-AzContext -Tenant $TenantId -Subscription $SubscriptionId 

$resourceGroup = Read-Host -Prompt "Resource Group Name"
$storageAccountName = Read-Host -Prompt "Storage Account Name"
$storageAccount = get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$ctx = $storageAccount.Context

# List & Count all tables & capacity in context
Get-AzStorageTable -Context $ctx
Write-Host "Total tables in this storage account:"
(Get-AzStorageTable -Context $ctx -Name "WADMetrics*").count

# Filter the results by year and retrieve count
$year = Read-Host -Prompt "Filter by year (e.g. 2018)"
$year = "WADMetrics*" + $year + "*"
$tables = Get-AzStorageTable -Context $ctx -Name $year
$count = $tables.Count
Write-Host "Total tables when filtering by specified year: $count"

# Prompt the user to continue with deletion or cancel
Write-Host "Do you want to remove all of the table entries for the specified year? Press 'y' to continue, otherwise press 'n' to cancel this script." -ForegroundColor Yellow
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
if ($key.Character -eq "y") {
    Write-Host "Continuing with script..." -ForegroundColor Green
}
else {
    Write-Host "Cancelling script..." -ForegroundColor Red
    return
}

# Remove all WADMetrics tables with the year in their name without confirmation, then re-count 
$deletedTables = Get-AzStorageTable -Context $ctx -Name $year
$deletedTables | Remove-AzStorageTable -Force
Write-Host "Total tables after deleting specified year: $count"