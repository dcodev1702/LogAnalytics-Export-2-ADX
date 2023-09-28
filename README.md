<h1 align="center">Security Operations - Azure Cloud Architecture <h1/>
   
![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/a043829b-8640-48c1-9391-e9abca8a96cc)


# Export Log Analytics tables to ADX via Event Hubs
Export tables in a Log Analytics Workspace (LAW) to an Azure Data Explorer (ADX) Database (DB) via Azure Event Hubs <br />

# Resources:
1. [Advanced Hunting for M365 Defender with ADX](https://koosg.medium.com/unlimited-advanced-hunting-for-microsoft-365-defender-with-azure-data-explorer-646b08307b75) 
2. [Microsoft Documentation - Azure Data Explorer](https://learn.microsoft.com/en-us/azure/data-explorer/)
3. [Microsoft Documentation - Log Analyrics Data Export to ADX via Event Hubs](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal)
4. [Works Cited - LinkedIn Source](https://www.linkedin.com/pulse/howto-configure-azure-sentinel-data-export-long-term-storage-lauren/)
5. [Tech Community - Export LAW tables to ADX by Javier Soriano](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/using-azure-data-explorer-for-long-term-retention-of-microsoft/ba-p/1883947)
6. [Manual Table Export](https://github.com/javiersoriano/sentinel-scripts/blob/main/ADX/Create-TableInADX.ps1)
7. [Programmatic | Automated Table Export](https://github.com/Azure/Azure-Sentinel/tree/master/Tools/AzureDataExplorer)
    * CAUTION: See my repo for an updated (24 JUN 2023) [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json)
    * CHECK FOR UPDATED TABLES [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)
  

# Instructions:
1. Register the Microsoft.insights resource provider (if not already done so).
   * Check with the following PowerShell command: (use Azure Cloud Shell if required) <br />
   
   ```console
    Get-AzResourceProvider | ? {$_.ProviderNamespace -eq 'microsoft.insights'}
   ```

   ![Image 6-24-23 at 10 55 PM](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/af00c1d3-a7c6-40e1-8409-256cfc953ed4)

2. Create an [Azure Data Explorer (ADX) Cluster and Database](https://learn.microsoft.com/en-us/azure/data-explorer/create-cluster-database-portal) where your exported tables (from Log Analytics) will reside.
3. Create an Event Hub Namespace with the appropriate Throughput Units (TU's - STD SKU is 22.00 per TU. Refer to [Event Hub pricing](https://learn.microsoft.com/en-us/azure/event-hubs/compare-tiers) for more details)
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/aa24dbc5-30f4-44fa-a040-02950ae3a9bd)

4. Identify the Log Analytics Workspace (LAW) you want to export your tables from using the 'data export' blade. <br />
   * Create and enable an export rule.
   * Select the tables you want to export to an Event Hub Namespace
   * Each LAW can only have a max of 10 "enabled" rules.
  
   ## Log Analytics Workspace -- Data Export (blade)
   * Recommend letting Azure Event Hub Namespace automatically determine the name of the Event Hub (e.g. am-[exported table name])
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/889b466d-e39e-42fb-b961-1cc37bc00309)

   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/287fd9ca-b424-49c6-ba32-a4b97dca29c8)

5. Go to the "adx_table_create" directory in the repo and copy the commands from the tables you want to create in Azure Data Explorer (ADX) <br />
   a. You can can export additional tables from Log Analytics using Javier's PowerShell script: [Create-Table-In-ADX-Manual.ps1](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/Create-Table-In-ADX-Manual.ps1)

   ## Manually export tables from Log Analytics into Kusto commands to create ADX tables.
   * Pre-req: You will need the PowerShell Azure Module installed and login (Connect-AzAccount) to your subscription via the PowerShell CLI or upload and run from the Cloud Shell.
      * Install-Module -Name Az -Scope User -Force
      * Connect-AzAccount
           * -Environment AzureUSGovernment (add this option if you're connecting to a MAG tenant/subscription)
      * .\Create-Table-In-ADX.ps1 -TableName [Log-A table] -WorkspaceId [Your WorkspaceId]
      * Copy and Paste the output from this script into your editor of choice.
      * A file with the Kusto commands needed for ADX table creation and mapping is also be created in your current directory (e.g. CommonSecurityLog_Table.txt)
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/90fb2db5-5b83-46c3-abdd-25d986bea3af)

6. Go to the Database in your ADX Cluster and ONE BY ONE, run each Kusto command to import/create the corresponding tables exported from your LAW.
    * CAUTION: See [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json) to ensure the table you're importing / creating in ADX can be exported via LAW.
    * LAW Tables can't be more than 47 characters log
    * [Custom Tables (CL's)](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal) can ONLY be exported via Data Collection Rules (HTTP REST API or Azure Monitor Agent/Extension)
    * CHECK FOR UPDATED TABLES -> [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)

   ## MANUALLY CREATE TABLES (exported from LAW) INTO ADX / Database
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/16c738a3-1154-44e8-8255-36f708ac329b)


7. Once your tables have been successfully created in your ADX database, the last step you need complete is establishing 'data connections' to EACH table you want to import via Event Hub.
   ## EVENT HUB NAMESPACE: SecurityTables-1
   * Corresponding Event Hubs (created automatically from the LAW data export rule in (step 2))
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/0939913d-0e17-4081-a7d1-36e808b811ff)


8. Data Connections within ADX Cluster / Database. <br />
   This is what connects to EACH of your Event Hubs. <br />
   The RAW Tables ingest the data that reside within the Event Hubs. <br />
   The mapping function uses the RAW table (CommonSecurityLogRaw) to map the defined columns of the actual table (CommonSecurityLog) with the following constraints: <br />
* events.Type == $TableName and the TimeGenerated value is not empty (null). <br />
   
   Once the data connections are defined and successfully created the information will flow from the specified Event Hubs into their assigned ADX DB tables.
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/04ddd907-744b-4d7d-a1cd-305518ec4ff6)

   ## ADX Database - Data Connection: Configuration | Settings
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/9a6c9a5e-ca04-4f6a-b3bf-e4f6c4f5430f)


9. Be patient, it takes about 20 - 30 minutes before data begins to flow from Log Analytics to your Event Hubs and then into your ADX Database. <br />

   **_Querying the CommonSecurityLog table via Log Analytics_** <br />
   
   ![3A3CA9C2-AFE1-453A-80DD-C1A7954C8831](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/0560e336-8818-480b-8580-d1067a391aaa)


   **_Querying the CommonSecurityLog table via Azure Data Explorer (ADX)_**
   
   ![EEA8D74E-F942-4A80-9FAB-D8C4F3DCEC81](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/c9a3b93a-1908-4084-9fcc-141879771b3b)

