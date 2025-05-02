param environment string = 'staging' // Allowed values: 'release', 'staging', 'prod'
param location string = 'eastasia'

var workspace_name = 'tigergrades-${environment}'
var sites_tigergrades_name = '${environment}.az.tigergrades.com'
var components_tigergrades_name = 'tigergrades-${environment}'
var namespaces_tiger_grades_bus_name = 'tiger-grades-bus-${environment}'
var serverfarms_ASP_tigergradesgroup_98ad_name = 'ASP-tigergradesgroup-98ad-${environment}'
var storageAccounts_tigergradesgroup_name = 'tigergrades${environment}'
var schedulers_tiger_grades_scheduler_name = 'tiger-grades-scheduler-${environment}'
var actionGroups_Application_Insights_Smart_Detection_name = 'Application Insights Smart Detection ${environment}'
var userAssignedIdentities_tigergrades_id_8bcc_name = 'tigergrades-id-8bcc-${environment}'

resource workspace_resource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspace_name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource schedulers_tiger_grades_scheduler_name_resource 'Microsoft.DurableTask/schedulers@2024-10-01-preview' = {
  name: schedulers_tiger_grades_scheduler_name
  location: location
  properties: {
    ipAllowlist: [
      '0.0.0.0/0'
    ]
    sku: {
      name: 'Dedicated'
      capacity: 1
    }
  }
}

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2024-10-01-preview' = {
  name: actionGroups_Application_Insights_Smart_Detection_name
  location: 'Global'
  properties: {
    groupShortName: 'SmartDetect'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

resource components_tigergrades_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_tigergrades_name
  location: 'eastasia'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    WorkspaceResourceId: workspace_resource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableLocalAuth: false
  }
}

resource userAssignedIdentities_tigergrades_id_8bcc_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: userAssignedIdentities_tigergrades_id_8bcc_name
  location: 'eastasia'
}

resource namespaces_tiger_grades_bus_name_resource 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: namespaces_tiger_grades_bus_name
  location: 'eastasia'
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource storageAccounts_tigergradesgroup_name_resource 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccounts_tigergradesgroup_name
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource serverfarms_ASP_tigergradesgroup_98ad_name_resource 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: serverfarms_ASP_tigergradesgroup_98ad_name
  location: 'eastasia'
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
    size: 'FC1'
    family: 'FC'
    capacity: 3
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 3
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 3
    targetWorkerSizeId: 0
    zoneRedundant: true
  }
}

resource schedulers_tiger_grades_scheduler_name_ClassRegistrationHub 'Microsoft.DurableTask/schedulers/taskHubs@2024-10-01-preview' = {
  parent: schedulers_tiger_grades_scheduler_name_resource
  name: 'ClassRegistrationHub'
  properties: {}
}

resource components_tigergrades_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'degradationindependencyduration'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'degradationinserverresponsetime'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'digestMailConfiguration'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_canaryextension'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_memoryleakextension'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_securityextensionspackage'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'extension_traceseveritydetector'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'longdependencyduration'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    enabled: false
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'slowpageloadtime'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource components_tigergrades_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_tigergrades_name_resource
  name: 'slowserverresponsetime'
  location: 'eastasia'
  properties: {
    ruleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    enabled: true
    sendEmailsToSubscriptionOwners: true
    customEmails: []
  }
}

resource userAssignedIdentities_tigergrades_id_8bcc_name_spenpo_freelance_tiger_functions_a318 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  parent: userAssignedIdentities_tigergrades_id_8bcc_name_resource
  name: 'spenpo-freelance-tiger-functions-a318'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:spenpo-freelance/tiger-functions:ref:refs/heads/main'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

resource namespaces_tiger_grades_bus_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2024-01-01' = {
  parent: namespaces_tiger_grades_bus_name_resource
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_tiger_grades_bus_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2024-01-01' = {
  parent: namespaces_tiger_grades_bus_name_resource
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource namespaces_tiger_grades_bus_name_invite_teacher 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: namespaces_tiger_grades_bus_name_resource
  name: 'invite-teacher'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: true
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource namespaces_tiger_grades_bus_name_monitor_copy_status 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: namespaces_tiger_grades_bus_name_resource
  name: 'monitor-copy-status'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: true
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource storageAccounts_tigergradesgroup_name_default 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_tigergradesgroup_name_default 'Microsoft.Storage/storageAccounts/fileServices@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_resource
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_tigergradesgroup_name_default 'Microsoft.Storage/storageAccounts/queueServices@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_tigergradesgroup_name_default 'Microsoft.Storage/storageAccounts/tableServices@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_tigergrades_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'ftp'
  properties: {
    allow: true
  }
}

resource sites_tigergrades_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'scm'
  properties: {
    allow: true
  }
}

resource sites_tigergrades_name_web 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$tigergrades'
    scmType: 'GitHubAction'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 16855
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 100
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_tigergrades_name_copy_drive_item 'Microsoft.Web/sites/functions@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'copy-drive-item'
  properties: {
    script_root_path_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/copy-drive-item/'
    script_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/copy-drive-item/index.js'
    config_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/copy-drive-item/function.json'
    test_data_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/tmp/FunctionsData/copy-drive-item.dat'
    href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/functions/copy-drive-item'
    config: {
      scriptFile: 'index.js'
      bindings: [
        {
          authLevel: 'function'
          type: 'httpTrigger'
          direction: 'in'
          name: 'req'
          methods: [
            'post'
          ]
        }
        {
          type: 'http'
          direction: 'out'
          name: '$return'
        }
      ]
    }
    invoke_url_template: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/api/copy-drive-item'
    language: 'node'
    isDisabled: false
  }
}

resource sites_tigergrades_name_create_folder 'Microsoft.Web/sites/functions@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'create-folder'
  properties: {
    script_root_path_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/create-folder/'
    script_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/create-folder/index.js'
    config_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/create-folder/function.json'
    test_data_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/tmp/FunctionsData/create-folder.dat'
    href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/functions/create-folder'
    config: {
      scriptFile: 'index.js'
      bindings: [
        {
          authLevel: 'function'
          type: 'httpTrigger'
          direction: 'in'
          name: 'req'
          methods: [
            'post'
          ]
        }
        {
          type: 'http'
          direction: 'out'
          name: '$return'
        }
      ]
    }
    invoke_url_template: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/api/create-folder'
    language: 'node'
    isDisabled: false
  }
}

resource sites_tigergrades_name_invite_edit 'Microsoft.Web/sites/functions@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'invite-edit'
  properties: {
    script_root_path_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/invite-edit/'
    script_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/invite-edit/index.js'
    config_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/invite-edit/function.json'
    test_data_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/tmp/FunctionsData/invite-edit.dat'
    href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/functions/invite-edit'
    config: {
      scriptFile: 'index.js'
      bindings: [
        {
          authLevel: 'function'
          type: 'httpTrigger'
          direction: 'in'
          name: 'req'
          methods: [
            'post'
          ]
        }
        {
          type: 'http'
          direction: 'out'
          name: '$return'
        }
      ]
    }
    invoke_url_template: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/api/invite-edit'
    language: 'node'
    isDisabled: false
  }
}

resource sites_tigergrades_name_subscribe_webhook_notifications 'Microsoft.Web/sites/functions@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: 'subscribe-webhook-notifications'
  properties: {
    script_root_path_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/subscribe-webhook-notifications/'
    script_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/subscribe-webhook-notifications/index.js'
    config_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/home/site/wwwroot/subscribe-webhook-notifications/function.json'
    test_data_href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/vfs/tmp/FunctionsData/subscribe-webhook-notifications.dat'
    href: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/admin/functions/subscribe-webhook-notifications'
    config: {
      scriptFile: 'index.js'
      bindings: [
        {
          authLevel: 'function'
          type: 'httpTrigger'
          direction: 'in'
          name: 'req'
          methods: [
            'post'
          ]
        }
        {
          type: 'http'
          direction: 'out'
          name: '$return'
        }
      ]
    }
    invoke_url_template: 'https://tigergrades-erbmcedccbgrfybr.eastasia-01.azurewebsites.net/api/subscribe-webhook-notifications'
    language: 'node'
    isDisabled: false
  }
}

resource sites_tigergrades_name_hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = {
  parent: sites_tigergrades_name_resource
  name: sites_tigergrades_name
  properties: {
    siteName: sites_tigergrades_name
    hostNameType: 'Verified'
  }
}

resource storageAccounts_tigergradesgroup_name_default_app_package_tigergrades_0299027 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_default
  name: 'app-package-tigergrades-0299027'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource storageAccounts_tigergradesgroup_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource storageAccounts_tigergradesgroup_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_tigergradesgroup_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource storageAccounts_tigergradesgroup_name_default_AzureFunctionsDiagnosticEvents202504 'Microsoft.Storage/storageAccounts/tableServices/tables@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_tigergradesgroup_name_default
  name: 'AzureFunctionsDiagnosticEvents202504'
  properties: {}
}

resource sites_tigergrades_name_resource 'Microsoft.Web/sites@2024-04-01' = {
  name: sites_tigergrades_name
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/6c17570e-c7c0-49d1-a38d-ae287afc2f84/resourceGroups/${resourceGroup().name}/providers/microsoft.insights/components/tigergrades'
    'hidden-link: /app-insights-instrumentation-key': '78215469-bab5-42bc-ba42-aca9b1621794'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=78215469-bab5-42bc-ba42-aca9b1621794;IngestionEndpoint=https://eastasia-0.in.applicationinsights.azure.com/;LiveEndpoint=https://eastasia.livediagnostics.monitor.azure.com/;ApplicationId=d562ec01-93a3-4c7c-a355-d84038a12836'
  }
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: sites_tigergrades_name
        sslState: 'Disabled'
        hostType: 'Standard'
      }
    ]
    serverFarmId: serverfarms_ASP_tigergradesgroup_98ad_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      http20Enabled: false
      functionAppScaleLimit: 100
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_tigergradesgroup_name};AccountKey=${storageAccounts_tigergradesgroup_name_resource.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
      ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobcontainer'
          value: 'https://${storageAccounts_tigergradesgroup_name}.blob.core.windows.net/app-package-tigergrades-${environment}-0299027'
          authentication: {
            type: 'storageaccountconnectionstring'
            storageAccountConnectionStringName: 'AzureWebJobsStorage'
          }
        }
      }
      runtime: {
        name: 'node'
        version: '20'
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: '0BA30D6E0DA06F29DE5CF1A72AC9CCE628F48C6713152AE889F66123BE13720D'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
  }
}
