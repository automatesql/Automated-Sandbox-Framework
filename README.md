# Automated Sandbox Framework

### Introduction
I built this framework to quickly spin up sandbox environments without needing to install Windows each time manually.  It's also used by students in my courses hosted at https://www.automatesql.com, focusing on SQL Server builds using Ansible.

The **Automated Sandbox Framework** provides all the resources you need—HashiCorp Packer HCL templates, PowerShell scripts, autounattend files, and Vagrantfiles—to build fully automated virtual sandbox environments.

By default, it creates a Windows Server 2025 Standard Evaluation image with SSH enabled. On the first boot, each VM is sysprepped to ensure a unique SID is generated.

The included Vagrantfile can create 5 virtual machines. Consider setting up a domain controller (DC1) for a more realistic scenario.  Additional secondary disks can be added manually using the VMware Workstation Pro GUI or by configuring the vagrant file to use the Vagrant [Disk](https://developer.hashicorp.com/vagrant/docs/disks/configuration).  However, it's not currently included.

**Example Machine Roles:**
- **DC1:** Domain Controller
- **SRV1:** Jumpbox/Tools Host
- **SQL1:** SQL Server Developer
- **SQL2:** SQL Server Developer
- **SQL3:** SQL Server Developer

---

## Prerequisites

1. **Host OS:** Windows 11  
   - Disable Hyper-V.  
   - Ensure nested virtualization is supported.  
   See [this link](https://community.broadcom.com/vmware-cloud-foundation/communities/community-home/digestviewer/viewthread?MessageKey=e6e27471-43e1-48e7-a355-abe6dd78428d&CommunityKey=fb707ac3-9412-4fad-b7af-018f5da56d9f) for details.

2. **Hardware:**  
   - **CPU:** x64 with virtualization support  .
   - **Memory:** 16 GB minimum (more may be needed to support larger environments).
   - **Storage:** At least 128 GB free.

---

### Required Software

1. [VMware Workstation Pro 17 (How to install using Chocolatey)](https://www.youtube.com/watch?v=CidERWH9YdE)
2. [HashiCorp Packer](https://www.packer.io/)
3. [HashiCorp Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)
4. [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility)
5. [Vagrant VMware Desktop Plugin](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation)
6. [Windows Server 2025 Evaluation ISO](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025?msockid=013313bebd1a61271b96073fbc7a603d)

---

## Building the Windows Server 2025 Evaluation Image

The `win2025.pkr.hcl` template leverages Packer to:
- Install and update Windows Server 2025 automatically.
- Install VMware Tools.
- Enable SSH access.
- Package everything into a Vagrant `.box` file, eliminating manual setup.

**Key Points:**
- Requires `vmware` and `vagrant` Packer plugins.
- Uses variables for customization (`iso_checksum`, `memsize`, `numvcpus`, etc.).
- Employs the `vmware-iso` builder and multiple provisioners (PowerShell scripts, file uploads, restarts).
- A final post-processor creates the `.box` file.

---

### Adjusting Autounattend and Unattend Files

1. **Password:**  
   Update the default password ("packer") at:  
   - `scripts/autounattend.xml`: Lines 144, 177  
   - `scripts/unattend.xml`: Lines 64, 98

2. **Time Zone:**  
   Edit `unattend.xml` to set your preferred time zone (the default is Central Standard Time).

3. **Windows Server Edition:**  
   By default, the template uses Standard Evaluation (Index 2). Modify `Autounattend.xml` if you need a different edition:  
   - Index 1: Windows Server 2025 Standard Evaluation  
   - Index 2: Windows Server 2025 Standard Evaluation (Desktop Experience)  
   - Index 3: Windows Server 2025 Datacenter Evaluation  
   - Index 4: Windows Server 2025 Datacenter Evaluation (Desktop Experience)

---

### Updating `variables.pkrvars.hcl`

- Update `iso_checksum`. To get the iso checksum, use `Get-FileHash pathToISO` in PowerShell.
- Adjust other variables as needed.

---

### Running `packer init`

Before building, run `packer init` to fetch the required plugins:

```cmd
cd path\to\win2025.pkr.hcl
packer init win2025.pkr.hcl
```

### Running packer build
#### Build the .box file.
Start VMware Workstation Pro prior to running packer build.

```cmd
cd path\to\win2025.pkr.hcl
packer build --var-file="variables.pkrvars.hcl" win2025.pkr.hcl
```

This step will take several minutes to complete. You'll see the image being built in VMware Workstation Pro.

## Using the vagrantfile to build your sandbox.
The example vagrantfile will create 5 VMs.  Modify the machines array as needed:

```ruby
machines = [ 
  { name: "DC1", memory: 4096, cpus: 4, vnet: "VMnet8", nat_device: "vmnet8", additional_disks: "FALSE" },
  { name: "SRV1", memory: 8192, cpus: 4, vnet: "VMnet8", nat_device: "vmnet8", additional_disks: "FALSE" },
  { name: "SQL1", memory: 8192, cpus: 8, vnet: "VMnet8", nat_device: "vmnet8", additional_disks: "TRUE" },
  { name: "SQL2", memory: 8192, cpus: 8, vnet: "VMnet8", nat_device: "vmnet8", additional_disks: "TRUE" },
  { name: "SQL3", memory: 8192, cpus: 8, vnet: "VMnet8", nat_device: "vmnet8", additional_disks: "TRUE" }
]
```
- Set config.vm.box to the path of your new .box file.
- Set config.ssh.password to the password used during image creation.

### Running vagrant up
Open either a command window and navigate to the directory where the vagrantfile resides.

- Run `vagrant up`.

VMware Workstation will create the VMs. Expect a few reboots on the initial run. Subsequent startups will be much faster.

- To shut down all VMs, run `vagrant halt`.

- To completely destroy all VMs created by this vagrantfile run `vagrant destroy`.

For more vagrant commands see this [link](https://developer.hashicorp.com/vagrant/docs)

This framework dramatically reduces manual setup time, making it easy to spin up multiple, fully configured Windows Server environments for testing, development, or lab scenarios.

### Screenshot of virtual environment
<img width="800" alt="ASF_Virtual_Environment" src="https://github.com/user-attachments/assets/d7c11166-40d3-43aa-a402-ffa14454408e" />

