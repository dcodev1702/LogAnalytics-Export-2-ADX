# Security Operations - Azure Cloud Architecture
![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/a043829b-8640-48c1-9391-e9abca8a96cc)


# Export Log Analytics tables to ADX via Event Hubs
Export tables in a Log Analytics Workspace (LAW) to an Azure Data Explorer (ADX) Database (DB) via Event Hubs <br />

# Resources:
1. [Microsoft Documentation - Azure Data Explorer](https://learn.microsoft.com/en-us/azure/data-explorer/)
2. [Microsoft Documentation - Log Analyrics Data Export to ADX via Event Hubs](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal)
3. [Works Cited - LinkedIn Source](https://www.linkedin.com/pulse/howto-configure-azure-sentinel-data-export-long-term-storage-lauren/)
4. [Tech Community - Export LAW tables to ADX by Javier Soriano](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/using-azure-data-explorer-for-long-term-retention-of-microsoft/ba-p/1883947)
5. [Manual Table Export](https://github.com/javiersoriano/sentinel-scripts/blob/main/ADX/Create-TableInADX.ps1)
6. [Programmatic Table Export](https://github.com/Azure/Azure-Sentinel/tree/master/Tools/AzureDataExplorer)
    * CAUTION: See my repo for an updated (24 JUN 2023) [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json)
    * CHECK FOR UPDATED TABLES [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)
  

# Instructions:
1. Register the Microsoft.insights resource provider (if not already done so).
   * You can check with the following PowerShell command (issue in your Azure Cloud Shell if required) <br />
   
   ```console
    Get-AzResourceProvider | ? {$_.ProviderNamespace -eq 'Microsoft.Insights'}
   ```

   ![Image 6-24-23 at 10 55 PM](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/af00c1d3-a7c6-40e1-8409-256cfc953ed4)

3. Create an Azure Data Explorer (ADX) Cluster and Database where your tables will reside.
4. Create an Event Hub Namespace with the appropriate Throughput Units (TU's - STD SKU is 22.00 per TU. Refer to documentation for more details)
5. Identify the Log Analytics Workspace (LAW) you want to export your tables from use the 'data export' blade.
   a. Create and enable an export rule.
      1. Each LAW can only have a max of 10 enabled rules.
  
   ## Log Analytics Workspace -- Data Export (blade)
   * Recommend letting Azure Event Hub automatically determine the name of the Event Hub (e.g. am-[exported table name])
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/3edcd03f-0dcc-4112-ace3-0268bbd7bd4f)

   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/287fd9ca-b424-49c6-ba32-a4b97dca29c8)

6. Go to the "Kusto Table Create" directory and copy the commands from the tables you want to create in Azure Data Explorer (ADX)
   a. You can can export additional tables from Log Analytics using Javier's PowerShell script (Create-Table-In-ADX-Manual.ps1)

   ## Manually export tables from Log Analytics to Kusto commands to create ADX tables.
   * Pre-req: You will need the PowerShell Azure Module installed
      * Install-Module -Name Az -Scope User -Force
      * .\Create-Table-In-ADX.ps1 -TableName [Log-A table] -WorkspaceId [Your WorkspaceId]
      * Copy and Paste the output from this script into notepad
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/c7d54452-1dc9-49ea-be3a-edd489275a74)


7. Go to the Database in your ADX Cluster and ONE BY ONE, run each Kusto command to import/create the corresponding tables exported from your LAW.
    * CAUTION: See [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json) to ensure the table you're importing / creating in ADX can be exported via LAW.
    * LAW Tables can't be more than 47 characters log
    * [Custom Tables (CL's)](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal) can ONLY be exported via Data Collection Rules (HTTP REST API or Azure Monitor Agent/Extension)
    * CHECK FOR UPDATED TABLES -> [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)

   ## MANUALLY CREATE TABLES (exported from LAW) INTO ADX / Database
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/16c738a3-1154-44e8-8255-36f708ac329b)



8. Once your tables have been successfully created in your ADX database, you need to establish 'data connections' to EACH table you want to import via Event Hub.
   ## EVENT HUB NAMESPACE: SecurityTables-1
   * Corresponding Event Hubs (created automatically from the LAW data export rule in (step 2))
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/f29a24ae-2efa-41e1-a6e3-f1b643ac0443)


9. Data Connections within ADX Cluster / Database.  This is what connects to EACH of your Event Hubs and the RAW Tables ingest your data that resides within the Event Hubs. Each table
   you export from Log Analytics to an Event Hub, will require a data connection from your ADX database, so the information can flow.
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/04ddd907-744b-4d7d-a1cd-305518ec4ff6)

10. Be patient, it takes about 20 - 30 minutes before data begins to flow from Log Analytics to your Event Hubs and then into your ADX Database. <br />

   **_Querying the CommonSecurityLog table via Log Analytics_** <br />
   ![3A3CA9C2-AFE1-453A-80DD-C1A7954C8831](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/0560e336-8818-480b-8580-d1067a391aaa)


   **_Querying the CommonSecurityLog table via Azure Data Explorer (ADX)_**
   ![EEA8D74E-F942-4A80-9FAB-D8C4F3DCEC81](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/c9a3b93a-1908-4084-9fcc-141879771b3b)

