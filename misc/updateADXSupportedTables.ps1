# Courtesy of ChatGPT-4  :)

# Initialize an empty array
$tables = @()

# Read the file line by line
Get-Content "ADXSupportedTables2.txt" | ForEach-Object {
    # Add each line to the array
    $tables += $_.Trim()
}

# Create an object with the array
$obj = [PSCustomObject]@{
    "SupportedTables" = $tables
}

# Convert the object to JSON and write it to a file
$obj | ConvertTo-Json -Depth 100 | Set-Content "ADXSupportedTables.json"
