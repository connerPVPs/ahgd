$workspace = (Get-Location).Path
$ngrokDir  = Join-Path $workspace "ngrok-tools"
$ngrokExe  = Join-Path $ngrokDir "ngrok.exe"

# ---- RDP ----
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Set-Service TermService -StartupType 'Automatic'
Start-Service TermService
Start-Sleep -Seconds 3

# ---- RDP user ----
$pass = ConvertTo-SecureString "RDPpassword!" -AsPlainText -Force
if (-not (Get-LocalUser -Name "RDPUser" -ErrorAction SilentlyContinue)) {
  New-LocalUser -Name "RDPUser" -Password $pass -Description "RDP User"
}
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "RDPUser" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators"      -Member "RDPUser" -ErrorAction SilentlyContinue

# ---- ngrok (download once, persists in workspace) ----
if (-not (Test-Path $ngrokExe)) {
  Write-Host "Downloading ngrok..."
  New-Item -ItemType Directory -Path $ngrokDir -Force | Out-Null
  $zip = Join-Path $ngrokDir "ngrok.zip"
  Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $ngrokDir -Force
  Remove-Item $zip
}
& $ngrokExe config add-authtoken $env:NGROK_AUTH_TOKEN | Out-Null

# ---- start tunnel ----
Start-Process -FilePath $ngrokExe -ArgumentList "tcp","3389" -NoNewWindow

# ---- grab URL ----
$url = $null
$deadline = (Get-Date).AddSeconds(30)
while ((Get-Date) -lt $deadline -and -not $url) {
  Start-Sleep -Seconds 2
  try {
    $api = Invoke-RestMethod http://localhost:4040/api/tunnels -ErrorAction SilentlyContinue
    if ($api.tunnels.Count -gt 0) {
      $url = $api.tunnels[0].public_url -replace '^tcp://',''
    }
  } catch {}
}

if (-not $url) { throw "ngrok did not start within 30s" }

Write-Host ""
Write-Host "==========================================="
Write-Host "  RDP Server is LIVE!"
Write-Host ""
Write-Host "  Host:     $url"
Write-Host "  Username: RDPUser"
Write-Host "  Password: RDPpassword!"
Write-Host "==========================================="
Write-Host "  Files persist at: $workspace"
Write-Host "==========================================="
