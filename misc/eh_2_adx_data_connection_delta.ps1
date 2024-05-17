<#
Authors: Clinton Frantz & DCODEV1702
Date: 5/17/2024

THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


Description:
This script will print out the differnce between the tables that are configured in Azure Event Hub and Azure Data Explorer's Data Connections.
This script is useful when you want to know when event hubs exists, however ADX tables that are not configured for ADX Database Data Connectors.

Usage:
1. Log into Azure via the CLI using Connect-AzAccount -UseDeviceAuthentication or via the Azure Portal -> Cloud Shell.
2. PowerShell Az Module is required (no checking is provided in this script)
2. Modify the variables $rg, $eh_ns, $adx, $adxDb to match your environment.
3. Run the script.
    -- ./eh_2_adx_data_connection_delta.ps1
4. The script will output the event hubs that exist, yet tables that are not configured via ADX Database Data Connectors.

#>

# -----------------------------------------------------------------
# !!! Modify the five variables below to match your environment !!!
$rg    = 'sec_telem_law_1'
$eh_ns = 'DiagnosticData-1'
$adx   = 'dart007'
$adxDb = 'sentinel-2-adx'
# -----------------------------------------------------------------

# Get the Event Hubs and ADX Data Connectors
# PowerShell Az Module is required (no checking is provided in this script)
$Eventhubtables = Get-AzEventHub -NamespaceName $eh_ns -ResourceGroupName $rg | ForEach-Object { $_.Name.ToString() }
$ADXDataConnectors = Get-AzKustoDataConnection -ResourceGroupName $rg -ClusterName $adx -DatabaseName $adxDb | ForEach-Object { ($_.Name -split '/')[2].ToString() -replace "-dc$"}

# Compare Event Hubs and ADX Data Connectors to see if there are any differences
$uniqueInList1 = Compare-Object $Eventhubtables $ADXDataConnectors | Where-Object {$_.SideIndicator -eq "<="}

# Print out the differences to the console
if ($uniqueInList1.Count -gt 0) {
    Write-Host "Event Hubs that exist however, ADX tables that are not configured via ADX Database Data Connectors" -ForegroundColor Yellow
    Write-Host "Be sure to create the ADX Data Connectors and Tables for the following Event Hubs: ($($uniqueInList1.Count))" -ForegroundColor Yellow
    Write-Host "Go here for assistance: https://github.com/dcodev1702/LogAnalytics-Export-2-ADX" -ForegroundColor Yellow
    
    $uniqueInList1 | ForEach-Object { Write-Host $_.InputObject }    
} else {
    Write-Host "No differences were found between Event Hubs: ($($Eventhubtables.Count)) and ADX Data Connectors!" -ForegroundColor Green
}
