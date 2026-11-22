[Implementation Plan](https://mnscorp.sharepoint.com/sites/dnthub/SitePages/Change-Enablement.aspx?csf=1&web=1&e=77OTNB&CID=6c0574b8-599f-4f95-93c9-f38c01cefa8f)

(Click Link to Obtain Latest Version of Template V3 – 14/10/26)

**MCX DEA Part 2.2 - ACI Activation: switch-over – Implementation Plan**

Workstream: SPExit  
Change Coordinator/Author: A MacPhail / P Donlon

Contents

1

1.1 References & Associated Documents [2](#references-associated-documents)

1.2 Business Contacts [2](#business-contacts)

2 Implementation Plan Requirements & Overview [3](#_Toc239775764)

2.1 **Title Of Change** [3](#title-of-change)

2.2 **Purpose** [3](#purpose)

2.3 **Business Justification Of Change** [3](#business-justification-of-change)

2.4 **Potential Impact of Change** [3](#potential-impact-of-change)

2.5 **Likelihood of Change Failure** [3](#likelihood-of-change-failure)

2.6 **Requirements & Dependencies** [3](#requirements-dependencies)

2.7 **Flow Topology / Technical Schematic** [3](#_Toc239775771)

2.8 **Resource requirements** [3](#resource-requirements)

3 Implementation Summary [4](#implementation-summary)

3.1 Change Window [4](#change-window)

3.2 Outage Timings (if any) [4](#outage-timings-if-any)

3.3 Execution Summary & Communication Plan [4](#execution-summary-communication-plan)

4 Detailed Implementation Plan [5](#detailed-implementation-plan)

4.1 **Pre-Requisites, Testing & Communication** [5](#pre-requisites-testing-communication)

4.2 **Implementation** [5](#_Toc239775779)

5 Post Change Validation Testing [7](#post-change-validation-testing)

6 Rollback [8](#rollback)

7 Close Down [9](#close-down)

Document History

|                                    |                                    |                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |                                  |
|------------------------------------|------------------------------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| **Document Created/Amended By**    | **Date**                           | **Reviewed by** | **Changes**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | **Version**                      |
|                                    |                                    |                 | Split from Part 2 V1.2:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | 2.2.8                            |
|                                    |                                    |                 | Final for Approval                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | 1.0                              |
| P Donlon | 18/11/26 |                 | Appendix A is one list of 62 bridge domains; step 2.4 attaches PROD_3022_BD, PROD_3046_BD, PROD_3056_BD, PROD_3083_BD and PROD_3096_BD; counts updated; changes highlighted in yellow                                                                                                                                                                                                                                                                                                                                                                                                                                                             | 2.2.11 |
| P Donlon                           | 19/11/26                           |                 | Change 2.1 ended at step 2.2 (NDO circular template dependency at its step 2.3): 2.4 attaches all 62 bridge domains; P1, P2 and P5 updated to the 19/11 end state; GCP-OUT-V3 and the NTP /32s; Azure map decision; PROD_MIG_L3OUT host-route checks moved to OSPF; new step 2.3 moves MCX_L3OUT and UXB_MCX_L3OUT into the stretched template as PROD_MCX_L3OUT, with rollback row 4; 2.4 split between NDO and the APIC (bridge domains deployed by NDO at one site only), from NDO and APIC data; enforceRtctrl check after each NDO deploy; P3 check 5 (route map); 3046/3083 not migrated; timings updated. Highlights: orange (2.2.12), green (2.2.13), blue (2.2.14) | 2.2.14                           |
| J Clowes / P Donlon | 22/11/26 | | Other-site copies of rows 27 to 61 are NDO shadow objects: 2.4 attaches each bridge domain at the site that owns it and no longer edits the copies on the APIC; new step 2.5 builds per-site reject policies on the EX4650s and 3.4 applies them, so a one-site subnet is only accepted from its own site; host routes (3.7, P9, rollback row 3) taken out of this change; counts and timings updated; 3.3 route map built on each APIC (NDO doesn't offer a route map on an L3Out in an application template, P3 check 5 on 20/11/2026), with Potential Impact, outage timings, 3.4 and rollback row 1 to match; P8 uses real flows from the mcx_lan and mcx_s2s policies | 2.2.16 |

## References & Associated Documents

|                                                                                                                       |            |           |
|-----------------------------------------------------------------------------------------------------------------------|------------|-----------|
| **Document**                                                                                                          | **Date**   | **Owner** |
| CRQ000000263806 MCX DEA Part 1 Routing (complete 05/11/2026)                                                          | 05/11/2026 | P Donlon  |
| CRQ MCX DEA update - V1.1 (LD8 to Azure / GCP via LD5, vlan 729)                                                      | 11/11/2026 | P Donlon  |
| MCX_DEA_Part2_V2.1.10 (change 2.1: Phase 1 and steps 2.1 and 2.2, complete 19/11/2026; its step 2.3 is step 2.4 here) | 19/11/2026 | P Donlon  |

## Business Contacts

| Business Owner |     | Business Sponsor |     |
|----------------|-----|------------------|-----|

# Implementation Plan Requirements & Overview

## **Title Of Change** 

MCX DEA Part 2.2 - ACI Activation: switch-over

## **Purpose** 

**What**

- This is the switch-over half of MCX DEA Part 2. Change 2.1 (19/11/2026) bound the FortiGate fabric route maps and put the hold on the EX4650 fabric sessions (import and export DENY-ALL). Its bridge domain attachment (2.3) was stopped by an NDO circular template dependency and rolled back without a deploy, so no bridge domain is attached yet. This change first moves the MCX L3Outs out of the site-local templates into the stretched template as PROD_MCX_L3OUT (2.3, no impact), which removes the dependency. It then attaches the 62 PROD_TNT bridge domains in Appendix A to PROD_MCX_L3OUT at SWI and UXB (2.4, no impact): their routes are held at the EX4650s and nothing is sent to the fabrics until 3.0.

- This change sends the MCX, Azure, GCP and GIST VPN ranges from the EX4650s to the fabrics (3.0, no impact), then does the switch-over: ACI imports them through the MCX L3Outs (LD5 at local preference 200, LD8 at 100) and the EX4650s release the bridge domain routes, so MCX, Azure and GCP send their traffic for the bridge domains via MCX. Host routes aren't turned on in this change.

- The default route and everything outside the MCX ranges don't change. The default route is OSPF at both sites today (SWI via 10.158.240.193 / .194, UXB via 10.157.240.178, checked 19/11/2026). Open item: confirm the UXB default comes from PROD_MIG_L3OUT and not the leak from tenant common.

**Why**

- Part 2 is split in two so the build (change 2.1, no impact) and the switch-over (this change, short outage) run in separate windows.

- After this change the migrated bridge domains reach MCX, Azure, GCP and the GIST VPN over the DEA links in both directions, with LD5 as primary and LD8 as DR.

## **Business Justification Of Change** 

- Why: the migrated bridge domains need a path to MCX, Azure, GCP and the GIST VPN over the DEA links.

- Benefit: LD5 becomes the primary path and LD8 the DR path for the migrated bridge domains, as set out in the DEA design.

- If not done: the bridge domains stay on their existing path, and the change 2.1 build stays in place unused (no bridge domain attached, EX4650 hold in place).

## **Potential Impact of Change**

- 2.3 (MCX L3Outs moved to the stretched template): no traffic impact. The four EX4650 fabric sessions and their BFD sessions are down from the 2.3.1 deploy until 2.3.3 and 2.3.4 are done (about an hour). Nothing is advertised or received on them (the hold from change 2.1), so no route changes anywhere. Expect BGP and BFD alarms for those four sessions. Monitoring that uses the old L3Out names (MCX_L3OUT, UXB_MCX_L3OUT) needs pointing at PROD_MCX_L3OUT.

- 2.4 (bridge domain attachment): no impact. The EX4650 hold from change 2.1 (import and export DENY-ALL) is in place, so the bridge domain subnets stay hidden on the EX4650s and nothing is sent to the fabrics.

- 3.0 (EX4650 export to the fabrics): no impact. Import route control is enforced on the MCX L3Outs with nothing permitted until 3.3, so ACI receives the MCX routes but installs none of them.

- 3.1 and 3.2 are each one NDO deploy for both sites. After 2.3 there is one L3Out and one external EPG in the stretched template, so the contract and the external subnets go to SWI and UXB together. The contract and subnets on PROD_MCX_L3OUT_EXT_EPG are the same at both sites. The route map (3.3) is created on each APIC, SWI then UXB straight after: NDO doesn't offer a route map on an L3Out in an application template (P3 check 5, 20/11/2026).

- Outage: about 2 to 5 minutes, starting about 07:25 into the change window. It runs from the 3.3 submit on APIC SWI until the 3.4 EX4650 commits have converged.

- During the outage, traffic between the migrated bridge domains and MCX, Azure, GCP and the GIST VPN can go out via PROD_MCX_L3OUT and come back via Cloud Connect, and the stateful firewalls drop it.

- The 57 bridge domains with unicast routing on are all affected for that window. The 5 with unicast routing off (Appendix A) keep their current gateway and path.

- Sessions open at the switch-over between the 57 routed bridge domains and MCX, Azure, GCP or the GIST VPN are reset, because from 3.4 they pass through the MCX FortiGates, which have no session for them. Applications reconnect on their own or the apps team restarts them (V5).

- After 3.4 both directions use MCX: outbound from the bridge domains via PROD_MCX_L3OUT (LD5 at local preference 200, LD8 at 100) and inbound from MCX, Azure and GCP via the EX4650s.

- Bridge domains in PROD_VRF that have a subnet but aren't in Appendix A lose MCX, Azure, GCP and GIST VPN access from 3.3. These are UXB_PROD_1584_BD (out of scope by decision P Donlon 30/10/2026) and the others listed as not in scope under Appendix A. P6 lists them on the day.

- The reason: ACI imports the MCX routes for the whole of PROD_VRF, so their traffic to those ranges goes out via PROD_MCX_L3OUT. MCX doesn't learn their subnets, so the replies come back via Cloud Connect and the stateful firewalls drop them.

- Decision needed before the change: accept this, or add them to the scope.

- Classification: 3.2 puts the 30 MCX-TO-ACI prefixes in PROD_MCX_L3OUT_EXT_EPG for the whole of PROD_VRF. From 3.3, traffic between any EPG in PROD_VRF and those prefixes is checked against the contracts of PROD_MCX_L3OUT_EXT_EPG (ALLOW_ALL_CNTRCT only). P6 confirms PROD_MIG_L3OUT_EXT_EPG has no other contract today; if it has, stop.

- Host routes: not in this change. Advertise Host Routes stays off on every bridge domain (decision J Clowes, 22/11/2026) and is left for a later change. Without it, traffic from MCX for a stretched bridge domain can arrive at either site, and the fabric carries it to the site the endpoint is in.

- Bridge domains that live at one site (rows 27 to 61): the other site holds an NDO shadow copy with the same subnet and no endpoints, and can advertise that subnet to the EX4650s as well. From 3.4 the EX4650s reject each one-site subnet when it comes from the site that doesn't own it (policies built in 2.5), so MCX only sends that traffic to the site with the endpoints.

- Decision needed before the change: AZURE-OUT-V4 (MCX-LD5-FGT2600-01) and AZURE-OUT-V2 (MCX-LD8-FGT2600-01) rule 2 permits fabric subnets by AS path ending 64631 or 64633, so it also passes fabric subnets learned back via Vodafone (path 64512 4445 ... 64633), as GCP-OUT-V2 did until GCP-OUT-V3 replaced it on 19/11/2026. Azure gets these today (Azure totals unchanged on 19/11/2026). After 3.4 the copies from the EX4650s are preferred; the Vodafone copies are only used if the EX4650 fabric sessions are down. Accept this, or tighten both Azure maps the same way as GCP-OUT-V3.

- UXB keeps the CC routes leaked from tenant common alongside PROD_MCX_L3OUT for now (decision J Clowes, 11/11/2026). The leak is tidied up in a later change. P3 checks that tenant common doesn't classify the MCX ranges into the leak contract.

- While LD5 is up, UXB uses MCX: the LD5 routes are at local preference 200 against 100 for the leaked routes. If LD5 is lost, the LD8 routes at 100 tie with the leak and either can be used, which can make traffic asymmetric.

- Worst case: traffic is dropped or takes an asymmetric path. Fast stop (rollback row 1): import and export DENY-ALL on the EX4650 fabric sessions, then delete the default-import route map on PROD_MCX_L3OUT on both APICs. Both directions go back to Cloud Connect, which is the state after 2.4 (bridge domains attached, routes held at the EX4650s).

## **Likelihood of Change Failure**

- Change 2.1 is complete to the end of step 2.2 and its end state is checked first (P1, P2): FortiGate maps bound, nothing sent to or accepted from the fabrics, no bridge domain attached. 2.4 attaches the bridge domains in batches with the no-impact check after each, while the hold is in place. 3.0 then sends the MCX routes to the fabrics with no impact, and is checked on the APICs before the switch-over starts.

- 2.3 is built by hand on the APICs from the values recorded in 2.3.1, and checked line by line against them in 2.3.5 before any bridge domain is attached. PROD_MIG_L3OUT is already in the stretched template and built the same way (name and VRF in NDO, node profile and interfaces on each APIC), and SWI_NONPROD_1303_BD in the SWI site-local template already uses it. The move itself hasn't been run in a lab.

- The outage is limited to the switch-over: the contract (3.1) and external subnets (3.2) are deployed and checked first with no impact, so only 3.3 starts it, and the 3.4 EX4650 commits are prepared before it.

- The NDO deployment plan is run before each deploy and must show only that step. ACI is checked to be using the MCX routes at both sites before 3.4 is committed.

- Rollback row 1 returns to the state after 2.4 (bridge domains attached, routes held at the EX4650s), which has no traffic impact.

## **Requirements & Dependencies** 

- MCX DEA Part 2 change 2.1 (V2.1.10) is complete to the end of step 2.2 and validated (19/11/2026), and nothing has changed since on the FortiGate fabric maps, the EX4650 fabric groups or the MCX L3Outs.

- The NDO circular template dependency between PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT (PROD_VRF and the stretched bridge domains) and SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT (MCX_L3OUT), found at change 2.1 step 2.3 on 19/11/2026, is fixed in this change by step 2.3: MCX_L3OUT (SWI) and UXB_MCX_L3OUT (UXB) are deleted from the site-local templates and built again as PROD_MCX_L3OUT in the stretched template, where PROD_MIG_L3OUT already is. Both site-local templates were In Sync on 19/11/2026 (P3 checks again).

- Accepted before the change: Cisco recommends against putting an L3Out in a stretched template, and a different L3Out name at each site. With one name at both sites a bridge domain can't be pointed at one site's L3Out only. PROD_MIG_L3OUT is already built this way, and PROD_MCX_L3OUT follows it.

- The BGP password for the four EX4650 fabric sessions is to hand before the window (2.3.3 and 2.3.4 type it in again on the APICs; the EX4650 side isn't changed).

- Where each bridge domain is attached (2.4), from NDO and both APICs on 19/11/2026 (ndo_pull.py and apic_pull.py): rows 1 to 26 are stretched and attached in NDO at both sites. Rows 27 to 42 are attached in NDO at SWINDON only and rows 43 to 61 at UXBRIDGE only. UXB_PROD_1700_BD (row 62) is not in NDO and is attached on APIC UXB.

- The other-site copies of rows 27 to 61 are NDO shadow objects (checked 22/11/2026: SWI_PROD_1050_BD on APIC UXB has annotation orchestrator:msc-shadow:yes). NDO owns them, so they are not edited on the APIC. NDO copies a bridge domain's L3Out association onto its shadow (the UXB shadow of SWI_PROD_1050_BD has PROD_MIG_L3OUT), and the UXB border leafs hold 10.158.50.0/24 as a pervasive route, so the other site is expected to advertise these subnets too.

- Decided 22/11/2026 (J Clowes): attach at the owning site only, and filter on the EX4650s. From 3.4 the SWI sessions reject 10.157.0.0/16 and the UXB sessions reject the SWI-owned subnets (2.5), so each one-site subnet is only accepted from the site that owns it.

- PROD_3046_BD and PROD_3083_BD were not migrated at 15:39 on 19/11/2026 (unicast routing off and no subnet on both APICs and in NDO). They must be migrated before the change, or 2.4 stops at its unicastRoute check.

- CRQ000000263806 (Part 1) and CRQ MCX DEA update V1.1 (LD8 change) are complete.

- Step numbers: this change has its own numbering, 3.0 to 3.6; Phase 1 and steps 2.1 and 2.2 are in change 2.1; 2.3 here is new (the MCX L3Out move, 2.3.1 to 2.3.5) and is not change 2.1 step 2.3; 2.4 here is change 2.1 step 2.3 (bridge domain attachment), with the 5 bridge domains added on 18/11/2026; 2.5 is new (the EX4650 reject policies that 3.4 applies). Where Part 1 refers to 7.1, that's 3.1 and 3.2 here; 7.2 is 3.3; 7.3 is 3.5 and 3.6; 6.1 (host routes) is not in this change; the export half of 6.0 is 3.0 (the hold is change 2.1 step 2.2); and Appendix B is Appendix A.

- The apps team for the bridge domain tests (V5).

- MCX-TO-ACI ranges (sent to the fabrics in 3.0, matched by the 3.3 route map and used as the 3.2 external subnets): MCX LD5 10.156.0.0/21, 10.156.8.0/21, 10.156.112.0/23, 10.156.114.0/23, 10.156.116.0/23, 10.156.118.0/23; MCX LD8 10.156.128.0/21, 10.156.136.0/21, 10.156.240.0/23, 10.156.242.0/23, 10.156.244.0/23, 10.156.246.0/23; MCX / SD-WAN 10.159.0.0/16, 10.32.0.0/16, 10.45.0.0/16; Azure 10.105.0.0/16, 10.119.0.0/16, 10.120.0.0/16, 10.126.0.0/16, 10.127.0.0/16, 10.150.0.0/16; GCP 10.108.0.0/16, 10.109.0.0/16, 10.252.0.0/22, 10.252.4.0/22, 10.252.8.0/22, 10.252.12.0/22; GIST VPN 172.16.0.0/16, 172.17.0.0/16, 172.24.0.0/16 (all orlonger).

## **Resource requirements**

- Network engineer: EX4650s, FortiGates, NDO and APIC (SWI and UXB back to back).

- The apps team for V5.

# Implementation Summary

*Detail each step of the implementation process in chronological order, Owners must be named resources. Do not put dates into this document – these should be agreed with the business owner and set accordingly when the Change is raised in Helix.*

## Change Window

- **Start Time:**

- **End Time:**

- **Duration:** 10:45 (pre-requisites 01:15 + implementation 06:50 + validation 02:10 + rollback 00:30, row 1; row 2 is the full back-out (2.4, 2.5 and change 2.1), 02:30; row 4 is the back-out of 2.3, 01:30)

> (Implementation + validation + rollback if required, excl. hyper care)

## Outage Timings (if any)

- **Start Time:** window start + 07:25 (the 3.3 submit on APIC SWI)

- **End Time:** window start + about 07:30 (step 3.4 EX4650 commits converged)

- **Duration:** about 2 to 5 minutes, at steps 3.3 and 3.4 (from the 3.3 submit on APIC SWI until the EX4650 import commits in 3.4 have converged)

## Execution Summary & Communication Plan

| # | Task Description | Day # | Start (GMT/BST) | End (GMT/BST) | Duration (hh:mm) | Owner |
|---|---|---|---|---|---|---|
|  | Pre-Requisites | 1 |  |  | 01:15 | Network Engineer |
|  | Implementation | 1 |  |  | 06:50 | Network Engineer |
|  | Post Change Validation | 1 |  |  | 02:10 | Network Engineer |
|  | Rollback | 1 |  |  | 00:30 | Network Engineer |

*Note: Put only day numbers in this plan, actual dates into the Helix Change Record*

For more complex changes, complete the following sections, detailing the steps needed to successfully complete this change.

# Detailed Implementation Plan

## **Pre-Requisites, Testing & Communication** 

(non-invasive only, no changes to operational systems in this phase)

### P1 - End state of change 2.1: EX4650s and FortiGates

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** The fabric groups on both EX4650s have export DENY-ALL and import DENY-ALL (the hold), nothing is advertised to or received from the fabric peers (no bridge domain attached yet). The Part 1 export policies that 3.0 uses (MCX-TO-ACI-LD5, MCX-TO-ACI) are there. The FortiGate Azure, GCP and Vodafone peers use the maps bound in change 2.1.

**Why:** This change starts from the state change 2.1 left. The hidden counts must be 0 here: 2.4 adds the bridge domain subnets, and 3.4 turns them active.

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
show bgp summary instance mcx_vrf | no-more
show configuration routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers | display set | no-more
show configuration routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers | display set | no-more
show configuration policy-options policy-statement MCX-TO-ACI-LD5 | no-more
show configuration policy-options community LD5-ACI | no-more
show configuration policy-options as-path FROM-LD8 | no-more
show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | count
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | count
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
show bgp summary instance mcx_vrf | no-more
show configuration routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers | display set | no-more
show configuration routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers | display set | no-more
show configuration policy-options policy-statement MCX-TO-ACI | no-more
show route advertising-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | count
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | count
```

**MCX-LD5-FGT2600-01**

```
config vdom
edit mcx_cc
show router bgp | grep -f route-map
show router route-map GCP-OUT-V3
end
```

**MCX-LD8-FGT2600-01**

```
config vdom
edit mcx_cc
show router bgp | grep -f route-map
show router route-map GCP-OUT-V3
end
```

**Expected:** 11 peers Established on each EX4650; fabric groups export DENY-ALL and import DENY-ALL; nothing advertised to the four fabric peers; MCX-TO-ACI-LD5 terms FROM-LD8, TAG, default; LD5-ACI 64635:100; FROM-LD8 ".\* 64636 .\*"; MCX-TO-ACI present on LD8; nothing received from the fabric peers, hidden count 0 (2.4 adds up to 56 from each SWI peer and 55 from each UXB peer). MCX-LD5-FGT2600-01: Vodafone peers VF-OUT-V4, Azure peers AZURE-OUT-V4, GCP peers GCP-OUT-V3. MCX-LD8-FGT2600-01: VF-OUT-V4, AZURE-OUT-V2, GCP-OUT-V3. GCP-OUT-V3 as applied on 19/11/2026 (rule 1 deny ASPATH-VF-64512 and FABRIC-RANGES).

### P2 - End state of change 2.1: ACI

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Import enforcement on MCX_L3OUT and UXB_MCX_L3OUT, no route map, no contract and no external subnet on MCX_L3OUT_EXT_EPG yet, no bridge domain attached yet, host routing off, and no MCX route installed in the fabric (Verify 5.8).

**Why:** ACI must still import nothing before 3.3. The counts are the baseline for rollback row 1.

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
moquery -c fvRsBDToOut -f 'fv.RsBDToOut.tnL3extOutName*"MCX_L3OUT"' | grep -c "^dn"
moquery -c fvBD -f 'fv.BD.hostBasedRouting=="yes"' | grep -c "^dn"
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="UXB_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
moquery -c fvRsBDToOut -f 'fv.RsBDToOut.tnL3extOutName*"MCX_L3OUT"' | grep -c "^dn"
moquery -c fvBD -f 'fv.BD.hostBasedRouting=="yes"' | grep -c "^dn"
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**Expected:** enforceRtctrl includes import; external subnet count 0; MCX L3Out bridge domain count 0 at both sites (after 2.4: 61 at SWI and 62 at UXB with the NDO shadow copies, 42 and 46 without; UXB_PROD_1700_BD is at UXB only); host routing count = the change 2.1 P5 count (unchanged; host routes stay off in this change); no route via MCX_L3OUT; the default route as at 19/11/2026: OSPF via 10.158.240.193 / .194 at SWI and via 10.157.240.178 at UXB.

### P3 - NDO drift, contract consumers and tenant common

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** Five checks in NDO. Don't change the templates before the window: 2.3, 3.1 and 3.2 are made and deployed in the window, one at a time (3.3 is on the APICs).

**1.** Run the deployment plan on PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT (the stretched bridge domains, 2.4, and PROD_MCX_L3OUT from 2.3), SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT (MCX_L3OUT, as shown by the NDO error on 19/11/2026) and UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT (UXB_MCX_L3OUT). None may be Out Of Sync (all In Sync on 19/11/2026).

**2.** The plan must not show a change to route control enforcement on either L3Out. Import was ticked on the APIC when the L3Outs were built.

**3.** In View Relationship for ALLOW_ALL_CNTRCT, check its consumers include the EPGs of the bridge domains in Appendix A.

**4.** Check tenant common has no shared-security subnet equal to or inside the 30 MCX-TO-ACI prefixes.

**5.** Done 20/11/2026 (NDO 4.4.3): PROD_MIG_L3OUT in PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT shows only Display Name, Description and VRF, with no route map option. 3.3 therefore creates default-import on each APIC, as the rest of the L3Out is built in 2.3.3 and 2.3.4. Nothing to run.

**Why:** Each step is deployed on its own, so its deployment plan must show only that step. If NDO put enforcement back to export only, ACI would accept every route the EX4650s send. A tenant common subnet on an MCX range would check UXB traffic from that range against the leak contract, or clash with 3.2. If any check fails, stop.

**APIC UXB 10.157.254.10**

```
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"tn-common"' | grep -E "^dn|^ip |^scope"
```

### P4 - Backups

*Day 1 · Duration 00:05 · Owner: Network Engineer*

**What:** Take an APIC config snapshot at SWI and UXB (Admin > Config Rollbacks > Create Snapshot) and capture the running config of both EX4650s to the session log.

**Why:** Restore point if we have to roll back the ACI or EX4650 changes.

**MCX-LD5-EX4650-INNER-01**

```
show configuration | display set | no-more
```

**MCX-LD8-EX4650-INNER-01**

```
show configuration | display set | no-more
```

### P5 - FortiGate advertised baseline

*Day 1 · Duration 00:05 · Owner: Network Engineer*

**What:** Record the advertised totals to every Azure, GCP and Vodafone peer.

**Why:** Baseline for 3.6 and V4: Azure and GCP gain the fabric subnets after 3.4, and the Vodafone totals mustn't change.

**MCX-LD5-FGT2600-01**

Neighbours - 10.156.118.114 Vodafone Cloud Connect, 10.156.118.146 Vodafone Cloud Connect, 10.156.118.122 Azure private peer, 10.156.118.126 Azure private peer, 169.254.52.89 GCP 230

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.118.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.122 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.126 advertised-routes | grep Total
get router info bgp neighbors 169.254.52.89 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.141.2.
get router info bgp neighbors 10.156.118.146 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.118.146 advertised-routes | grep 10.141.2.
end
```

**MCX-LD8-FGT2600-01**

Neighbours - 10.156.246.114 Vodafone Cloud Connect, 10.156.246.146 Vodafone Cloud Connect, 10.156.246.122 Azure private peer, 10.156.246.126 Azure private peer, 169.254.130.41 GCP 230

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.246.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.122 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.126 advertised-routes | grep Total
get router info bgp neighbors 169.254.130.41 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.141.2.
get router info bgp neighbors 10.156.246.146 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.246.146 advertised-routes | grep 10.141.2.
end
```

**Expected:** totals as at 19/11/2026 (change 2.1 post-checks): MCX-LD5-FGT2600-01 Vodafone 210, Azure 445, GCP 230 1; MCX-LD8-FGT2600-01 Vodafone 228, Azure 413, GCP 230 4. 10.96.3.70/32, 10.141.2.11/32 and 10.141.2.34/32 advertised to both Vodafone peers on both FortiGates.

### P6 - PROD_VRF: contracts on the external EPGs and bridge domains not in scope

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** List the contracts provided and consumed by PROD_MIG_L3OUT_EXT_EPG and MCX_L3OUT_EXT_EPG, and every bridge domain in PROD_VRF with a subnet.

**Why:** From 3.3 (with 3.2), traffic to the MCX ranges is checked against PROD_MCX_L3OUT_EXT_EPG (the external EPG from 2.3), which provides only ALLOW_ALL_CNTRCT, so an EPG that reaches MCX today through another contract would be dropped. Bridge domains with a subnet that aren't in Appendix A lose MCX access from 3.3 (Potential Impact).

**APIC SWI 10.158.254.10**

```
moquery -c fvRsProv -f 'fv.RsProv.dn*"PROD_MIG_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsCons -f 'fv.RsCons.dn*"PROD_MIG_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsProv -f 'fv.RsProv.dn*"MCX_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsCtx -f 'fv.RsCtx.tnFvCtxName=="PROD_VRF"' | grep "^dn"
moquery -c fvSubnet -f 'fv.Subnet.dn*"tn-PROD_TNT/BD-"' | grep -E "^dn|^ip "
```

**APIC UXB 10.157.254.10**

```
moquery -c fvRsProv -f 'fv.RsProv.dn*"PROD_MIG_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsCons -f 'fv.RsCons.dn*"PROD_MIG_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsProv -f 'fv.RsProv.dn*"MCX_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName"
moquery -c fvRsCtx -f 'fv.RsCtx.tnFvCtxName=="PROD_VRF"' | grep "^dn"
moquery -c fvSubnet -f 'fv.Subnet.dn*"tn-PROD_TNT/BD-"' | grep -E "^dn|^ip "
```

**Expected:** PROD_MIG_L3OUT_EXT_EPG provides only ALLOW_ALL_CNTRCT and consumes nothing; MCX_L3OUT_EXT_EPG provides nothing yet (3.1 adds ALLOW_ALL_CNTRCT to PROD_MCX_L3OUT_EXT_EPG, which replaces it in 2.3). Bridge domains in PROD_VRF with a subnet and not in Appendix A: only those listed under Appendix A as not in scope. Anything else: stop.

### P7 - Route map objects from Part 1

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** Check the match rules and set rule that the 3.3 route map uses, on both APICs.

**Why:** 3.3 only builds the route map from these objects. A missing prefix or community term means routes aren't imported, or aren't preferred via LD5.

**APIC SWI 10.158.254.10**

```
moquery -c rtctrlSubjP -f 'rtctrl.SubjP.name*"MCX"' | grep "^dn"
moquery -c rtctrlMatchRtDest -f 'rtctrl.MatchRtDest.dn*"subj-MCX-IMPORT/"' | grep -c "^dn"
moquery -c rtctrlMatchRtDest -f 'rtctrl.MatchRtDest.dn*"subj-MCX-LD5-IMPORT/"' | grep -c "^dn"
moquery -c rtctrlMatchCommFactor -f 'rtctrl.MatchCommFactor.dn*"MCX-LD5-IMPORT"' | grep -E "^dn|community"
moquery -c rtctrlSetPref -f 'rtctrl.SetPref.dn*"MCX-LD5-LOCALPREF200"' | grep -E "^dn|localPref"
```

**APIC UXB 10.157.254.10**

```
moquery -c rtctrlSubjP -f 'rtctrl.SubjP.name*"MCX"' | grep "^dn"
moquery -c rtctrlMatchRtDest -f 'rtctrl.MatchRtDest.dn*"subj-MCX-IMPORT/"' | grep -c "^dn"
moquery -c rtctrlMatchRtDest -f 'rtctrl.MatchRtDest.dn*"subj-MCX-LD5-IMPORT/"' | grep -c "^dn"
moquery -c rtctrlMatchCommFactor -f 'rtctrl.MatchCommFactor.dn*"MCX-LD5-IMPORT"' | grep -E "^dn|community"
moquery -c rtctrlSetPref -f 'rtctrl.SetPref.dn*"MCX-LD5-LOCALPREF200"' | grep -E "^dn|localPref"
```

**Expected:** match rules MCX-IMPORT and MCX-LD5-IMPORT in PROD_TNT; 30 prefixes in each; community regular:as2-nn2:64635:100 on MCX-LD5-IMPORT; local preference 200 in MCX-LD5-LOCALPREF200.

### P8 - FortiGate policy in the other VDOMs

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** Policy lookups for real flows from Appendix A subnets into mcx_lan and mcx_s2s on both FortiGates, entering on the interface each VDOM uses towards the EX4650 (ae3.810 in mcx_lan, ae3.840 in mcx_s2s). The flows are taken from the policies in mcx_lan and mcx_s2s that have an Appendix A subnet as source (pulled 20/11/2026): Infoblox DNS and NTP from SWI_PROD_1050_BD, vCenter from the fenix jump hosts (row 23) and nw-rdp-server 10.99.59.3 (row 41), and the GIST flows from NONPROD_139_BD (row 5). After each match, show the matched policy to see its action.

**Why:** After 3.4 this traffic enters these VDOMs from the EX4650. Each flow must hit an accept policy, not the cleanup rule.

**MCX-LD5-FGT2600-01**

```
config vdom
edit mcx_lan
diagnose firewall iprope lookup 10.158.50.10 1024 10.156.116.3 53 udp ae3.810
diagnose firewall iprope lookup 10.158.50.10 1024 10.141.2.11 123 udp ae3.810
diagnose firewall iprope lookup 10.141.96.100 1024 10.156.118.106 443 tcp ae3.810
diagnose firewall iprope lookup 10.99.59.3 1024 10.156.118.106 22 tcp ae3.810
end
config vdom
edit mcx_s2s
diagnose firewall iprope lookup 10.96.139.91 1024 172.24.106.122 9100 tcp ae3.840
diagnose firewall iprope lookup 10.96.139.66 1024 172.24.48.123 21424 tcp ae3.840
diagnose firewall iprope lookup 10.96.139.90 1024 172.17.4.10 9100 tcp ae3.840
end
```

**MCX-LD8-FGT2600-01**

```
config vdom
edit mcx_lan
diagnose firewall iprope lookup 10.158.50.10 1024 10.156.244.2 53 udp ae3.810
diagnose firewall iprope lookup 10.158.50.10 1024 10.141.2.11 123 udp ae3.810
diagnose firewall iprope lookup 10.141.96.100 1024 10.156.246.106 443 tcp ae3.810
diagnose firewall iprope lookup 10.99.59.3 1024 10.156.246.106 22 tcp ae3.810
end
config vdom
edit mcx_s2s
diagnose firewall iprope lookup 10.96.139.91 1024 172.24.106.122 9100 tcp ae3.840
diagnose firewall iprope lookup 10.96.139.66 1024 172.24.48.123 21424 tcp ae3.840
diagnose firewall iprope lookup 10.96.139.90 1024 172.17.4.10 9100 tcp ae3.840
end
```

After each lookup: show firewall policy \<id from the lookup> (in the same VDOM)

**Expected:** each lookup matches an accept policy (no set action line in the show means deny). MCX-LD5-FGT2600-01: mcx_lan 34, 119, 61, and 48 vcenter-block-rule (deny) for 10.99.59.3 to vCenter tcp 22; mcx_s2s 16, 17, 42. MCX-LD8-FGT2600-01: mcx_lan 34, 96, 48, 8; mcx_s2s 18, 19, 44. Policy 48 on MCX-LD5-FGT2600-01 blocks that flow today and the change doesn't alter it (the same rule is disabled on MCX-LD8-FGT2600-01, id 47): known, not a stop. Any other lookup matching a cleanup or deny rule: stop.

*Note: Put only day numbers in this plan, actual dates into Change Record*


## **Implementation**

(Change Window Starts)

**Mandatory:** When change starts update Helix to “Implementation in Progress” or if change does not proceed then in Helix Cancel the change with a suitable reason: “No Longer Required / Resources Not Available / To Be Rescheduled”.

*Owner: Network Engineer*

---

> **Phase 2 - move the MCX L3Outs into the stretched template as PROD_MCX_L3OUT (2.3.1 to 2.3.5, new), then attach the 62 bridge domains in Appendix A (2.4, change 2.1 step 2.3 moved here) and build the EX4650 reject policies for 3.4 (2.5). No impact: the EX4650 hold from change 2.1 step 2.2 is in place. The four EX4650 fabric sessions are down between 2.3.1 and 2.3.4.**

---

### 2.3.1 - NDO: record the MCX L3Out build, then delete MCX_L3OUT (SWI) and UXB_MCX_L3OUT (UXB) from the site-local templates (no impact)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Record how both L3Outs are built to the session log, then delete them and their external EPGs in NDO. The four EX4650 fabric sessions drop at these deploys and stay down until 2.3.3 and 2.3.4 are done. Nothing is advertised or received on them (the hold from change 2.1), so no route changes.

1. Run the record commands below on both APICs. 2.3.3 and 2.3.4 are built from this output and 2.3.5 is checked against it.

2. In NDO, open SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT. Delete External EPG MCX_L3OUT_EXT_EPG, then L3Out MCX_L3OUT > Save.

3. Run the deployment plan. It must show only the external EPG and the L3Out being deleted at SWI. If it shows anything else, stop and don't deploy.

4. Deploy. If NDO won't take both in one deploy, deploy with only the external EPG deleted, then delete the L3Out and deploy again.

5. Do lines 2 to 4 in UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT (MCX_L3OUT_EXT_EPG and MCX_L3OUT there are UXB_MCX_L3OUT_EXT_EPG and UXB_MCX_L3OUT on the APIC). NDO shows the UXB L3Out's display name as "MCX_L3OUT " with a trailing space (19/11/2026), so search for MCX_L3OUT.

6. Run the check commands below on both APICs and both EX4650s.

**Why:** NDO won't let a bridge domain in the stretched template use an L3Out in a site-local template. The site-local template already uses PROD_VRF from the stretched template, so the two templates would depend on each other (the error at change 2.1 step 2.3). The L3Out has to be in the stretched template, as PROD_MIG_L3OUT is. NDO can't move an L3Out between templates, so it is deleted here and created again in 2.3.2. The old L3Outs go first because vlans 725 to 728 on eth1/40 can't be in two L3Outs on the same leaf. Deleting the L3Out in NDO removes everything under it on the APIC, including the node profile, SVIs and BGP peers that were built on the APIC, which is why they are recorded first.

**Record (before the delete)**

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
```

**Check (after both deploys)**

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extInstP -f 'l3ext.InstP.name*"MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extInstP -f 'l3ext.InstP.name*"MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
show bgp summary instance mcx_vrf | no-more
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
show bgp summary instance mcx_vrf | no-more
```

**Expected:** record: at SWI one L3Out MCX_L3OUT, enforceRtctrl export,import, domain SWI_L3OUT_MCX_DOM, bgpExtP count 1, nodes 1701 (router ID 10.158.255.13) and 1702 (10.158.255.14), SVIs vlan-725 10.158.240.242/30 and vlan-726 10.158.240.246/30, peers 10.158.240.241 (AS 64635) and 10.158.240.245 (AS 64636), BFD policy BFD_POL_INT_300. At UXB one L3Out UXB_MCX_L3OUT, export,import, domain UXB_L3OUT_MCX_DOM, bgpExtP count 1, nodes 2703 (10.157.255.17) and 2704 (10.157.255.18), SVIs vlan-727 10.157.240.210/30 and vlan-728 10.157.240.214/30, peers 10.157.240.209 (AS 64635) and 10.157.240.213 (AS 64636), BFD policy BFD_POL-INT_300. If the record shows anything different from these values, stop before the delete and correct 2.3.3 and 2.3.4 first. Check: L3Out count 0 and external EPG count 0 on both APICs; both site-local templates In Sync; the default route as in P2; on each EX4650 the two fabric neighbours are not Established and the other 9 peers are.

### 2.3.2 - NDO (stretched template): create PROD_MCX_L3OUT and PROD_MCX_L3OUT_EXT_EPG and deploy to SWI and UXB (no impact)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Create the L3Out and its external EPG in PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT, set up the same way as PROD_MIG_L3OUT and PROD_MIG_L3OUT_EXT_EPG in that template. NDO holds only the name and the VRF. The rest is built on each APIC in 2.3.3 and 2.3.4.

1. In NDO, open PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT > Create Object > L3Out: Display Name PROD_MCX_L3OUT, Virtual Routing & Forwarding PROD_VRF.

2. Create Object > External EPG: Display Name PROD_MCX_L3OUT_EXT_EPG, Virtual Routing & Forwarding PROD_VRF, fabric type ON-PREM, L3Out PROD_MCX_L3OUT under On-Premises Properties in the template (not per site), as on PROD_MIG_L3OUT_EXT_EPG. No contract and no subnet: those are 3.1 and 3.2.

3. Save. Run the deployment plan. It must show only these two objects, at SWI and UXB. If it shows anything else, stop and don't deploy.

4. Deploy.

**Why:** An L3Out in the stretched template is deployed to both sites under one name. The stretched bridge domains are in the same template, and the site-local templates already depend on the stretched template for PROD_VRF, so every bridge domain in Appendix A can use it without the two templates depending on each other. SWI_NONPROD_1303_BD (site-local) uses PROD_MIG_L3OUT this way today.

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsEctx -f 'l3ext.RsEctx.dn*"out-PROD_MCX_L3OUT/"' | grep -E "^dn|tnFvCtxName"
moquery -c l3extInstP -f 'l3ext.InstP.name=="PROD_MCX_L3OUT_EXT_EPG"' | grep "^dn"
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsEctx -f 'l3ext.RsEctx.dn*"out-PROD_MCX_L3OUT/"' | grep -E "^dn|tnFvCtxName"
moquery -c l3extInstP -f 'l3ext.InstP.name=="PROD_MCX_L3OUT_EXT_EPG"' | grep "^dn"
```

**Expected:** on both APICs PROD_MCX_L3OUT in PROD_TNT with PROD_VRF, and PROD_MCX_L3OUT_EXT_EPG under it; the stretched template In Sync. enforceRtctrl shows export only at this point: Import is ticked on the APIC in 2.3.3 and 2.3.4, before any peer is built.

### 2.3.3 - APIC SWI: build PROD_MCX_L3OUT by hand - BGP, node profile, SVIs, BGP peers and BFD (no impact)

*Day 1 · Duration 00:25 · Owner: Network Engineer*

**What:** On APIC SWI 10.158.254.10, under Tenants > PROD_TNT > Networking > L3Outs > PROD_MCX_L3OUT, put back what was under MCX_L3OUT with the same values (the 2.3.1 record). The banner saying the object was created by NDO is expected. BGP is set in two places: on the L3Out itself (line 1) and as a peer inside each SVI (lines 4 and 6).

1. PROD_MCX_L3OUT > Policy > Main: tick BGP (Enable BGP/EIGRP/OSPF). Route Control Enforcement: tick Import (Export is always on). L3 Domain: SWI_L3OUT_MCX_DOM. Submit. Do this line first, before any peer is built.

2. Logical Node Profiles > Create Node Profile: Name MCX_NODE_PROF. Add node 1701 with Router ID 10.158.255.13 and node 1702 with Router ID 10.158.255.14. Untick Use Router ID as Loopback Address on both (it is ticked by default).

3. Under MCX_NODE_PROF create Logical Interface Profile MCX_LD5_IFP. SVI tab > add: Path Type Port, node 1701, eth1/40, Encap vlan 725, Encap Scope Local, Auto State disabled, Mode Trunk, IPv4 Primary Address 10.158.240.242/30, MTU 1500 (typed in, the default is inherit), MAC left as default (00:22:BD:F8:19:FF).

4. In the same SVI, BGP Peer Connectivity Profiles > add: Peer Address 10.158.240.241 (MCX-LD5-EX4650-INNER-01), Remote AS 64635, Peer Controls: tick Bidirectional Forwarding Detection, Password and Confirm Password. Everything else as default: no BGP Controls ticked, AF Ucast, EBGP Multihop TTL 1, Weight 0, no Local-AS.

5. Under MCX_NODE_PROF create Logical Interface Profile MCX_LD8_IFP. SVI tab > add, with the same settings as line 3: node 1702, eth1/40, Encap vlan 726, IPv4 Primary Address 10.158.240.246/30, MTU 1500.

6. In that SVI, BGP Peer Connectivity Profiles > add, the same way as line 4: Peer Address 10.158.240.245 (MCX-LD8-EX4650-INNER-01), Remote AS 64636, Bidirectional Forwarding Detection ticked, Password and Confirm Password.

7. On MCX_LD5_IFP and on MCX_LD8_IFP: Create BFD Interface Profile, Authentication Type none, BFD Interface Policy BFD_POL_INT_300.

**Why:** NDO holds only the name and VRF of this L3Out, so this part is built on the APIC, as it was for the old L3Out and as it is for PROD_MIG_L3OUT. Import is ticked before the peers are built so ACI never accepts routes without the import route map (3.3); the EX4650s send nothing until 3.0 in any case. The router IDs must be exactly these: PROD_MIG_L3OUT uses the same leafs in PROD_VRF with the same router IDs, and a different one would clash with it. The menu names are as on APIC 6.x and haven't been checked against 6.1(5e). If a label differs, the setting is the same one; PROD_MIG_L3OUT shows where each sits.

**Expected:** no fault on PROD_MCX_L3OUT; the two EX4650 neighbours come up within a minute or two of line 6. Checked in 2.3.5.

### 2.3.4 - APIC UXB: build PROD_MCX_L3OUT by hand - BGP, node profile, SVIs, BGP peers and BFD (no impact)

*Day 1 · Duration 00:25 · Owner: Network Engineer*

**What:** On APIC UXB 10.157.254.10, under Tenants > PROD_TNT > Networking > L3Outs > PROD_MCX_L3OUT, put back what was under UXB_MCX_L3OUT with the same values (the 2.3.1 record). The banner saying the object was created by NDO is expected. BGP is set in two places: on the L3Out itself (line 1) and as a peer inside each SVI (lines 4 and 6).

1. PROD_MCX_L3OUT > Policy > Main: tick BGP (Enable BGP/EIGRP/OSPF). Route Control Enforcement: tick Import (Export is always on). L3 Domain: UXB_L3OUT_MCX_DOM. Submit. Do this line first, before any peer is built.

2. Logical Node Profiles > Create Node Profile: Name MCX_NODE_PROF. Add node 2703 with Router ID 10.157.255.17 and node 2704 with Router ID 10.157.255.18. Untick Use Router ID as Loopback Address on both (it is ticked by default).

3. Under MCX_NODE_PROF create Logical Interface Profile MCX_LD5_IFP. SVI tab > add: Path Type Port, node 2703, eth1/40, Encap vlan 727, Encap Scope Local, Auto State disabled, Mode Trunk, IPv4 Primary Address 10.157.240.210/30, MTU 1500 (typed in, the default is inherit), MAC left as default (00:22:BD:F8:19:FF). Description "To MCX LD5" (as it was).

4. In the same SVI, BGP Peer Connectivity Profiles > add: Peer Address 10.157.240.209 (MCX-LD5-EX4650-INNER-01), Remote AS 64635, Peer Controls: tick Bidirectional Forwarding Detection, Password and Confirm Password. Everything else as default: no BGP Controls ticked, AF Ucast, EBGP Multihop TTL 1, Weight 0, no Local-AS.

5. Under MCX_NODE_PROF create Logical Interface Profile MCX_LD8_IFP. SVI tab > add, with the same settings as line 3: node 2704, eth1/40, Encap vlan 728, IPv4 Primary Address 10.157.240.214/30, MTU 1500.

6. In that SVI, BGP Peer Connectivity Profiles > add, the same way as line 4: Peer Address 10.157.240.213 (MCX-LD8-EX4650-INNER-01), Remote AS 64636, Bidirectional Forwarding Detection ticked, Password and Confirm Password.

7. On MCX_LD5_IFP and on MCX_LD8_IFP: Create BFD Interface Profile, Authentication Type none, BFD Interface Policy BFD_POL-INT_300.

**Why:** NDO holds only the name and VRF of this L3Out, so this part is built on the APIC, as it was for the old L3Out and as it is for PROD_MIG_L3OUT. Import is ticked before the peers are built so ACI never accepts routes without the import route map (3.3); the EX4650s send nothing until 3.0 in any case. The router IDs must be exactly these: PROD_MIG_L3OUT uses the same leafs in PROD_VRF with the same router IDs, and a different one would clash with it. The BFD policy is BFD_POL_INT_300 at SWI and BFD_POL-INT_300 at UXB; the existing names are used as they are.

**Expected:** no fault on PROD_MCX_L3OUT; the two EX4650 neighbours come up within a minute or two of line 6. Checked in 2.3.5.

### 2.3.5 - Verify 2.3: PROD_MCX_L3OUT is built as the old L3Outs were, sessions up, nothing sent or received (mandatory before 2.4)

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** Run the 2.3.1 record commands again on both APICs and compare them line by line with the 2.3.1 output. Only the L3Out name in the dn may differ. Then check for faults, the BGP and BFD sessions on the leafs and the EX4650s, that nothing is advertised or received, and NDO.

1. Run the commands below on both APICs and both EX4650s.

2. In NDO, check PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT, SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT and UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT are In Sync, and run the deployment plan on the stretched template. It must show no change, and in particular no change to route control enforcement on PROD_MCX_L3OUT (P3 check 2).

**Why:** The build is done by hand, so a wrong router ID, vlan or address, a missed BGP or Import tick, or a missed BFD profile shows here and not at the switch-over. If a value is wrong, correct it on the APIC and run this again. If it can't be made to pass, run rollback row 4. Don't start 2.4 until this passes.

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
moquery -c faultInst -f 'fault.Inst.dn*"out-PROD_MCX_L3OUT"' | grep -E "^dn|^descr|^severity"
fabric 1701,1702 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
fabric 1701,1702 show bfd neighbors vrf PROD_TNT:PROD_VRF
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name*"MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
moquery -c faultInst -f 'fault.Inst.dn*"out-PROD_MCX_L3OUT"' | grep -E "^dn|^descr|^severity"
fabric 2703,2704 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
fabric 2703,2704 show bfd neighbors vrf PROD_TNT:PROD_VRF
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
show bgp summary instance mcx_vrf | no-more
show bfd session | no-more
show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | count
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | count
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
show bgp summary instance mcx_vrf | no-more
show bfd session | no-more
show route advertising-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | count
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | count
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | count
```

**Expected:** the record output matches 2.3.1 at both sites (the values listed under Expected in 2.3.1, and rtrIdLoopBack no from the ^rtrId grep, encapScope local from ^encap and mac 00:22:BD:F8:19:FF), now under PROD_MCX_L3OUT: enforceRtctrl export,import, bgpExtP count 1, the same domain, nodes and router IDs, SVIs, peers, AS and BFD policy; mtu 1500, autostate disabled, peerCtrl bfd, ttl 1. No fault on PROD_MCX_L3OUT. On the leafs the EX4650 neighbours (10.158.240.241 / .245 at SWI, 10.157.240.209 / .213 at UXB) are Established with 0 prefixes received and BFD is up; there is no route via PROD_MCX_L3OUT and the default route is as in P2. On each EX4650 11 peers are Established and BFD is up to the fabric peers; nothing is advertised to the four fabric peers; nothing is received from them and the hidden count is 0. All three templates In Sync and the deployment plan shows no change.

### 2.4 - NDO: attach the 62 bridge domains in Appendix A to PROD_MCX_L3OUT at the site that owns each one, in batches, with the no-impact check after every batch, then Verify 2.4 (no impact)

*Day 1 · Duration 03:00 · Owner: Network Engineer*

**What:** Associate the 62 bridge domains in Appendix A with PROD_MCX_L3OUT, in batches. Each one is attached where it is managed. The other-site copies of rows 27 to 61 are NDO shadow objects and are not touched on the APIC. This is change 2.1 step 2.3, moved here on 19/11/2026; 2.3 is done and Verify 2.3 has passed first.

**Rows 1 to 26:** NDO, PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT, at SWINDON and UXBRIDGE.

**Rows 27 to 42:** NDO at SWINDON only (SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT; rows 28 to 32 in SWI_NONPROD_CYBERARK_BD_EPG_APP_CONTRACT-TMPLT).

**Rows 43 to 61:** NDO at UXBRIDGE only (UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT).

**Row 62 UXB_PROD_1700_BD:** APIC UXB 10.157.254.10 only, because it isn't in NDO: Tenants > PROD_TNT > Networking > Bridge Domains > UXB_PROD_1700_BD > Policy > L3 Configurations > Associated L3 Outs > + PROD_MCX_L3OUT > Submit.

**1.** The stretched template must be deployed and In Sync before a site-local template that uses PROD_MCX_L3OUT is deployed.

**2.** Run the NDO deployment plan before each deploy. It must show only this change.

**3.** Do SWI_PROD_1050_BD (row 35) first, on its own, and run the no-impact check. Note whether 10.158.50.0/24 shows as hidden from the SWI peers only, or from the UXB peers as well.

**4.** Do the rest in batches. After every batch run the no-impact check, and don't start the next batch until it passes.

**5.** Once both sites are done, run Verify 2.4 (mandatory).

**Where to look:** the bridge domain routes show as hidden on the EX4650s, because import DENY-ALL rejects them.

**Why:** Attaching a bridge domain makes ACI advertise its subnet to the EX4650s and nothing else. The EX4650s reject it and advertise nothing back (change 2.1 step 2.2), so no route changes anywhere and traffic stays on its current path. The no-impact check confirms that after each batch. Verify 2.4 then proves the MCX L3Outs advertise every bridge domain subnet and nothing else. If either check fails, stop: detach the bridge domains attached so far and deploy (no impact), then don't start 3.0.

**Why SWI_PROD_1050_BD goes first:** it lives at SWI only. If the UXB peers show its subnet too, NDO has copied the attachment onto the UXB shadow, as it does for PROD_MIG_L3OUT. That is expected and harmless here because the routes are hidden, and it is why 3.4 uses the per-site filter from 2.5.

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | no-more
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | no-more
```

**Verify 2.4 (once both sites are done):** the receive-protocol commands above on both EX4650s, and the APIC commands below.

**APIC SWI 10.158.254.10**

```
moquery -c fvBD -f 'fv.BD.name=="PROD_3022_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3046_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3056_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3083_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3096_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvRsBDToOut -f 'fv.RsBDToOut.tnL3extOutName*"PROD_MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
```

**APIC UXB 10.157.254.10**

```
moquery -c fvBD -f 'fv.BD.name=="PROD_3022_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3046_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3056_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3083_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvBD -f 'fv.BD.name=="PROD_3096_BD"' | grep -E "^name|^unicastRoute"
moquery -c fvRsBDToOut -f 'fv.RsBDToOut.tnL3extOutName*"PROD_MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
```

**Expected (Verify 2.4):** no active route from the fabric peers. Hidden: only Appendix A subnets with unicast routing on; no /32 host route, no default route, no prefix from another L3Out and no prefix outside Appendix A.

**Hidden counts:** 56 from each SWI peer and 55 from each UXB peer if NDO copies the attachment to the shadow copies (expected); 37 and 45 if it doesn't. Either is fine. Record which.

**unicastRoute:** yes on PROD_3022_BD, PROD_3046_BD, PROD_3056_BD, PROD_3083_BD and PROD_3096_BD at both sites. PROD_3046_BD and PROD_3083_BD were not migrated at 15:39 on 19/11/2026 (Requirements); if either shows no, stop and get a decision before going on.

**APIC counts:** MCX L3Out bridge domain count 61 at SWI and 62 at UXB with the shadow copies, 42 and 46 without; enforceRtctrl export,import on PROD_MCX_L3OUT at both sites.

**No-impact check (after every batch):** the commands below.

**MCX-LD5-EX4650-INNER-01**

```
show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | no-more
show route summary table mcx_vrf.inet.0 | no-more
show bgp neighbor 10.158.240.242 instance mcx_vrf | match "State:|prefixes|limit"
show bgp neighbor 10.157.240.210 instance mcx_vrf | match "State:|prefixes|limit"
```

**MCX-LD8-EX4650-INNER-01**

```
show route advertising-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | no-more
show route summary table mcx_vrf.inet.0 | no-more
show bgp neighbor 10.158.240.246 instance mcx_vrf | match "State:|prefixes|limit"
show bgp neighbor 10.157.240.214 instance mcx_vrf | match "State:|prefixes|limit"
```

**MCX-LD5-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.118.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.122 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.126 advertised-routes | grep Total
get router info bgp neighbors 169.254.52.89 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.141.2.
end
```

**MCX-LD8-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.246.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.122 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.126 advertised-routes | grep Total
get router info bgp neighbors 169.254.130.41 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.141.2.
end
```

**APIC SWI 10.158.254.10**

```
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
fabric 1701,1702 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
```

**APIC UXB 10.157.254.10**

```
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
fabric 2703,2704 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
```

**Expected (no-impact check):** nothing advertised to the four fabric peers; no active route from them; the subnets of the bridge domains attached so far show as hidden, and nothing else does (the first bridge domain must show as hidden before the next batch, which proves the import deny is doing the work); fabric sessions Established and under their prefix limits; no fabric subnet active in mcx_vrf.inet.0. FortiGate advertised totals as P5, and both FortiGates still send 10.96.3.70/32, 10.141.2.11/32 and 10.141.2.34/32 to Vodafone. On the leafs the EX4650 neighbours (10.158.240.241 / .245 at SWI, 10.157.240.209 / .213 at UXB) show 0 prefixes received, there's no route via PROD_MCX_L3OUT and the default route is as in P2; enforceRtctrl on PROD_MCX_L3OUT is still export,import at both sites (an NDO deploy of the stretched template must not reset it). If any of these fails, stop: detach the bridge domains attached so far (in NDO and deploy, and on APIC UXB for UXB_PROD_1700_BD).

### 2.5 - MCX-LD5-EX4650-INNER-01 and MCX-LD8-EX4650-INNER-01: build the per-site reject policies for 3.4 (no impact)

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** On both EX4650s, create two prefix lists and two reject policies. They aren't applied to anything until 3.4, so nothing changes. The config is the same on both.

**Why:** The bridge domains in rows 27 to 61 live at one site, but the other site can advertise their subnets too (NDO shadow copies, see 2.4). In 3.4 the SWI sessions reject the UXB-owned subnets and the UXB sessions reject the SWI-owned ones, so MCX only accepts each subnet from the site that has the endpoints.

**UXB-OWNED-BDS:** 10.157.0.0/16. Every UXB-owned subnet (rows 43 to 62) is inside it, and no stretched or SWI-owned bridge domain uses it.

**SWI-OWNED-BDS:** 10.158.0.0/16 (rows 33 to 40 and 42), plus the seven SWI-owned subnets in the shared 10.96 and 10.99 ranges (rows 27 to 32 and 41). No stretched or UXB-owned bridge domain uses any of these.

**Logic:** each policy has one term that rejects and no default action, so a route that doesn't match carries on to the next policy in the chain. In 3.4 that is FABRIC-RANGES, which isn't changed.

**Keep in step with ACI:** a new SWI-owned bridge domain outside 10.158.0.0/16 needs a line in SWI-OWNED-BDS. If a one-site bridge domain is later stretched, its subnet must come out of the list.

**MCX-LD5-EX4650-INNER-01**

```
configure
set policy-options prefix-list UXB-OWNED-BDS 10.157.0.0/16
set policy-options prefix-list SWI-OWNED-BDS 10.158.0.0/16
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.0/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.32/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.64/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.96/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.128/28
set policy-options prefix-list SWI-OWNED-BDS 10.96.148.0/28
set policy-options prefix-list SWI-OWNED-BDS 10.99.59.0/24
set policy-options policy-statement REJECT-UXB-OWNED term 1 from prefix-list-filter UXB-OWNED-BDS orlonger
set policy-options policy-statement REJECT-UXB-OWNED term 1 then reject
set policy-options policy-statement REJECT-SWI-OWNED term 1 from prefix-list-filter SWI-OWNED-BDS orlonger
set policy-options policy-statement REJECT-SWI-OWNED term 1 then reject
show | compare
commit check
commit
run show configuration policy-options policy-statement REJECT-UXB-OWNED | no-more
run show configuration policy-options policy-statement REJECT-SWI-OWNED | no-more
run show configuration routing-instances mcx_vrf protocols bgp | display set | match "aci.*(import|export)"
run show bgp summary instance mcx_vrf | no-more
exit
```

**MCX-LD8-EX4650-INNER-01**

```
configure
set policy-options prefix-list UXB-OWNED-BDS 10.157.0.0/16
set policy-options prefix-list SWI-OWNED-BDS 10.158.0.0/16
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.0/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.32/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.64/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.96/27
set policy-options prefix-list SWI-OWNED-BDS 10.96.147.128/28
set policy-options prefix-list SWI-OWNED-BDS 10.96.148.0/28
set policy-options prefix-list SWI-OWNED-BDS 10.99.59.0/24
set policy-options policy-statement REJECT-UXB-OWNED term 1 from prefix-list-filter UXB-OWNED-BDS orlonger
set policy-options policy-statement REJECT-UXB-OWNED term 1 then reject
set policy-options policy-statement REJECT-SWI-OWNED term 1 from prefix-list-filter SWI-OWNED-BDS orlonger
set policy-options policy-statement REJECT-SWI-OWNED term 1 then reject
show | compare
commit check
commit
run show configuration policy-options policy-statement REJECT-UXB-OWNED | no-more
run show configuration policy-options policy-statement REJECT-SWI-OWNED | no-more
run show configuration routing-instances mcx_vrf protocols bgp | display set | match "aci.*(import|export)"
run show bgp summary instance mcx_vrf | no-more
exit
```

**Expected:** show | compare shows only the two prefix lists and the two policies; the fabric groups still have import DENY-ALL and export DENY-ALL; 11 peers Established on each EX4650.

---

> **Phase 3 - Switch-over (Phases 1 and 2 were done in change 2.1). No impact: the EX4650s send the MCX routes to the fabrics (3.0), then the contract (3.1) and the external subnets (3.2) are deployed one at a time and checked. Outage, about 2 to 5 minutes: the import route map is created on APIC SWI then APIC UXB (3.3), ACI is checked to be using the MCX routes, then the EX4650s release the fabric routes (3.4).**

---

### 3.0 - MCX-LD5-EX4650-INNER-01 and MCX-LD8-EX4650-INNER-01: send the MCX routes to the fabrics (no impact)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** On the fabric groups mcx-aci-swi-peers and mcx-aci-uxb-peers, swap export DENY-ALL for MCX-TO-ACI-LD5 (MCX-LD5-EX4650-INNER-01) or MCX-TO-ACI (MCX-LD8-EX4650-INNER-01). Import stays DENY-ALL (the hold from change 2.1). Commit each device on its own, then run Verify 5.8 on both APICs. No MCX route may be installed: if one is, roll back 3.0 (the export lines in rollback row 1) and stop.

**Why:** ACI needs the MCX routes before 3.3 can import them. Import route control is enforced on the MCX L3Outs with nothing permitted until 3.3, so ACI receives the routes but installs none of them, and no traffic moves.

**Logic:**

**MCX-TO-ACI-LD5:** FROM-LD8 (AS path contains 64636 and prefix in MCX-TO-ACI -> accept, no community) -> TAG (prefix in MCX-TO-ACI -> add 64635:100, accept) -> default reject.

**MCX-TO-ACI (LD8):** prefix in MCX-TO-ACI -> accept, no community.

**LD8 ranges:** since the LD8 change, LD5 learns them over 729 (path 64636). They match FROM-LD8 and go out untagged, so ACI sees them from LD5 as 64635 64636 and from LD8 as 64636, both at local preference 100, and uses LD8 (shorter AS path).

**LD5, Azure and GCP routes:** MCX-LD8-EX4650-INNER-01 also sends the LD5 ranges and the Azure / GCP routes it learns over 729, untagged at local preference 100. LD5's tagged copies at 200 win (3.3).

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export MCX-TO-ACI-LD5
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export MCX-TO-ACI-LD5
show | compare
commit confirmed 10
run show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
run show route advertising-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
run show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 10.150.240.0/21 detail | no-more
commit
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export MCX-TO-ACI
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export MCX-TO-ACI
show | compare
commit confirmed 10
run show route advertising-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
run show route advertising-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
commit
```

**APIC SWI 10.158.254.10**

```
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**APIC UXB 10.157.254.10**

```
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 0.0.0.0/0
```

**Expected:** fabric groups export MCX-TO-ACI-LD5 (LD5) / MCX-TO-ACI (LD8) and import DENY-ALL; only MCX-TO-ACI prefixes advertised to the four fabric peers; on MCX-LD5-EX4650-INNER-01 10.150.240.0/21 carries community 64635:100; on the APICs no route via PROD_MCX_L3OUT and the default route as in P2 (as at 19/11/2026).

### 3.1 - NDO (stretched template): ALLOW_ALL_CNTRCT as provider on PROD_MCX_L3OUT_EXT_EPG. Deployed on its own, first (no impact)

*Day 1 · Duration 00:30 · Owner: Network Engineer*

**What:** Add PROD_MCX_L3OUT_EXT_EPG as a provider of ALLOW_ALL_CNTRCT. Since 2.3 it is one external EPG in the stretched template, so one deploy covers SWI and UXB. The contract itself isn't changed: it already exists in PROD_SWI-UXB_VRF_BD_EPG_APP-TMPLT (scope Global, apply both directions, filter ALLOW_ALL_FLTR).

**1.** In NDO, open PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT > External EPGs > PROD_MCX_L3OUT_EXT_EPG > Contracts > Add Contract > ALLOW_ALL_CNTRCT, type provider > Save.

**2. Run the deployment plan. It must show only the contract, at SWI and UXB.**

**3. Deploy (one deploy for SWI and UXB).**

**4.** On both APICs check PROD_MCX_L3OUT_EXT_EPG provides ALLOW_ALL_CNTRCT with state formed (the contract check in 3.5). Also check enforceRtctrl on PROD_MCX_L3OUT is still export,import (the 2.4 command). Don't start 3.2 until both are true.

**Why:** The contract must be on PROD_MCX_L3OUT_EXT_EPG before anything is classified into it. On its own this changes nothing, because the external EPG has no subnets yet. Access to MCX stays as it is today: the bridge domain EPGs already consume the contract and PROD_MIG_L3OUT_EXT_EPG provides it. Every EPG that consumes ALLOW_ALL_CNTRCT can reach the MCX ranges, not just those in Appendix A (checked in P3).

### 3.2 - NDO (stretched template): MCX-TO-ACI prefixes as External Subnets on PROD_MCX_L3OUT_EXT_EPG. Deployed on its own, after 3.1 is checked (no impact)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Add the 30 MCX-TO-ACI prefixes below to PROD_MCX_L3OUT_EXT_EPG in PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT (one external EPG, so SWI and UXB together). Never deploy this before 3.1 has been deployed and checked at both sites.

**1.** Tick only External Subnets for the External EPG. Export Route Control, Import Route Control, Shared Route Control, Shared Security Import and Aggregate stay unticked.

**2. Run the deployment plan. It must show only the 30 subnets, at SWI and UXB.**

**3. Deploy (one deploy for SWI and UXB).**

**4.** Check there are 30 subnets on both APICs (the subnet check in 3.5). Also check enforceRtctrl on PROD_MCX_L3OUT is still export,import (the 2.4 command). Don't start 3.3 until both are true.

**If there's a problem:** if an application reports a fault after this deploy, remove the 30 subnets and redeploy. That puts the classification back as it was.

**Why:** Traffic from the MCX, Azure, GCP and GIST VPN ranges is classified into PROD_MCX_L3OUT_EXT_EPG and checked against ALLOW_ALL_CNTRCT from 3.1, as the DEA design has it. ACI picks the external EPG by longest match across the whole of PROD_VRF, so these aggregates also cover the more-specifics the 3.3 route map imports. 10.120.210.0/24 stays on PROD_MIG_L3OUT_EXT_EPG, which provides the same contract.

**Without this step:** the traffic is still allowed, through the 0.0.0.0/0 on PROD_MIG_L3OUT_EXT_EPG.

**Why it goes in after 3.1, and why that has no impact:** these subnets apply across the whole VRF. Deployed before the contract, traffic from these ranges arriving on PROD_MIG_L3OUT or the UXB leak would land in an EPG with no contract and be dropped. Deployed after it, that traffic is still on Cloud Connect but is now classified into PROD_MCX_L3OUT_EXT_EPG, which provides the same contract as PROD_MIG_L3OUT_EXT_EPG (P6), so nothing is dropped.

**PROD_MCX_L3OUT_EXT_EPG subnets (SWI and UXB)**

MCX LD5: 10.156.0.0/21, 10.156.8.0/21, 10.156.112.0/23, 10.156.114.0/23, 10.156.116.0/23, 10.156.118.0/23

MCX LD8: 10.156.128.0/21, 10.156.136.0/21, 10.156.240.0/23, 10.156.242.0/23, 10.156.244.0/23, 10.156.246.0/23

MCX / SD-WAN: 10.159.0.0/16, 10.32.0.0/16, 10.45.0.0/16

Azure: 10.105.0.0/16, 10.119.0.0/16, 10.120.0.0/16, 10.126.0.0/16, 10.127.0.0/16, 10.150.0.0/16

GCP: 10.108.0.0/16, 10.109.0.0/16, 10.252.0.0/22, 10.252.4.0/22, 10.252.8.0/22, 10.252.12.0/22

GIST VPN: 172.16.0.0/16, 172.17.0.0/16, 172.24.0.0/16

### 3.3 - APIC SWI then APIC UXB: route map default-import on PROD_MCX_L3OUT (starts the outage)

*Day 1 · Duration 00:30 · Owner: Network Engineer*

**What:** Create the import route map default-import on PROD_MCX_L3OUT on APIC SWI, then straight away on APIC UXB. The submit on APIC SWI starts the outage. NDO holds only the name and VRF of PROD_MCX_L3OUT and doesn't offer a route map on it (P3 check 5), so the route map is built on each APIC, as the node profile, SVIs and peers are in 2.3.3 and 2.3.4.

**1.** Get the 3.4 config ready on both EX4650s, in configure mode and not committed.

**2. APIC SWI 10.158.254.10:** Tenants > PROD_TNT > Networking > L3Outs > PROD_MCX_L3OUT > Route map for import and export route control > Create Route Map for import and export route control. Name default-import, Type Match Routing Policy Only. Context order 0: Action Permit, Associated Matched Rules MCX-LD5-IMPORT, Set Rule MCX-LD5-LOCALPREF200. Context order 1: Action Permit, Associated Matched Rules MCX-IMPORT, no Set Rule. Submit.

**3. APIC UXB 10.157.254.10:** the same as line 2, straight after it.

**4.** Run the commands below on both APICs, then go straight to 3.4.

**If the submit fails at either site:** don't run 3.4. Commit the export lines of rollback row 1 on both EX4650s. That takes ACI's MCX routes away and puts both sites back on Cloud Connect. Delete default-import on any APIC where it was created, then fix it on the APIC.

**Why:** This is where ACI starts using the MCX routes that 3.0 sent. The contract and subnets are already in place, so this is the only step that starts the outage. SWI and UXB are done back to back so the two sites change within a minute of each other.

**Why a route map:** import subnets on the external EPG only match the exact prefix, so more-specifics (for example 10.120.8.0/21 and 172.16.0.0/20) wouldn't be imported. The route map imports them.

**NDO deploys after this:** default-import is an APIC object under an NDO-owned L3Out, like the node profile and peers. An NDO deploy of the stretched template doesn't remove it, and the template stays In Sync.

**Not lab tested:** the route map hasn't been tested in a lab or on this APIC version, which is why 3.4 checks ACI before the commit.

**Logic:** Contexts are checked lowest order first, the first match decides, and a route that matches no context is rejected. Order 0: MCX-TO-ACI prefix AND community 64635:100 (LD5's own routes) -> local preference 200. Order 1: MCX-TO-ACI prefix, any community (LD8's routes, and LD5's untagged copies of LD8's routes) -> local preference 100.

**APIC SWI 10.158.254.10**

```
moquery -c rtctrlProfile -f 'rtctrl.Profile.dn*"out-PROD_MCX_L3OUT/"' | grep -E "^dn|^type"
moquery -c rtctrlCtxP -f 'rtctrl.CtxP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|^order|^action"
moquery -c rtctrlRsCtxPToSubjP -f 'rtctrl.RsCtxPToSubjP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|tnRtctrlSubjPName"
moquery -c rtctrlRsScopeToAttrP -f 'rtctrl.RsScopeToAttrP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|tnRtctrlAttrPName"
```

**APIC UXB 10.157.254.10**

```
moquery -c rtctrlProfile -f 'rtctrl.Profile.dn*"out-PROD_MCX_L3OUT/"' | grep -E "^dn|^type"
moquery -c rtctrlCtxP -f 'rtctrl.CtxP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|^order|^action"
moquery -c rtctrlRsCtxPToSubjP -f 'rtctrl.RsCtxPToSubjP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|tnRtctrlSubjPName"
moquery -c rtctrlRsScopeToAttrP -f 'rtctrl.RsScopeToAttrP.dn*"out-PROD_MCX_L3OUT/prof-default-import/"' | grep -E "^dn|tnRtctrlAttrPName"
```

**Expected:** at each site one route map prof-default-import under PROD_MCX_L3OUT, type global (Match Routing Policy Only); two contexts, order 0 and order 1, both permit; order 0 uses MCX-LD5-IMPORT with set rule MCX-LD5-LOCALPREF200; order 1 uses MCX-IMPORT with no set rule.

### 3.4 - MCX-LD5-EX4650-INNER-01 and MCX-LD8-EX4650-INNER-01: release the fabric routes (straight after 3.3)

*Day 1 · Duration 00:10 · Owner: Network Engineer*

**What:** On the fabric groups, swap import DENY-ALL for the per-site reject policy from 2.5 followed by FABRIC-RANGES (the Part 1 setting): REJECT-UXB-OWNED on the SWI group and REJECT-SWI-OWNED on the UXB group. As soon as 3.3 is submitted on both APICs, run the route check below on both APICs. If both sites show the MCX route via the EX4650, commit, MCX-LD5-EX4650-INNER-01 first. If either site doesn't, don't commit and run rollback row 1.

**Why:** MCX, Azure and GCP learn the bridge domain subnets (more specific than the 10.0.0.0/8 via Cloud Connect) and send their traffic for the bridge domains via MCX, matching the outbound traffic since 3.3. The outage ends when this has converged.

**Why the reject policy:** a one-site subnet is only accepted from the site that owns it, so MCX never sends its traffic to the site with no endpoints (2.5).

**Check before the commit:** is ACI using the MCX routes at both sites?

**APIC SWI 10.158.254.10**

```
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
```

**APIC UXB 10.157.254.10**

```
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
```

**Expected before the commit:** at each site the route to 10.156.118.129 is a BGP route with its next hop on the EX4650 (10.158.240.241 or .245 at SWI, 10.157.240.209 or .213 at UXB), not the default route. If a site still shows the default route, ACI isn't importing there. Committing 3.4 would then bring inbound traffic in via MCX while ACI replies via Cloud Connect.

**MCX-LD5-EX4650-INNER-01**

Neighbours - 10.158.240.242 SWI-1701, 10.157.240.210 UXB-2703

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import [ REJECT-UXB-OWNED FABRIC-RANGES ]
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import [ REJECT-SWI-OWNED FABRIC-RANGES ]
show | compare
commit confirmed 10
run show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | count
run show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | count
run show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | no-more
run show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | no-more
run show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 10.158.50.0/24 exact | no-more
run show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 10.158.50.0/24 exact | no-more
commit
```

**MCX-LD8-EX4650-INNER-01**

Neighbours - 10.158.240.246 SWI-1702, 10.157.240.214 UXB-2704

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import [ REJECT-UXB-OWNED FABRIC-RANGES ]
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import DENY-ALL
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import [ REJECT-SWI-OWNED FABRIC-RANGES ]
show | compare
commit confirmed 10
run show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | count
run show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | count
run show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | no-more
run show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | no-more
run show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 10.158.50.0/24 exact | no-more
run show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 10.158.50.0/24 exact | no-more
commit
```

**Expected:** the bridge domain routes are active: 37 from each SWI peer and 45 from each UXB peer.

**Hidden:** from the SWI peers only subnets inside 10.157.0.0/16 (up to 19), and from the UXB peers only SWI-owned subnets (up to 10). None if NDO didn't copy the attachment to the shadow copies (2.4). Anything else hidden: don't confirm the commit.

**Example:** 10.158.50.0/24 (SWI_PROD_1050_BD) is shown from the SWI peer and not from the UXB peer.

### 3.5 - APIC SWI and UXB: verify the MCX routes are installed via PROD_MCX_L3OUT and classified

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Check the MCX, Azure, GCP and GIST prefixes are installed via PROD_MCX_L3OUT, at local preference 200 via LD5 and 100 via LD8, and that the external EPG pcTag is in the zoning rules with the contract. Part A finds the PROD_VRF scope id, the PROD_MCX_L3OUT_EXT_EPG pcTag and the external subnets; part B uses the scope id.

**Why:** Confirms the switch-over. If it fails, or V3 or V5 fail, run rollback row 1 (fast stop).

**APIC SWI 10.158.254.10**

```
moquery -c fvCtx -f 'fv.Ctx.name=="PROD_VRF"' | grep -E "^dn|scope"
moquery -c l3extInstP -f 'l3ext.InstP.name=="PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|pcTag"
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|^ip |scope"
moquery -c fvRsProv -f 'fv.RsProv.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName|state"
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.120.210.1
fabric 1701,1702 show ip bgp 10.156.118.129 vrf PROD_TNT:PROD_VRF
fabric 1701,1702 show zoning-rule scope <PROD_VRF scope id from the first command>
```

**APIC UXB 10.157.254.10**

```
moquery -c fvCtx -f 'fv.Ctx.name=="PROD_VRF"' | grep -E "^dn|scope"
moquery -c l3extInstP -f 'l3ext.InstP.name=="PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|pcTag"
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|^ip |scope"
moquery -c fvRsProv -f 'fv.RsProv.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -E "^dn|tnVzBrCPName|state"
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.252.0.0/22
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.150.0.0/16
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 172.16.0.0/20
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.120.210.1
fabric 2703,2704 show ip bgp 10.156.118.129 vrf PROD_TNT:PROD_VRF
fabric 2703,2704 show zoning-rule scope <PROD_VRF scope id from the first command>
```

**Expected:** routes via PROD_MCX_L3OUT with next hop 10.158.240.241 or 10.158.240.245 at SWI and 10.157.240.209 or 10.157.240.213 at UXB (the EX4650 side of the links); the LD5 route at local preference 200 and the LD8 route at 100; the external EPG pcTag in the zoning rules with the contract; the default route as in P2; 10.120.210.1 via PROD_MCX_L3OUT; 30 subnets on PROD_MCX_L3OUT_EXT_EPG, each with scope import-security only (3.2); PROD_MCX_L3OUT_EXT_EPG provides ALLOW_ALL_CNTRCT only, state formed (3.1).

### 3.6 - FortiGates and EX4650s with fabric routes present (Part 1 Verify 2.2 stage 2, 2.4, 4.12 and 4.13)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**What:** Check what the FortiGates advertise to Azure, GCP, Vodafone and mcx_sdwan_np now that fabric routes exist, the next hop of a fabric subnet in every VDOM, and what the EX4650s send to mcx_sdwan_np.

**Why:** These checks need fabric routes, so they couldn't be run in Part 1.

**MCX-LD5-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.118.122 advertised-routes
get router info bgp neighbors 10.156.118.126 advertised-routes
get router info bgp neighbors 169.254.52.89 advertised-routes
get router info bgp neighbors 169.254.41.201 advertised-routes
get router info bgp neighbors 10.156.118.135 advertised-routes
get router info bgp neighbors 10.156.118.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.118.114 advertised-routes | grep 10.141.2.
get router info bgp network 10.158.50.0/24
end
```

**MCX-LD5-FGT2600-01 (Part 1 step 1.4: firewall policy for traffic from the fabrics)**

```
config vdom
edit mcx_cc
diagnose firewall iprope lookup <fabric host IP> 1024 <Azure host IP> 443 tcp ae3.800
diagnose firewall iprope lookup <fabric host IP> 1024 <GCP host IP> 443 tcp ae3.800
end
```

**MCX-LD8-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp neighbors 10.156.246.122 advertised-routes
get router info bgp neighbors 10.156.246.126 advertised-routes
get router info bgp neighbors 169.254.130.41 advertised-routes
get router info bgp neighbors 169.254.27.249 advertised-routes
get router info bgp neighbors 10.156.246.135 advertised-routes
get router info bgp neighbors 10.156.246.114 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.146 advertised-routes | grep Total
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.96.3.70
get router info bgp neighbors 10.156.246.114 advertised-routes | grep 10.141.2.
get router info bgp network 10.158.50.0/24
end
```

**MCX-LD5-EX4650-INNER-01**

```
show route advertising-protocol bgp 10.156.118.129 table mcx_vrf.inet.0 10.158.50.0/24 detail | no-more
show route advertising-protocol bgp 10.156.118.135 table mcx_vrf.inet.0 | no-more
```

**MCX-LD8-EX4650-INNER-01**

```
show route advertising-protocol bgp 10.156.246.129 table mcx_vrf.inet.0 10.158.50.0/24 detail | no-more
show route advertising-protocol bgp 10.156.246.135 table mcx_vrf.inet.0 | no-more
```

**Expected:** as below, on both FortiGates.

**Azure:** gets the fabric subnets (/16 to /28, no /29 to /32) plus its existing routes. LD5 metric 100; LD8 64636 x3, metric 200.

**GCP 230:** with GCP-OUT-V3 it gets the fabric subnets learned from the EX4650s and no fabric range learned from Vodafone (LD5 metric 100; LD8 64636 x3, metric 250), and still 10.0.0.0/8. LD8 also sends 172.16.0.0, 172.17.0.0 and 172.24.0.0 (GCP-AGGREGATE).

**GCP 240 (Active):** nothing.

**Vodafone:** totals unchanged from P5, and 10.96.3.70/32, 10.141.2.11/32 and 10.141.2.34/32 still advertised.

**Next hop:** 10.158.50.0/24 has next hop 10.156.118.136 (LD5) / 10.156.246.136 (LD8), valid, with Nexthop Self towards mcx_cc.

**mcx_sdwan_np:** gets the fabric subnets and no /32. From LD8 they have 64636 64636 64636 in front.

**Other VDOMs:** run get router info bgp network 10.158.50.0/24 in mcx_lan, mcx_dia, mcx_partner, mcx_s2s, mcx_c2s and mcx_3p_vrf4 on both FortiGates. Same next hop, valid.

**Expected (iprope):** each lookup matches the same policy ID as the mcx_vf_onprem policy that allows that flow today. Use a fabric host and an Azure / GCP host that an existing policy allows. mcx_cc is in policy-based NGFW mode; if the lookup returns nothing useful, V5 covers it.

*Note: Put only day numbers in this plan, actual dates into the Helix Change Record*

# Post Change Validation Testing

**Confirmation** (does not include hyper care)

### V1 - BGP and BFD: all sessions up, no flaps for 30 minutes

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**MCX-LD5-EX4650-INNER-01**

```
show bgp summary instance mcx_vrf | no-more
show bfd session | no-more
```

**MCX-LD8-EX4650-INNER-01**

```
show bgp summary instance mcx_vrf | no-more
show bfd session | no-more
```

### V2 - EX4650 routes: each fabric subnet accepted only from a site that owns it, and only MCX-TO-ACI sent

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**MCX-LD5-EX4650-INNER-01**

```
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.242 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.210 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.156.255.202 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.156.255.202 table mcx_vrf.inet.0 | no-more
```

**MCX-LD8-EX4650-INNER-01**

```
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 | no-more
show route receive-protocol bgp 10.158.240.246 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.157.240.214 table mcx_vrf.inet.0 hidden | no-more
show route receive-protocol bgp 10.156.255.201 table mcx_vrf.inet.0 | no-more
show route advertising-protocol bgp 10.156.255.201 table mcx_vrf.inet.0 | no-more
```

**Expected:** from the fabric peers, only Appendix A subnets and no /32 (host routes are off): 37 active from each SWI peer and 45 from each UXB peer. Hidden: from the SWI peers only subnets inside 10.157.0.0/16, from the UXB peers only SWI-owned subnets. To the fabric peers, only MCX-TO-ACI. On vlan 729 (10.156.255.201 / .202): the routes as at the end of the LD8 change (site and management ranges, no 172.16, 172.17 or 172.24), plus the SWI and UXB fabric subnets (AS path ending 64631 or 64633).

### V3 - ACI leaf routes: MCX, Azure, GCP and 172.x prefixes via PROD_MCX_L3OUT, LD5 at 200 and LD8 at 100, no default from MCX (as 3.5)

*Day 1 · Duration 00:15 · Owner: Network Engineer*

### V4 - FortiGates: every VDOM has the fabric routes from the EX4650; Azure, GCP and Vodafone as in 3.6

*Day 1 · Duration 00:15 · Owner: Network Engineer*

**MCX-LD5-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp network 10.158.0.0/16
get router info bgp network 10.157.0.0/16
end
```

**MCX-LD8-FGT2600-01**

```
config vdom
edit mcx_cc
get router info bgp network 10.158.0.0/16
get router info bgp network 10.157.0.0/16
end
```

**Expected:** in mcx_cc and in every other VDOM (mcx_lan, mcx_partner, mcx_dia, mcx_s2s, mcx_c2s, mcx_sdwan_np, mcx_3p_vrf4) the fabric routes via the EX4650 (10.156.118.136 / 10.156.246.136).

### V5 - Migrated bridge domains: ping and traceroute from a host in a migrated bridge domain to an MCX host, an Azure host, a GCP host and a GIST VPN address (test hosts agreed with the apps team before the change); return traffic follows the same path; applications reconnected after the session reset

*Day 1 · Duration 01:00 · Owner: Network Engineer*

### V6 - EX4650 irb filter counters: no unexpected drops

*Day 1 · Duration 00:05 · Owner: Network Engineer*

**MCX-LD5-EX4650-INNER-01**

```
show firewall filter FROM-FABRIC-725
show firewall filter FROM-FABRIC-727
```

**MCX-LD8-EX4650-INNER-01**

```
show firewall filter FROM-FABRIC-726
show firewall filter FROM-FABRIC-728
```

### V7 - Route counts within the prefix limits, no warnings

*Day 1 · Duration 00:05 · Owner: Network Engineer*

**MCX-LD5-EX4650-INNER-01**

```
show route summary table mcx_vrf.inet.0 | no-more
show bgp neighbor 10.158.240.242 instance mcx_vrf | match "State:|prefixes|limit"
show bgp neighbor 10.157.240.210 instance mcx_vrf | match "State:|prefixes|limit"
```

**MCX-LD8-EX4650-INNER-01**

```
show route summary table mcx_vrf.inet.0 | no-more
show bgp neighbor 10.158.240.246 instance mcx_vrf | match "State:|prefixes|limit"
show bgp neighbor 10.157.240.214 instance mcx_vrf | match "State:|prefixes|limit"
```

**Mandatory:** If Implementation has been validated successfully then update status of the Change in Helix to “Completed” – otherwise move on to Rollback

*Owner: Network Engineer*

*Note: Put only day numbers in this plan, actual dates into the Helix Change Record*

# Rollback

Complete Back-out and restore to previously good configuration (*Change Window ends*)

### Rollback row 1 - Roll back Phase 3 (fast stop first) to the state after 2.4: EX4650 hold and export, then NDO and APIC

*Day 1 · Duration 00:30 · Owner: Network Engineer*

**What:** Go back to the state after 2.4. Always do the EX4650s first. The bridge domains in Appendix A stay attached and held, with no traffic impact; row 2 detaches them.

**1. EX4650s (fast stop):** put the hold back (import DENY-ALL) and stop sending the MCX routes (export DENY-ALL), below. Commit MCX-LD8-EX4650-INNER-01 first, then MCX-LD5-EX4650-INNER-01, so traffic stays on LD5 until both are done. This takes seconds and puts both directions back on Cloud Connect.

**2. APIC SWI then APIC UXB:** delete default-import (Tenants > PROD_TNT > Networking > L3Outs > PROD_MCX_L3OUT > Route map for import and export route control > default-import > Delete).

**3. NDO, first deploy (stretched template, one deploy for SWI and UXB):** delete the 30 external subnets from 3.2. Check the subnet count is 0.

**4. NDO, second deploy:** remove ALLOW_ALL_CNTRCT as provider on PROD_MCX_L3OUT_EXT_EPG. Never before the first deploy: taking the contract off before the subnets would drop traffic to the 30 ranges.

**5. Check:** on each APIC, nothing is left.

**If 3.4 had been committed:** the EX4650 commits are a second short outage and open sessions are reset again.

**If 3.4 hadn't been committed:** the import lines change nothing, because import is already DENY-ALL.

**If only 3.0 was done:** the export lines on their own are enough.

**The reject policies from 2.5:** leave them in place. They aren't applied to anything once import is back to DENY-ALL. Row 2 removes them.

**MCX-LD5-EX4650-INNER-01**

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export MCX-TO-ACI-LD5
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export MCX-TO-ACI-LD5
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export DENY-ALL
show | compare
commit
```

**MCX-LD8-EX4650-INNER-01**

```
configure
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers import DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers import DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export MCX-TO-ACI
set routing-instances mcx_vrf protocols bgp group mcx-aci-swi-peers export DENY-ALL
delete routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export MCX-TO-ACI
set routing-instances mcx_vrf protocols bgp group mcx-aci-uxb-peers export DENY-ALL
show | compare
commit
```

**APIC SWI 10.158.254.10**

```
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
moquery -c rtctrlProfile -f 'rtctrl.Profile.dn*"out-PROD_MCX_L3OUT/"' | grep -c "^dn"
fabric 1701,1702 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extSubnet -f 'l3ext.Subnet.dn*"PROD_MCX_L3OUT_EXT_EPG"' | grep -c "^dn"
moquery -c rtctrlProfile -f 'rtctrl.Profile.dn*"out-PROD_MCX_L3OUT/"' | grep -c "^dn"
fabric 2703,2704 show ip route vrf PROD_TNT:PROD_VRF 10.156.118.129
```

**Expected:** subnet count 0; route map count 0; no route via PROD_MCX_L3OUT.

### Rollback row 2 - Full back-out of MCX DEA Part 2 (2.4 and change 2.1)

*Day 1 · Duration 02:30 · Owner: Network Engineer*

**What:** After row 1, detach the bridge domains attached in 2.4 from PROD_MCX_L3OUT: in NDO and deploy, and on APIC UXB for UXB_PROD_1700_BD (count 0 on both APICs, as change 2.1 rollback row 1). Delete the 2.5 policies and prefix lists on both EX4650s (below). Then run rollback rows 2 and 3 of change 2.1 (V2.1.10): step 2.2 (EX4650 import back to FABRIC-RANGES) and Phase 1 (FortiGate peers back to the V3 or original maps, GCP-OUT-V3 deleted).

**Why:** Only needed if change 2.1 must be backed out as well. Row 1 on its own returns to the state after 2.4, which has no traffic impact and can stay in place until the switch-over is re-planned. PROD_MCX_L3OUT stays in the stretched template with no bridge domain attached and the sessions held, which is the end state of change 2.1 apart from the L3Out name and template. Run row 4 as well only if the L3Outs have to go back to the site-local templates.

**MCX-LD5-EX4650-INNER-01 and MCX-LD8-EX4650-INNER-01**

```
configure
delete policy-options policy-statement REJECT-UXB-OWNED
delete policy-options policy-statement REJECT-SWI-OWNED
delete policy-options prefix-list UXB-OWNED-BDS
delete policy-options prefix-list SWI-OWNED-BDS
show | compare
commit check
commit
```

**Rollback row 3:** **Not used.** Host routes (3.7) are not in this change, so there is nothing to roll back. The row number is kept so rows 1, 2 and 4 keep their numbers.

### Rollback row 4 - Roll back step 2.3: MCX L3Outs back in the site-local templates

*Day 1 · Duration 01:30 · Owner: Network Engineer*

**What:** Put MCX_L3OUT (SWI) and UXB_MCX_L3OUT (UXB) back as they were at the end of change 2.1. Only if 2.3 can't be completed or Verify 2.3 can't be made to pass. If any bridge domain was attached in 2.4, run row 2 first (and row 1 before that if Phase 3 was started). The stretched template copy goes first: vlans 725 to 728 can't be in two L3Outs on the same leaf.

1. NDO: in PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT delete External EPG PROD_MCX_L3OUT_EXT_EPG, then L3Out PROD_MCX_L3OUT > Save. Run the deployment plan (only those two, at SWI and UXB), then Deploy. If 2.3.2 wasn't reached, there is nothing to delete: carry on.

2. NDO: in SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT create L3Out MCX_L3OUT (Virtual Routing & Forwarding PROD_VRF) and External EPG MCX_L3OUT_EXT_EPG (PROD_VRF, ON-PREM, L3Out MCX_L3OUT, no contract, no subnet) > Save. Run the deployment plan (only those two), then Deploy.

3. NDO: in UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT create them with Display Names UXB_MCX_L3OUT and UXB_MCX_L3OUT_EXT_EPG, so those are the names on the APIC as before > Save. Run the deployment plan (only those two), then Deploy. The old display names there were MCX_L3OUT and MCX_L3OUT_EXT_EPG; leave the display names as UXB_MCX_L3OUT and UXB_MCX_L3OUT_EXT_EPG unless it has been confirmed that changing a display name doesn't rename the object on the APIC.

4. APIC SWI: under MCX_L3OUT, run lines 1 to 7 of 2.3.3 with the same values.

5. APIC UXB: under UXB_MCX_L3OUT, run lines 1 to 7 of 2.3.4 with the same values.

6. Run the commands below and compare with the 2.3.1 record.

**Why:** NDO can't move the L3Out back either, so the back-out is the same delete and build in the other direction. There is no traffic impact in either state: no bridge domain is attached and the EX4650 hold is in place. The fabric sessions are down again from line 1 until lines 4 and 5 are done.

**Not lab tested:** this back-out hasn't been run. If 2.3 was stopped before the 2.3.1 deploy, nothing needs rolling back.

**APIC SWI 10.158.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extOut -f 'l3ext.Out.name=="MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
fabric 1701,1702 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
fabric 1701,1702 show bfd neighbors vrf PROD_TNT:PROD_VRF
```

**APIC UXB 10.157.254.10**

```
moquery -c l3extOut -f 'l3ext.Out.name=="PROD_MCX_L3OUT"' | grep -c "^dn"
moquery -c l3extOut -f 'l3ext.Out.name=="UXB_MCX_L3OUT"' | grep -E "^dn|enforceRtctrl"
moquery -c l3extRsL3DomAtt -f 'l3ext.RsL3DomAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^tDn"
moquery -c bgpExtP -f 'bgp.ExtP.dn*"MCX_L3OUT/"' | grep -c "^dn"
moquery -c l3extRsNodeL3OutAtt -f 'l3ext.RsNodeL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^rtrId"
moquery -c l3extRsPathL3OutAtt -f 'l3ext.RsPathL3OutAtt.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^encap|^ifInstT|^mode|^mtu|^autostate|^descr|^mac"
moquery -c bgpPeerP -f 'bgp.PeerP.dn*"MCX_L3OUT/"' | grep -E "^dn|^addr|^peerCtrl|^ctrl|^ttl"
moquery -c bgpAsP -f 'bgp.AsP.dn*"MCX_L3OUT/"' | grep -E "^dn|^asn"
moquery -c bfdRsIfPol -f 'bfd.RsIfPol.dn*"MCX_L3OUT/"' | grep -E "^dn|tnBfdIfPolName"
fabric 2703,2704 show bgp ipv4 unicast summary vrf PROD_TNT:PROD_VRF
fabric 2703,2704 show bfd neighbors vrf PROD_TNT:PROD_VRF
```

**MCX-LD5-EX4650-INNER-01**

```
show bgp summary instance mcx_vrf | no-more
```

**MCX-LD8-EX4650-INNER-01**

```
show bgp summary instance mcx_vrf | no-more
```

**Expected:** PROD_MCX_L3OUT count 0 on both APICs; MCX_L3OUT at SWI and UXB_MCX_L3OUT at UXB with enforceRtctrl export,import and the build as in the 2.3.1 record; the EX4650 neighbours Established on the leafs with 0 prefixes received, BFD up; 11 peers Established on each EX4650; all three templates In Sync. This is the P2 state.

**Mandatory:** If validation failed and the change was rolled back, then update status of the Change in Helix to “Completed”

*Owner: Network Engineer*

*Note: Put only day numbers in this plan, actual dates into the Helix Change Record*

# Close Down

Within 7 days of Change Completing, you must update Helix and Close the change with the correct status:

| **\#** | **Task Description**                                                                                                                                                                | **Owner**                       |
|--------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| A      | **Successful**—The change request is closed because the request is successful.                                                                                                      | Change Coordinator              |
| B      | **Successful with Issues**—The change request is closed because the request is successful, but with issues.                                                                         | Change Coordinator              |
| C      | **Unsuccessful**—The change request is closed because the request is unsuccessful.                                                                                                  | Change Coordinator              |
| D      | **Backed Out—**The change request is closed because the request is backed out.                                                                                                      | Change Coordinator              |
| E      | **Auto Closed –** The change was auto closed by the system because the coordinator did not update their change within 7 days of completion, success will be reported as **Unknown** | Helix (Hannah Admin) Automation |

# Appendix A - Bridge domains in scope

The 62 bridge domains in tenant PROD_TNT that are on PROD_MIG_L3OUT and are attached to PROD_MCX_L3OUT in step 2.4 of this change, each at the site that owns it (change 2.1 step 2.3 was stopped on 19/11/2026 by the NDO template dependency and moved here). Source: aci_migrated_svis_v2.xlsx (moquery -c fvSubnet, fvRsBDToOut and fvBD on APIC SWI 10.158.254.10 and APIC UXB 10.157.254.10, 28/10/2026). Host routing is off on all of them and stays off in this change. Unicast routing is off at both sites on 5 of the 62 (PROD_3104_BD, SWI_PROD_1010_BD, SWI_PROD_1022_BD, SWI_PROD_1054_BD and SWI_PROD_1104_BD, checked 16/11/2026): ACI is not their gateway, so they advertise no subnet, get no host routes and keep their current gateway and path. SWI_PROD_2481_BD and SWI_NONPROD_3481_BD have their subnet on SWI only (the bridge domain and L3Out exist at both sites); UXB_PROD_1700_BD is at UXB only. The 7 with an L3Out other than PROD_MIG_L3OUT were checked in change 2.1 (P9).

Where they are managed (NDO and both APICs, 19/11/2026): rows 1 to 26 are stretched in PROD_SWI_UXB-STRTCHD_L3OUT_VRF_BD_EPG_APP-TMPLT. Rows 27 to 42 are deployed by NDO at SWINDON only (SWI_PROD_BD_EPG_APP_CONTRACT-TMPLT; rows 28 to 32 in SWI_NONPROD_CYBERARK_BD_EPG_APP_CONTRACT-TMPLT) and rows 43 to 61 at UXBRIDGE only (UXB_PROD_BD_EPG_APP_CONTRACT-TMPLT); the copy at the other site is an NDO shadow object and is left alone (which is why "Subnet at" shows both sites for them). Row 62 is on APIC UXB only. "Subnet at" below is as on the APICs. On 19/11/2026 the APICs gave 54 subnets from SWI and 53 from UXB that will be advertised once attached; 56 and 55 once PROD_3046_BD and PROD_3083_BD are migrated. From 3.4 the EX4650s accept 37 from each SWI peer and 45 from each UXB peer, because a one-site subnet is only accepted from the site that owns it (2.5).

| **\#**                       | **Bridge domain**                      | **Gateway / subnet**                       | **Subnet at**                         | **Attached in 2.4**        | **L3Outs today**                                                                                                     |
|------------------------------|----------------------------------------|--------------------------------------------|---------------------------------------|-------------------------------|----------------------------------------------------------------------------------------------------------------------|
| 1                            | NONPROD_129_BD                         | 10.96.129.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 2                            | NONPROD_130_BD                         | 10.96.130.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 3                            | NONPROD_132_BD                         | 10.96.132.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 4                            | NONPROD_137_BD                         | 10.96.137.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 5                            | NONPROD_139_BD                         | 10.96.139.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 6                            | NONPROD_140_BD                         | 10.96.140.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 7                            | NONPROD_141_BD                         | 10.96.141.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 8                            | NONPROD_142_BD                         | 10.96.142.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 9                            | NONPROD_143_BD                         | 10.96.143.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 10                           | NONPROD_2015_BD                        | 10.99.15.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 11                           | NONPROD_2026_BD                        | 10.99.26.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 12                           | NONPROD_2027_BD                        | 10.99.27.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 13                           | NONPROD_2041_BD                        | 10.99.41.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 14                           | NONPROD_2052_BD                        | 10.99.52.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 15                           | NONPROD_2092_BD                        | 10.99.92.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 16                           | PROD_2022_BD                           | 10.99.22.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 17                           | PROD_2056_BD                           | 10.99.56.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 18                           | PROD_2341_BD                           | 10.100.41.254/24                           | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 19 | PROD_3022_BD | 10.141.22.254/24 | SWI and UXB | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                             |
| 20 | PROD_3046_BD | 10.141.46.254/24 | SWI and UXB | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                             |
| 21 | PROD_3056_BD | 10.141.56.254/24 | SWI and UXB | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                             |
| 22 | PROD_3083_BD | 10.141.83.254/24 | SWI and UXB | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                             |
| 23 | PROD_3096_BD | 10.141.96.254/24 | SWI and UXB | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                             |
| 24 | PROD_3104_BD                           | 10.141.104.254/24                          | SWI and UXB                           | NDO, SWI and UXB (unicast routing off) | PROD_MIG_L3OUT                                                                                                       |
| 25 | PROD_VLAN2014_BD                       | 10.99.14.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 26 | PROD_VLAN2080_BD                       | 10.99.80.254/24                            | SWI and UXB                           | NDO, SWI and UXB | PROD_MIG_L3OUT                                                                                                       |
| 27 | SWI_NONPROD_3481_BD                    | 10.96.148.14/28                            | SWI only                              | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 28 | SWI_NONPROD_CYBERARK_T0_CPMPSM_BD      | 10.96.147.30/27                            | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 29 | SWI_NONPROD_CYBERARK_T0_DISC_BD        | 10.96.147.142/28                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 30 | SWI_NONPROD_CYBERARK_T0_SIA_BD         | 10.96.147.62/27                            | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 31 | SWI_NONPROD_CYBERARK_T1_CPMPSM_BD      | 10.96.147.94/27                            | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 32 | SWI_NONPROD_CYBERARK_T1_SIA_BD         | 10.96.147.126/27                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 33 | SWI_PROD_1010_BD                       | 10.158.10.254/24                           | SWI and UXB                           | NDO, SWI (unicast routing off) | PROD_MIG_L3OUT                                                                                                       |
| 34 | SWI_PROD_1022_BD                       | 10.158.22.254/24                           | SWI and UXB                           | NDO, SWI (unicast routing off) | PROD_MIG_L3OUT                                                                                                       |
| 35 | SWI_PROD_1050_BD                       | 10.158.50.254/24                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 36 | SWI_PROD_1051_BD                       | 10.158.51.254/24                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 37 | SWI_PROD_1053_BD                       | 10.158.53.254/24                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 38 | SWI_PROD_1054_BD                       | 10.158.54.254/24                           | SWI and UXB                           | NDO, SWI (unicast routing off) | PROD_MIG_L3OUT                                                                                                       |
| 39 | SWI_PROD_1099_BD                       | 10.158.99.254/24                           | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 40 | SWI_PROD_1104_BD                       | 10.158.104.254/24                          | SWI and UXB                           | NDO, SWI (unicast routing off) | PROD_MIG_L3OUT                                                                                                       |
| 41 | SWI_PROD_2059_BD                       | 10.99.59.254/24                            | SWI and UXB                           | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 42 | SWI_PROD_2481_BD                       | 10.158.148.14/28                           | SWI only                              | NDO, SWI | PROD_MIG_L3OUT                                                                                                       |
| 43 | UXB_PROD_1481_BD                       | 10.157.148.14/28                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 44 | UXB_PROD_1510_BD                       | 10.157.10.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_CC_L3OUT, COMMON_VRF1_L3OUT, COMMON_PARTNER_IN_L3OUT                                          |
| 45 | UXB_PROD_1522_BD                       | 10.157.22.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_VRF1_L3OUT                                                                                    |
| 46 | UXB_PROD_1550_BD                       | 10.157.50.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 47 | UXB_PROD_1551_BD                       | 10.157.51.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 48 | UXB_PROD_1553_BD                       | 10.157.53.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 49 | UXB_PROD_1554_BD                       | 10.157.54.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 50 | UXB_PROD_1555_BD                       | 10.157.55.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 51 | UXB_PROD_1556_BD                       | 10.157.56.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 52 | UXB_PROD_1557_BD                       | 10.157.57.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 53 | UXB_PROD_1558_BD                       | 10.157.58.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 54 | UXB_PROD_1564_BD                       | 10.157.64.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_VRF1_L3OUT                                                                                    |
| 55 | UXB_PROD_1565_BD                       | 10.157.65.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 56 | UXB_PROD_1566_BD                       | 10.157.66.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_VRF1_L3OUT                                                                                    |
| 57 | UXB_PROD_1575_BD                       | 10.157.75.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_CC_L3OUT, COMMON_VRF1_L3OUT, COMMON_VRF4_IN_L3OUT, COMMON_PARTNER_IN_L3OUT, PROD_DIA_IN_L3OUT |
| 58 | UXB_PROD_1576_BD                       | 10.157.76.254/24                           | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT, COMMON_CC_L3OUT, COMMON_VRF1_L3OUT, COMMON_VRF4_IN_L3OUT, COMMON_PARTNER_IN_L3OUT                    |
| 59 | UXB_PROD_1604_BD                       | 10.157.104.254/24                          | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 60 | UXB_PROD_1651_BD                       | 10.157.151.254/24                          | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 61 | UXB_PROD_1658_BD                       | 10.157.158.254/24                          | SWI and UXB                           | NDO, UXB | PROD_MIG_L3OUT                                                                                                       |
| 62 | UXB_PROD_1700_BD                       | 10.157.200.254/24                          | UXB only                              | APIC UXB | PROD_MIG_L3OUT, UXB_PROD_DMZ_833_L3OUT                                                                               |

Not in scope: UXB_PROD_1552_BD, PROD_1594_BD, SWI_PROD_1052_BD and UXB_PROD_1584_BD (SVI but no L3Out; UXB_PROD_1584_BD accepted with no return path, see Potential Impact of Change), UXB_PROD_TEST_1_BD (test object) and the PREP_TNT bridge domains.

Not in scope (found on PROD_MIG_L3OUT on 11/11/2026, after the 28/10/2026 check; aci_migrated_svis_v3.xlsx): PROD_2060_BD (10.99.60.254/24), PROD_2062_BD (10.99.62.254/24), PROD_3041_BD (10.141.41.254/24), SWI_NONPROD_1303_BD (10.151.130.254/24), UXB_PROD_CYBERARK_T0_CPMPSM_BD (10.157.67.30/27), UXB_PROD_CYBERARK_T0_DISC_BD (10.157.67.142/28), UXB_PROD_CYBERARK_T0_SIA_BD (10.157.67.62/27), UXB_PROD_CYBERARK_T1_CPMPSM_BD (10.157.67.94/27) and UXB_PROD_CYBERARK_T1_SIA_BD (10.157.67.126/27). They are not attached to PROD_MCX_L3OUT by this change and stay on PROD_MIG_L3OUT.
