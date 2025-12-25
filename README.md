# Enterprise Hybrid Identity & Active Directory Security Lab

## Project Overview
A fully virtualized corporate network environment designed to simulate real-world identity management and network security operations. This lab integrates **Windows Server 2022 (Active Directory)** with **Linux (Ubuntu)** clients, enforces network segmentation using **pfSense**, and extends into a **Hybrid Cloud** architecture using **Microsoft Entra ID**.

**Goal:** To engineer a secure, cross-platform infrastructure adhering to Zero Trust, Least Privilege, and Defense-in-Depth principles, utilizing **PowerShell automation** and **Conditional Access** for modern identity security.

---

## Architecture & Topology
* **Hypervisor:** VirtualBox
* **Cloud Identity:** Microsoft Entra ID (formerly Azure AD)
* **Firewall/Router:** pfSense (WAN/LAN Separation)
* **Domain Controller:** Windows Server 2022 (DNS, DHCP, AD DS, Entra Connect)
* **Endpoints:** Ubuntu Server 22.04 (Joined to Domain)

![Virtual Environment Setup](lab-topology.png)
*Figure 1: Virtual machine inventory running consistently with network isolation.*

---

## Key Implementations

### 1. Network Segmentation & Hardening (pfSense)
Configured strict firewall rules to isolate traffic.
* **Rule Implemented:** Blocked management interface access (port 443) from general LAN subnets to prevent internal privilege escalation attempts.
* **Verification:** Verified traffic flow using firewall logs.

![Firewall Rules](pfsense-firewall-rules.png)
*Figure 2: Custom LAN rules blocking management access while allowing standard traffic.*

### 2. Active Directory Configuration
* Established a new forest `corp.local`.
* Created Organizational Units (OUs) for "IT Department" to segregate administrative accounts.
* Created user accounts for simulation (e.g., `Muhammad Javed`).

![AD Users](ad-users.png)
*Figure 3: Active Directory Users and Computers showing the IT Department structure.*

### 3. Cross-Platform Integration (SSSD & Realmd)
Successfully joined Ubuntu Linux servers to the Windows Active Directory domain using `SSSD` and `Realmd`.
* **Result:** Enabled centralized authentication. Users can log into Linux servers using their AD credentials.
* **Verification:** The `id` command below confirms the user `admin_javed` is recognized as a `domain admin` with sudo privileges.

![Linux Integration](linux-ad-integration.png)
*Figure 4: Terminal output proving the Linux machine is querying the AD Domain Controller for user groups.*

### 4. Identity Lifecycle Automation (PowerShell)
Developed a custom PowerShell toolset (`onboard.ps1` and `offboard.ps1`) to automate the onboarding, offboarding, and re-hiring of employees.
* **Dynamic Provisioning:** The script reads raw employee data (CSV), automatically detects the department, creates the necessary **Organizational Units (OUs)** if they don't exist, and provisions the user.
* **Logic Handling:** Implemented error handling to detect duplicate users and **"Re-Hire" logic** to reactivate disabled accounts, reset passwords, and move them back to their active departments.
* **Audit Stamping:** Scripts automatically update the user's Description field with timestamps (e.g., "HIRED on 2025-12-07 via Automation").

![Automation Success](automation-script.png)
*Figure 5: PowerShell output showing successful dynamic user creation and folder generation.*

### 5. Hybrid Identity (Microsoft Entra Connect)
Bridged the on-premise Active Directory environment with the Cloud.
* **Implementation:** Deployed **Microsoft Entra Connect** on the Windows Server 2022 Domain Controller.
* **Sync Configuration:** Enabled **Password Hash Sync (PHS)**, allowing users to use their on-premise passwords to access cloud resources.
* **Result:** Achieved unified identity; creating a user in Active Directory automatically provisions them in Microsoft Entra ID.

![Entra Connect Sync](entra-sync-verify.png)
*Figure 6: Entra Admin Center showing users successfully synced from "Windows Server AD".*

### 6. Zero Trust Security (Conditional Access)
Implemented "Identity as the Firewall" using **Entra ID P2** licensing.
* **Geofencing Policy:** Configured a Conditional Access Policy to block authentication attempts originating from outside the United States.
* **Validation:** Used the **"What If"** simulation tool to test login attempts from high-risk regions (e.g., China, Russia), confirming that the policy successfully denies access while permitting US-based traffic.

![Conditional Access Block](conditional-access-block.png)
*Figure 7: "What If" simulation confirming the Geofencing policy blocks international access.*

---

## Skills Demonstrated
* **Cloud Security:** Hybrid Identity, Microsoft Entra Connect, Password Hash Sync, Azure AD.
* **Zero Trust Architecture:** Conditional Access Policies, Geofencing, Identity Protection.
* **Identity & Access Management:** AD DS, User Provisioning, Group Policy.
* **Network Security:** Firewall Rule Configuration, VLANs, Port Hardening.
* **Linux System Administration:** SSSD, PAM, Domain Joining, Sudoers management.
* **PowerShell Scripting:** Automating bulk administrative tasks, handling logic loops, CSV parsing.
