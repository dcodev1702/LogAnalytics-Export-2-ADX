<#
Author: DCODEV1702
Date: 8 May 2024

THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


Description:
This script will set the Message Retention Time on all Event Hubs for a specified Event Hub Namespace.

Usage:
0. Ensure you have the requesite RBAC permissions
1. Open a PowerShell or Azure Cloud Shell session w/ Az module installed & the appropriate permissions
2. Be sure to set the execution policy to Unrestricted
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
3. Ensure you're in the right subscription
    (Get-AzContext).Subscription.Name
    Set-AzContext -SubscriptionId <SubscriptionId>
4. Run the PowerShell script
    ./Set-EH-RetentionTime.ps1 -EventHubNamespaceName 'diagnosticData-1' -ResourceGroupName 'sec_telem_law_1'  -RetentionTimeInHours 504
#>

#Requires -Modules Az.EventHub

param(
    [Parameter(Mandatory=$true)]
    [string]$EventHubNamespaceName,
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [int]$RetentionTimeInHours
)

Write-Host "You're currently in Subscription: `"$((Get-AzContext).Subscription.Name)`"" -ForegroundColor Yellow

$confirm = Read-Host "Are you sure you want to continue to set message retention time for event hubs within the $EventHubNamespaceName to $RetentionTimeInHours hours? (Y/N)"

if ($confirm -eq 'Y' -or $confirm -eq 'y') {

    Write-Host "Setting Retention Time for all Event Hubs in the Event Hub Namespace: $EventHubNamespaceName to $RetentionTimeInHours hours..." -ForegroundColor Yellow
    $eventHubs = Get-AzEventHub -NamespaceName $EventHubNamespaceName -ResourceGroupName $ResourceGroupName

    foreach ($eventHub in $eventHubs) {
        $eventHub | Set-AzEventHub -RetentionTimeInHour $RetentionTimeInHours | Select-Object -Property Name, RetentionTimeInHour
    }

    Write-Host "Retention Time for all Event Hubs ($(($eventHubs).Count)) in the Event Hub Namespace '$EventHubNamespaceName' has been set to $RetentionTimeInHours hours." -ForegroundColor Green
} else {
    Write-Host "`"$confirm`" <entered> - Operation Cancelled ..Goodbye." -ForegroundColor Red
    exit 1
}
