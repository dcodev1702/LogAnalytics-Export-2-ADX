# Security Operations - Azure Cloud Architecture
![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/a043829b-8640-48c1-9391-e9abca8a96cc)


# Export Log Analytics tables to ADX via Event Hubs
Export tables in a Log Analytics Workspace (LAW) to an Azure Data Explorer (ADX) Database (DB) via Event Hubs <br />

# Resources:
0. [Microsoft Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal)
1. [Works Cited - LinkedIn Source](https://www.linkedin.com/pulse/howto-configure-azure-sentinel-data-export-long-term-storage-lauren/)
2. [Tech Community - Export LAW tables to ADX by Javier Soriano](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/using-azure-data-explorer-for-long-term-retention-of-microsoft/ba-p/1883947)
3. [Manual Table Export](https://github.com/javiersoriano/sentinel-scripts/blob/main/ADX/Create-TableInADX.ps1)
4. [Programmatic Table Export](https://github.com/Azure/Azure-Sentinel/tree/master/Tools/AzureDataExplorer)
    * CAUTION: See my repo for an updated (24 JUN 2023) [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json)
    * CHECK FOR UPDATED TABLES [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)
  

# Instructions:
0. Create an Azure Data Explorer (ADX) Cluster and Database where your tables will reside.
1. Create an Event Hub Namespace with the appropriate Throughput Units (TU's - STD SKU is 22.00 per TU. Refer to documentation for more details)
2. Identify the Log Analytics Workspace (LAW) you want to export your tables from use the 'data export' blade.
   a. Create and enable an export rule.
      1. Each LAW can only have a max of 10 enabled rules.
  
   ## Log Analytics Workspace -- Data Export (blade)
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/287fd9ca-b424-49c6-ba32-a4b97dca29c8)

3. Go to the "Kusto Table Create" directory and copy the commands from the tables you want to create in Azure Data Explorer (ADX)
   a. You can can export additional tables from Log Analytics using Javier's PowerShell script (Create-Table-In-ADX-Manual.ps1)

   ## Manually export tables from Log Analytics to Kusto commands to create ADX tables.
   * Pre-req: You will need the PowerShell Azure Module installed
      * Install-Module -Name Az -Scope User -Force
      * .\Create-Table-In-ADX.ps1 -TableName <<Log-A table>> -WorkspaceId <<Your WorkspaceId>>
      * Copy and Paste the output from this script into notepad
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/c7d54452-1dc9-49ea-be3a-edd489275a74)


5. Go to the Database in your ADX Cluster and ONE BY ONE, run each Kusto command to import/create the corresponding tables exported from your LAW.
    * CAUTION: See [ADXSupportedTables.json](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/blob/main/ADXSupportedTables.json) to ensure the table you're importing / creating in ADX can be exported via LAW.
    * LAW Tables can't be more than 47 characters log
    * [Custom Tables (CL's)](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal) can ONLY be exported via Data Collection Rules (HTTP REST API or Azure Monitor Agent/Extension)
    * CHECK FOR UPDATED TABLES -> [SupportedADXTables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)

   ## CREATE TABLES (exported from LAW) INTO ADX / Database
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/2c2ecd33-0a1b-45c0-b662-6ba386663c5b)

   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/68ec1c3a-e4e4-449e-bf89-9d17b46d2dd9)


7. Once your tables have been successfully created in your ADX database, you need to establish 'data connections' to EACH table you want to import via Event Hub.
   ## EVENT HUB NAMESPACE: SecurityTables-1
      * Corresponding Event Hubs (created automatically from the LAW data export rule)
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/e1680592-085a-480c-a30b-667748a4db1e)

8. Data Connections within ADX Cluster / Database.  This is what connects to EACH of your Event Hubs and the RAW Tables ingest your data that resides within the Event Hubs. Each table
   you export from Log Analytics to an Event Hub, will require a data connection from your ADX database, so the information can flow.
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/04ddd907-744b-4d7d-a1cd-305518ec4ff6)

9. Be patient, it takes about 20 - 30 minutes before data begins to flow from Log Analytics to your Event Hubs and then into your ADX Database.
   ![image](https://github.com/dcodev1702/LogAnalytics-Export-2-ADX/assets/32214072/19fe71bd-5b2c-4fe6-a0f6-d682e730c112)


