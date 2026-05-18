using './main.bicep'

// General Parameters
// Single-region only. Original generated value had ['uksouth', ''] which broke
// the bicep's per-location RG loop (BadRequest: location required) and added
// a phantom dual-region hub. See AVM migration runbook 2026-05-14 hub-config
// incident + CLAUDE.md pattern L52 (candidate).
param parLocations = [
  'uksouth'
]
param parGlobalResourceLock = {
  name: 'GlobalResourceLock'
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Accelerator.'
}
param parTags = {
  environment: 'prod'
  workload: 'platform-connectivity'
  managedBy: 'bicep-accelerator'
  repo: 'codelooks-com/azure-mgmt'
}
param parEnableTelemetry = true

// Resource Group Parameters
param parHubNetworkingResourceGroupNamePrefix = 'rg-codelooks-conn'
param parDnsResourceGroupNamePrefix = 'rg-codelooks-dns'
param parDnsPrivateResolverResourceGroupNamePrefix = 'rg-codelooks-dnspr'

// Hub Networking Parameters — single-hub, cost-disciplined config matching the
// codelooks ALZ design spec (docs/superpowers/specs/2026-04-10-codelooks-alz-design.md).
// Differences from accelerator default (which had everything on):
//  - addressPrefixes 10.0.0.0/22 → 10.96.0.0/22 (matches Phase 1c hub)
//  - Azure Firewall off (~£1000/mo savings; we deny-by-policy + NSG)
//  - Bastion off (no need; access via VPN tunnel from OPNsense)
//  - DDoS off (£2k/mo plan; not justified)
//  - ExpressRoute Gateway off (no ExR circuit)
//  - VPN Gateway SKU Basic (~£23/mo; matches Phase 1c, only SKU we can afford)
//  - VPN mode singleInstance (Basic doesn't support BGP/active-active)
//  - Peering off (single hub; no second region)
//  - DNS Private Resolver on (matches Phase 1c corp-LZ validation test pattern L30)
param hubNetworks = [
  {
    name: 'vnet-alz-${parLocations[0]}'
    location: parLocations[0]
    addressPrefixes: [
      '10.96.0.0/22'
    ]
    deployPeering: false
    dnsServers: []
    peeringSettings: []
    subnets: [
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.96.0.0/27'
      }
      {
        name: 'snet-shared-services-01'
        addressPrefix: '10.96.1.0/25'
      }
      {
        name: 'snet-pe-hub-01'
        addressPrefix: '10.96.1.128/25'
      }
    ]
    azureFirewallSettings: {
      deployAzureFirewall: false
    }
    bastionHostSettings: {
      deployBastion: false
    }
    // VPN Gateway: AVM module pins the SKU type to VpnGw{1-5}AZ — Basic SKU
    // (the only one within the £130/mo budget) is rejected at bicep-build time.
    // We disable it via deployVpnGateway:false and deploy a Basic VPN Gateway
    // via custom bicep in codelooks-com/azure-landing-zone. The schema still
    // requires skuName/vpnMode etc (BCP035) — placeholder values below are
    // ignored because deployVpnGateway:false. See AVM migration runbook
    // 2026-05-14 hub-config incident + CLAUDE.md pattern L52.
    vpnGatewaySettings: {
      deployVpnGateway: false
      name: 'vgw-alz-${parLocations[0]}-PLACEHOLDER-NOT-DEPLOYED'
      skuName: 'VpnGw1AZ'
      vpnMode: 'activePassiveNoBgp'
      vpnType: 'RouteBased'
      asn: 65515
    }
    expressRouteGatewaySettings: {
      deployExpressRouteGateway: false
    }
    privateDnsSettings: {
      deployPrivateDnsZones: true
      // DNS Private Resolver disabled — corp validation test torn down 2026-04-17.
      // Re-enable when Phase 2 needs on-prem name resolution into Azure (see
      // codelooks-com/azure-landing-zone snag #15 closure).
      deployDnsPrivateResolver: false
      privateDnsResolverName: 'dnspr-alz-${parLocations[0]}'
      privateDnsZones: []
    }
    ddosProtectionPlanSettings: {
      deployDdosProtectionPlan: false
    }
  }
]
