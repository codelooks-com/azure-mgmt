using './main.bicep'

// General Parameters
param parLocations = [
  'uksouth'
  ''
]
param parEnableTelemetry = true

param landingZonesConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'landingzones'
  managementGroupParentId: 'codelooks'
  managementGroupIntermediateRootName: 'codelooks'
  managementGroupDisplayName: 'Landing Zones'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: []
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

// Only specify the parameters you want to override - others will use defaults from JSON files
param parPolicyAssignmentParameterOverrides = {
  // Enable-DDoS-VNET: forced to Disabled. Defaults to effect=Modify which would
  // inject a `ddosProtectionPlan.id` reference to a never-created DDoS plan
  // (we run with `deployDdosProtectionPlan: false` for cost — see pattern L54).
  // The ddosPlan ref below is kept for "turn DDoS back on" optionality but is
  // unused when effect is Disabled.
  'Enable-DDoS-VNET': {
    parameters: {
      effect: {
        value: 'Disabled'
      }
      ddosPlan: {
        value: '/subscriptions/d744499a-fb71-4880-9d2e-853fec43ac29/resourceGroups/rg-codelooks-conn-${parLocations[0]}/providers/Microsoft.Network/ddosProtectionPlans/ddos-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-AzSqlDb-Auditing': {
    parameters: {
      logAnalyticsWorkspaceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.OperationalInsights/workspaces/law-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-vmArc-ChangeTrack': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-ct-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-VM-ChangeTrack': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-ct-alz-${parLocations[0]}'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-VMSS-ChangeTrack': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-ct-alz-${parLocations[0]}'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-vmHybr-Monitoring': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-vmi-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-VM-Monitoring': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-vmi-alz-${parLocations[0]}'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-VMSS-Monitoring': {
    parameters: {
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-vmi-alz-${parLocations[0]}'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-${parLocations[0]}'
      }
    }
  }
  'Deploy-MDFC-DefSQL-AMA': {
    parameters: {
      userWorkspaceResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.OperationalInsights/workspaces/law-alz-${parLocations[0]}'
      }
      dcrResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.Insights/dataCollectionRules/dcr-mdfcsql-alz-${parLocations[0]}'
      }
      userAssignedIdentityResourceId: {
        value: '/subscriptions/9a89e47c-d57b-459f-8588-ca605dc7150b/resourceGroups/rg-codelooks-logging-${parLocations[0]}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-alz-${parLocations[0]}'
      }
    }
  }
}
