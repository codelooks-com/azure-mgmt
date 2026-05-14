using './main.bicep'

// General Parameters
param parLocations = [
  'uksouth'
  ''
]
param parEnableTelemetry = true

param platformConnectivityConfig = {
  createOrUpdateManagementGroup: true
  managementGroupName: 'connectivity'
  managementGroupParentId: 'platform'
  managementGroupIntermediateRootName: 'codelooks'
  managementGroupDisplayName: 'Connectivity'
  managementGroupDoNotEnforcePolicyAssignments: []
  managementGroupExcludedPolicyAssignments: []
  customerRbacRoleDefs: []
  customerRbacRoleAssignments: []
  customerPolicyDefs: []
  customerPolicySetDefs: []
  customerPolicyAssignments: []
  subscriptionsToPlaceInManagementGroup: ['d744499a-fb71-4880-9d2e-853fec43ac29']
  waitForConsistencyCounterBeforeCustomPolicyDefinitions: 10
  waitForConsistencyCounterBeforeCustomPolicySetDefinitions: 10
  waitForConsistencyCounterBeforeCustomRoleDefinitions: 10
  waitForConsistencyCounterBeforePolicyAssignments: 40
  waitForConsistencyCounterBeforeRoleAssignments: 40
  waitForConsistencyCounterBeforeSubPlacement: 10
}

// Only specify the parameters you want to override - others will use defaults from JSON files
//
// `Enable-DDoS-VNET` (built-in policy "Virtual networks should be protected by
// Azure DDoS Network Protection") defaults to effect=Modify, which adds a
// `ddosProtectionPlan.id` reference to every VNet creation request at this
// MG's scope. The default ddosPlan parameter (set just below) points at the
// hub-local DDoS plan that the hub-networking bicep WOULD create if
// `deployDdosProtectionPlan: true`.
//
// Our codelooks hub has `deployDdosProtectionPlan: false` (£2k/mo is outside
// the £130/mo budget — see pattern L54). The plan never gets created, so the
// Modify effect injects a reference to a non-existent resource ID and ARM
// rejects EVERY VNet create with `Resource ddos-alz-${location} not found`.
//
// Fix: explicitly override `effect: Disabled`. The ddosPlan value is kept for
// reference (and to make the "turn it back on" path obvious) but is unused
// when effect is Disabled.
//
// Customer rollout note: for cost-constrained customers, prefer the Terraform
// SMB starter scenario which disables DDoS Network Protection out of the box.
// On Bicep, you MUST override this policy whenever deployDdosProtectionPlan is
// false, or you'll hit this same blocker on the first VNet create.
param parPolicyAssignmentParameterOverrides = {
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
}
