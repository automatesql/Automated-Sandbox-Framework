# Source: https://github.com/eaksel/packer-Win2022/blob/main/scripts/vmware-tools.ps1\
<#
MIT License

Copyright (c) 2021 eaksel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>
$ProgressPreference = "SilentlyContinue"

$webclient = New-Object System.Net.WebClient
$version_url = "https://packages.vmware.com/tools/releases/latest/windows/x64/"
$raw_package = $webclient.DownloadString($version_url)
$raw_package -match "VMware-tools[\w-\d\.]*\.exe"
$package = $Matches.0

$url = "https://packages.vmware.com/tools/releases/latest/windows/x64/$package"
$exe = "$Env:TEMP\$package"

Write-Output "***** Downloading VMware Tools"
$webclient.DownloadFile($url, $exe)

$parameters = '/S /v "/qn REBOOT=R ADDLOCAL=ALL"'

Write-Output "***** Installing VMware Tools"
Start-Process $exe $parameters -Wait

Write-Output "***** Deleting $exe"
Remove-Item $exe