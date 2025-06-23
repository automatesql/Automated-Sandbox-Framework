# Pre-Check Script for the Automated-Sandbox-Framework
# This script checks for prerequisites and potential issues before setting up the lab environment.
# Must be run as an Administrator

Write-Host "--- Automated-Sandbox-Framework Environment Pre-Check ---" -ForegroundColor Yellow
Write-Host "This script will check your system for potential issues with the lab setup."
Write-Host "Please run this script as an Administrator."
Write-Host ""

# --- Check 1: Administrator Privileges ---
Write-Host "1. Checking for Administrator Privileges..." -ForegroundColor Cyan
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "   [FAIL] This script must be run as an Administrator. Please re-run in an elevated PowerShell terminal." -ForegroundColor Red
    exit
}
Write-Host "   [PASS] Script is running with Administrator privileges." -ForegroundColor Green

# --- Check 2: Hardware Virtualization ---
Write-Host "2. Checking for Hardware Virtualization Support..." -ForegroundColor Cyan
$systemInfo = systeminfo.exe
if ($systemInfo -match "Virtualization Enabled in Firmware: Yes") {
    Write-Host "   [PASS] Hardware virtualization (Intel VT-x / AMD-V) is enabled in the BIOS/UEFI." -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Hardware virtualization is not enabled in your BIOS/UEFI. You will need to reboot your computer, enter the BIOS/UEFI settings, and enable 'Intel VT-x' or 'AMD-V'." -ForegroundColor Red
}

# --- Check 3: Conflicting Windows Features ---
Write-Host "3. Checking for conflicting Windows features..." -ForegroundColor Cyan
$hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
$vmPlatform = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
$wsl = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($hyperV.State -eq 'Enabled' -or $vmPlatform.State -eq 'Enabled') {
    Write-Host "   [FAIL] Hyper-V or the Virtual Machine Platform is enabled. These conflict with VMware Workstation." -ForegroundColor Red
    Write-Host "   To fix, run the following commands in an elevated PowerShell terminal and reboot:" -ForegroundColor Yellow
    Write-Host "   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All"
    Write-Host "   Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
} else {
    Write-Host "   [PASS] Hyper-V and Virtual Machine Platform are disabled." -ForegroundColor Green
}

if ($wsl.State -eq 'Enabled') {
    Write-Host "   [INFO] Windows Subsystem for Linux (WSL) is enabled. If you encounter issues, you may need to disable it." -ForegroundColor Yellow
    Write-Host "   To disable, run: Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux"
}

# --- Check 4: Core Isolation (Memory Integrity) ---
Write-Host "4. Checking for Core Isolation (Memory Integrity)..." -ForegroundColor Cyan
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
if ((Get-ItemProperty -Path $regKey -Name "Enabled" -ErrorAction SilentlyContinue).Enabled -eq 1) {
    Write-Host "   [FAIL] Core Isolation (Memory Integrity) is enabled. This feature uses virtualization and can conflict with VMware Workstation." -ForegroundColor Red
    Write-Host "   To fix, go to Start > Settings > Privacy & security > Windows Security > Device security > Core isolation details, and turn 'Memory integrity' off. A reboot will be required." -ForegroundColor Yellow
} else {
    Write-Host "   [PASS] Core Isolation (Memory Integrity) is disabled." -ForegroundColor Green
}

# --- Check 5: VMware Workstation Installation ---
Write-Host "5. Checking for VMware Workstation Installation..." -ForegroundColor Cyan
$vmwareInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "VMware Workstation*" }
if ($vmwareInstalled) {
    Write-Host "   [PASS] VMware Workstation is installed." -ForegroundColor Green

    # --- Check 6: VMware Services ---
    Write-Host "6. Checking VMware Services..." -ForegroundColor Cyan
    $authdService = Get-Service -Name "VMAuthdService" -ErrorAction SilentlyContinue
    $usbArbService = Get-Service -Name "VMUSBArbService" -ErrorAction SilentlyContinue

    if ($authdService.Status -eq 'Running' -and $usbArbService.Status -eq 'Running') {
        Write-Host "   [PASS] Required VMware services are running." -ForegroundColor Green
    } else {
        Write-Host "   [FAIL] One or more required VMware services are not running." -ForegroundColor Red
        Write-Host "   To fix, open the Services application, find 'VMware Authorization Service' and 'VMware USB Arbitration Service', and start them." -ForegroundColor Yellow
    }
} else {
    Write-Host "   [INFO] VMware Workstation does not appear to be installed. Please install it before proceeding with the lab setup." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- Pre-Check Complete ---" -ForegroundColor Yellow