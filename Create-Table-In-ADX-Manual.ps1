<# 
Author: Javier Soriano
Source: https://github.com/javiersoriano/sentinel-scripts/blob/main/ADX/Create-TableInADX.ps1
Slight modifications made on lines 52, 54, 61, 88 - 100 by DCODev1702 
Date: 26 June 2023

THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

PARAM(
    [Parameter(Mandatory=$true)]$TableName,  # The log analytics table you wish to have in ADX
    [Parameter(Mandatory=$true)]$WorkspaceId # The log analytics WorkspaceId
)

$query = $TableName + ' | getschema | project ColumnName, DataType'

$output = (Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $query).Results

$TableExpandFunction = $TableName + 'Expand'
$TableRaw = $TableName + 'Raw'
$RawMapping = $TableRaw + 'Mapping'

$FirstCommand = @()
$ThirdCommand = @()

foreach ($record in $output) {
    if ($record.DataType -eq 'System.DateTime') {
        $dataType = 'datetime'
        $ThirdCommand += $record.ColumnName + " = todatetime(events." + $record.ColumnName + "),"
    } elseif ($record.DataType -eq 'System.Int32') {
        $dataType = 'int'
        $ThirdCommand += $record.ColumnName + " = toint(events." + $record.ColumnName + "),"
    } elseif ($record.DataType -eq 'System.String') {
        $dataType = 'string'
        $ThirdCommand += $record.ColumnName + " = tostring(events." + $record.ColumnName + "),"
    } elseif ($record.DataType -eq 'System.SByte') {
        $dataType = 'bool'
        $ThirdCommand += $record.ColumnName + " = tobool(events." + $record.ColumnName + "),"
    } elseif ($record.DataType -eq 'System.Double') {
        $dataType = 'real'
        $ThirdCommand += $record.ColumnName + " = toreal(events." + $record.ColumnName + "),"
    } else {
        $dataType = 'string'
        $ThirdCommand += $record.ColumnName + " = tostring(events." + $record.ColumnName + "),"
    }
    $FirstCommand += $record.ColumnName + ":" + "$dataType" + ","    
}

$schema = ($FirstCommand -join '') -replace ',$'
$function = ($ThirdCommand -join '') -replace ',$'

$CreateRawTable = @'
.create table {0} (Records:dynamic)
'@ -f $TableRaw

$CreateRawMapping = @'
.create table {0} ingestion json mapping '{1}' '[{{"column":"Records","Properties":{{"path":"$.records"}}}}]'
'@ -f $TableRaw, $RawMapping

$CreateRetention = @'
.alter-merge table {0} policy retention softdelete = 0d
'@ -f $TableRaw

$CreateTable = @'
.create table {0} ({1})
'@ -f $TableName, $schema

$CreateFunction = @'
.create-or-alter function {0}() {{
    {1}
| mv-expand events = Records | where events.Type == '{3}' and isnotempty(events.TimeGenerated)
| project {2}
}}
'@ -f $TableExpandFunction, $TableRaw, $function, $TableName

$CreatePolicyUpdate = @'
.alter table {0} policy update @'[{{"Source": "{1}", "Query": "{2}()", "IsEnabled": true, "IsTransactional": true}}]'
'@ -f $TableName, $TableRaw, $TableExpandFunction

Write-Host -ForegroundColor Red 'Copy and run the following commands (one by one), on your Azure Data Explorer cluster query window to create the table, mappings and update policy:'
Write-Host -ForegroundColor Green $CreateRawTable
Write-Host `r
Write-Host -ForegroundColor Green $CreateRawMapping
Write-Host `r
Write-Host -ForegroundColor Green $CreateRetention
Write-Host `r
Write-Host -ForegroundColor Green $CreateTable
Write-Host `r
Write-Host -ForegroundColor Green $CreateFunction
Write-Host `r
Write-Host -ForegroundColor Green $CreatePolicyUpdate

# Define the output file path, adjust it according to your need
$filePath = ".\$TableName`_Table.txt"

Write-Verbose "Creating file $filePath so it can be upload to Cloud Shell or archived for later use"
# Use Add-Content to add text to the file
Add-Content -Path $filePath -Value $CreateRawTable
Add-Content -Path $filePath -Value "`r"
Add-Content -Path $filePath -Value $CreateRawMapping
Add-Content -Path $filePath -Value "`r"
Add-Content -Path $filePath -Value $CreateRetention
Add-Content -Path $filePath -Value "`r"
Add-Content -Path $filePath -Value $CreateTable
Add-Content -Path $filePath -Value "`r"
Add-Content -Path $filePath -Value $CreateFunction
Add-Content -Path $filePath -Value "`r"
Add-Content -Path $filePath -Value $CreatePolicyUpdate
