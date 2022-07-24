###################################################################
#                                                                 #
#                     PowerShell Profile                          #
#                                                                 #
###################################################################


#Touch: Create empty file
<#
.DESCRIPTION
    Erstellt eine leere Datei oder aktualisiert das Zugriffsdatum einer existierenden Datei (Äquivalent zum "touch"-Befehl auf Linux)
.PARAMETER path
    Der Pfad der Datei
#>
function touch($path){
    if ($(test-path $path)) {
        echo $null >> $path
    } else {
        New-Item $path | out-null
    }
}

# Filefind: Search for string in current directory
<#
.DESCRIPTION
    Sucht Vorkommnisse des gegebenen Strings im aktuellen Verzeichnis.
.PARAMETER search
    Der String, nach dem gesucht werden soll.
.PARAMETER Recurse
    Entscheidet, ob Unterverzeichnisse durchsucht werden sollen
.PARAMETER List
    Gibt jede Datei nur einmal an.
#>
function filefind(){
    param(
        [string]$search = "",
        [switch]$Recurse=$true,
        [switch]$List
    )
    $files = ""
    if ($Recurse) 
        { $files = Get-ChildItem -Recurse} 
    else 
        { $files = Get-ChildItem }
    
    if ($List) {
        return $files | Select-String $search -List
    }
    return $files | Select-String $search
}

<#
.DESCRIPTION
    Zeigt die Länge des eingegebenen Strings an
#> 
function len($str){
    return $str.length
}

<#
.DESCRIPTION
    Gibt die gegebene Zahl in Hexadezimalschreibweise zurück
#>                                              
function hex([int]$num) {                       
    return "0x" + ('{0:x}').ToUpper() -f $num   
}                                               

<#
.DESCRIPTION
    Gibt die gegebene Zahl in Binärschreibweise zurück
#>
function Bin([int]$num) {
    return [Convert]::ToString($num, 2)
}

# Benutze CTRL + D zum beenden (Wie in Bash)
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# Open = Start
Set-Alias -Name "open" -Value "ii"

# Benutze notepad++ als Editor
Set-Alias -Name "notepad" -Value "$env:ProgramFiles\Notepad++\notepad++.exe"

# VSCode
Set-Alias -Name "vs" -Value "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\Code.exe"

# Clipcopy
Set-Alias -Name "clipcopy" -Value "set-clipboard"

# ===== Dateien =====
<#
.DESCRIPTION
    Berechnet den SHA256-Hash einer Datei oder eines Strings
.PARAMETER Path
    Der Pfad der Datei
.PARAMETER String
    Eine Zeichenkette
#>
function sha256hash() {
    param(
        [string[]]$Path,
        [string]$String
    )
    if ($String) {
        $stringAsStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stringAsStream)
        $writer.write("$String")
        $writer.Flush()
        $stringAsStream.Position = 0
        return (Get-FileHash -InputStream $stringAsStream).Hash
    } else {
        $table =  New-Object system.Data.DataTable 'Hash'
    
        $newcol = New-Object system.Data.DataColumn Path,([string]); 
        $table.columns.add($newcol)
        $newcol = New-Object system.Data.DataColumn sha256,([string]); 
        $table.columns.add($newcol)
        
        foreach ($file in $path) {
            $hash = Get-FileHash -Path "$file" -Algorithm sha256
            
            $row = $table.NewRow()
            $row.Path = $file
            $row.sha256 = $hash.hash
            $table.Rows.Add($row) 
        }
        return $table
    }
}
Set-Alias -Name "sha256sum" -Value "sha256hash"

<#
.DESCRIPTION
    Berechnet den SHA256-Hash aller Dateien in einem Verzeichnis
.PARAMETER path
    Der Pfad des Verzeichnisses
.PARAMETER Recurse
    Unterordner miteinbeziehen
#>
function sha256dir() {
    param(
        [string]$path,
        [switch]$Recurse
    )
    $table =  New-Object system.Data.DataTable 'FolderContents'
    
    $newcol = New-Object system.Data.DataColumn FileName,([string]); 
    $table.columns.add($newcol)
    $newcol = New-Object system.Data.DataColumn sha256,([string]); 
    $table.columns.add($newcol)
    
    if ($Recurse) {
        $files = $(get-childItem -File -Recurse $path)
    } else {
        $files = $(get-childItem -File $path)
    }
    
    foreach ($file in $files) {
        $row = $table.NewRow()
        $row.FileName = ($file.Name)
        $row.sha256 = (get-fileHash -Path $file.FullName -Algorithm sha256).Hash
        $table.Rows.Add($row) 
    }
    
    return $table
}

function Compare-Dir() {
    param(
        [string]$path1,
        [string]$path2,
        [switch]$Recurse
    )
    $table1 = $(sha256dir -Recurse=$Recurse $path1)
    $table2 = $(sha256dir -Recurse=$Recurse $path2)
    
    $diff = $(compare-Object $table1 $table2 -Property sha256 -PassThru
    
    foreach ($change in $diff) {
        if ($change.SideIndicator -eq "<=") {
            $change.SideIndicator = "Path1"
        } else {
            $change.SideIndicator = "Path2"
        }
    })
    
    return diff
}

function Compare-Files($file1, $file2) {
    $diff = Compare-Object $(get-content $file1) $(get-content $file2)
    foreach ($change in $diff) {
        if ($change.SideIndicator -eq "<=") { Write-Host "+ "$change.InputObject -ForegroundColor "green" } 
        elseif ($change.SideIndicator -eq "=>") { Write-Host "- "$change.InputObject -ForegroundColor "red" } 
        else {Write-Host "  "$change.InputObject -ForegroundColor "gray"}
    }
}
Set-Alias -Name "get-FileDiff" -Value "Compare-Files"

<#
.DESCRIPTION
    Gibt eine Bilddatei auf dem Terminal als Unicode-Zeichen aus
.PARAMETER path
    Der Pfad der Bilddatei
.PARAMETER Width
    Die gewünschte Bildbreite
.PARAMETER Size
    Die gewünschte Größe, auf die das Bild skaliert werden soll (1-100, prozentualer Anteil der Terminalbreite)
.PARAMETER HalfChar
    Verwende ein anderes Zeichen, um das Bild anzuzeigen (Terminal-Abhängig)
.PARAMETER EnableTransparency
    Verwende Transparenz (weißer Hintergrund)
#>
function Out-Image() {
    # Idea from: https://github.com/DevAndersen/posh-bucket/tree/master/projects/consoleImageRenderer
    param(
        [string]$path,
        [int]$Width,
        [int]$Size = 100,
        [switch]$HalfChar,
        [switch]$EnableTransparency
    )
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    
    if ($HalfChar) {
        $pixelChar = [char]0x2580 #0x25AE
    } else {
        $pixelChar = [char]0x2588 
    }
    $escapeChar = [char]0x1B
    
    $img = [System.Drawing.Image]::Fromfile($path)
    $windowSize = $host.UI.RawUI.WindowSize
    
    if ($Width) {
        $imgWidth = $Width
    } else {
        $imgWidth = $windowSize.Width
    }
    
    $imgHeight = [int]((($img.Height / $img.Width) * $imgWidth) * ($Size / 100))
    $imgWidth = [int]($imgWidth * ($Size / 100))
    
    $imgResized = $img.GetThumbnailImage($imgWidth, $imgHeight, $null, [System.IntPtr]::Zero)
    
    $imageText = ""
    $transparencyModifier = [int][bool]$EnableTransparency
    $maxColor = 255 * $transparencyModifier
    for ($y = 0; $y -lt $imgResized.Height; $y++) { 
        $line = ""
        for ($x = 0; $x -lt $imgResized.Width; $x++) {
            $pixel = $imgResized.GetPixel($x, $y);
            $colorA = $pixel.A * $transparencyModifier
            $colorR = [math]::Min($($pixel.R + ($maxColor - $colorA)), 255)
            $colorG = [math]::Min($($pixel.G + ($maxColor - $colorA)), 255)
            $colorB = [math]::Min($($pixel.B + ($maxColor - $colorA)), 255)
            $line += "$escapeChar[38;2;$($colorR);$($colorG);$($colorB)m$pixelChar"        
        }
        $imageText += "`n$line"
    }
    
    $imgResized.dispose()
    $img.dispose()
    
    return $imageText
}


#Fügt Text ein, indem das Tippen jedes Zeichen simuliert wird.
#Add-Type -AssemblyName System.Windows.Forms
#function pasteAsKeystrokes() {
#    param(
#        [Parameter(Position=0,mandatory=$true)]
#        [string]$pasteString,
#        [Parameter(Position=1,mandatory=$false)]
#        [int]$Delay = 1
#    )
#    
#    $Shell = New-Object -ComObject "WScript.Shell"
#    if ($Shell.Popup("Click OK to paste.", 60, "paste as keystrokes", 1) -eq 2) { return }
#    Release-Ref $Shell
#    foreach ($char in ([char[]] $pasteString)) {
#        [System.Windows.Forms.SendKeys]::SendWait($char);
#        sleep -Milliseconds $Delay
#    }
#}
    


# ===== Windows =====
function list-apps() {
    Get-AppxPackage | where { $_.SignatureKind -eq "Store" -and $_.isframework -eq $false } | Format-Table
}

<#
.DESCRIPTION
   Prüft, ob eine Internetverbindung besteht
.PARAMETER Count
    Die Anzahl der Echo-Packete, die gesendet werden sollen (gleicht dem -n Parameter des Ping-Befehls)
.PARAMETER Size
    Die Größe der Echo-Packete, die gesendet werden sollen (gleicht dem -l Parameter des Ping-Befehls)
.PARAMETER SkipLocal
    Überspringt die Prüfung des Standardgateways und dessen DNS-Servern
#>
function check-internet() {
    param (
        [int]$Count=2,
        [int]$Size=64,
        [switch]$SkipLocal
    )
    
    if (!$SkipLocal) {
        $connectedDevices = Get-NetIPConfiguration | where-Object {$_.NetAdapter.Status -ne "Disconnected" }
        foreach($dev in $connectedDevices) {
            $devName = $dev.NetProfile.Name
            if (!$devName) { $devName = $dev.InterfaceDescription }
            if (!$devName) { $devName = $dev.InterfaceAlias }
            
            $devDns = $dev.DNSServer
            $devGateway4 = $dev.IPv4DefaultGateway.NextHop
            $devGateway = $devGateway4
            
            if (!$devGateway) { $devGateway = $devGateway6 }
            if (!$devGateway) { continue }
           
            Write-Host "Checking default Gateway ($devGateway) of connection $devName..." -NoNewLine
            if (test-connection -Quiet -BufferSize $Size -Count $Count $devGateway) { 
                Write-Host "Success" -ForegroundColor "green" 
                
                foreach ($dns in $devDns) {
                    foreach ($dnsAddr in $dns.ServerAddresses) {
                        Write-Host "Checking DNS Server ($dnsAddr) of connection $devName..." -NoNewLine
                        if (test-connection -Quiet -BufferSize $Size -Count $Count $dnsAddr) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
                    }
                }
            } else {  
                Write-Host "Fail" -ForegroundColor "red" 
            } 
        }
    }
    
    Write-Host "Checking Cloudflare 1..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 1.1.1.1) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking Cloudflare 2..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 1.0.0.1) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking Cloudflare 1 (IPv6)..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 2606:4700:4700:0000:1111) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking Cloudflare 2 (IPv6)..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 2606:4700:4700:0000:1001) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking Google 1..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 8.8.8.8) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking Google 2..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count -IPAddress 8.8.4.4) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking google.com..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count google.com) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking github.com..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count github.com) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking cloudflare.net..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count cloudflare.net) { Write-Host "Success" -ForegroundColor "green" } else {  Write-Host "Fail" -ForegroundColor "red" }
    Write-Host "Checking nonexistium.gone..." -NoNewLine
    if (test-connection -Quiet -BufferSize $Size -Count $Count nonexistium.gone) { Write-Host "EXISTS (Fail)" -ForegroundColor "yellow" } else {  Write-Host "Fail (Success)" -ForegroundColor "green" }
}

function Show-Notification {
    [cmdletbinding()]
    Param (
        [string] $ToastTitle,
        [string] $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "PowerShell"
    $Toast.Group = "PowerShell"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $Notifier.Show($Toast);
}

# ===== Git =====
# Auf 0 setzen, wenn git nicht installiert ist
$GITINSTALLED=1

# Custom Path für Git.exe
$env:Path += ";$env:USERPROFILE\Downloads\PortableGit\bin\"
$GITCMD = "$env:USERPROFILE\Downloads\PortableGit\bin\git.exe" #git


function ga($str) { & $GITCMD add $str}
function gaa(){ & $GITCMD add --all }
function ggo(){ & $GITCMD commit -m '#Changes:' --edit}
#Set-Alias -Name "gl" -Value "$GITCMD pull" #Schon ein PS-Alias
#Set-Alias -Name "gp" -Value "$GITCMD push" #Schon ein PS-Alias
Set-Alias -Name "gpl" -Value "$GITCMD pull"
Set-Alias -Name "gpu" -Value "$GITCMD push"
Set-Alias -Name "ggs" -Value "$GITCMD status"

# gss: Kurze Statusinfo
function gss(){ & $GITCMD status --short}

# glg: Git log mit Infos über veränderte Dateien
Set-Alias -Name "glg" -Value "$GITCMD log --stat"

# glgg: Git log mit grafischer (Textart) Darstellung von Branches
Set-Alias -Name "glgg" -Value "$GITCMD log --graph"

# gcm: Git checkout master
#Set-Alias -Name "gcm" -Value "GITCMD checkout master" #Schon ein PS-Alias

#gco: Git checkout
function gco($str) { & $GITCMD checkout $str}


function Get-Encoding{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]
    $Path
  )

  process 
  {
    $bom = New-Object -TypeName System.Byte[](4)
        
    $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')
    
    $null = $file.Read($bom,0,4)
    $file.Close()
    $file.Dispose()
    
    $enc = [Text.Encoding]::ASCII
    if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
      { $enc =  [Text.Encoding]::UTF7 }
    if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
      { $enc =  [Text.Encoding]::Unicode }
    if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
      { $enc =  [Text.Encoding]::BigEndianUnicode }
    if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
      { $enc =  [Text.Encoding]::UTF32}
    if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
      { $enc =  [Text.Encoding]::UTF8}
        
    [PSCustomObject]@{
      Encoding = $enc
      Path = $Path
    }
  }
}

function encode-base64($str) {
    return [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($str))
}

function decode-base64($str) {
    return [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($str))
}


# Setze das Hintergrundbild
Function Set-WallPaper($Image) {  
    Add-Type -TypeDefinition @" 
    using System; 
    using System.Runtime.InteropServices;
      
    public class Params
    { 
        [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
        public static extern int SystemParametersInfo (Int32 uAction,Int32 uParam, String lpvParam, Int32 fuWinIni);
    }
"@
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

#Hintergründe für jede Tageszeit
$WP_KWS = @{
    #TODO: Put Wallpapers here!
    default="$env:windir\Web\Wallpaper\Windows\img0.jpg";                      # Windows 10 Standard
}

# ===== Theming =====

# Setzt den Wallpaper
function set-wp($kw) {
    if (!$kw) {
        Write-Host "Wallpapers:"
        Write-Host "-----------"
        $WP_KWS.keys
    } elseif ($WP_KWS.ContainsKey($kw)) {
        Set-WallPaper $WP_KWS[$kw]
    } else {
        Write-Host "Not found!" -ForegroundColor "red"
    }
}
Set-Alias -Name "wp" -Value "set-wp"

#Setzt das App-Design von Windows
<#
.DESCRIPTION
    Setzt das Windows-App Theme auf Hell oder Dunkel
.PARAMETER theme
    "light" oder "dark"
#>
function Set-Theme($theme) {
    if ($theme -eq "dark") {
        $themeID = 0
    } elseif ($theme -eq "light") {
        $themeID = 1
    } else {
        Write-Host "Themes"
        Write-Host "------"
        Write-Host "dark"
        Write-Host "light"
        return
    }
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value ([int]$themeID)
}


# ===== Keyboard =====

#Ersetzt die LEDs auf meinem Keyboard
#function kbd-indicator() {    
#    $title = $host.ui.RawUI.WindowTitle
#    $cursorSize = $host.ui.RawUI.CursorSize
#    $backCol = $host.ui.RawUI.BackgroundColor
#    
#    $host.ui.RawUI.CursorSize = 0 #Hide cursor
#    $host.ui.RawUI.BackgroundColor = "black"
#    $host.ui.RawUI.WindowTitle = "Keyboard" 
#    
#    try {
#        while($true){
#            $nlState = [console]::NumberLock
#            $clState = [console]::CapsLock
#            
#            #Limit number of redraws to reduce CPU usage
#            if (($clState -ne $clLast) -or ($nlState -ne $nlLast)) {
#                if($nlState){$nlCol="yellow"}else{$nlCol="white"}
#                if($clState){$clCol="yellow"}else{$clCol="white"}
#                Write-Host -NoNewLine "`rNumLock    " -ForegroundColor $nlCol
#                Write-Host -NoNewLine "CapsLock" -ForegroundColor $clCol
#            }
#            $clLast = $clState
#            $nlLast = $nlState
#            Sleep -Milliseconds 400
#        }
#    } finally {
#        $host.ui.RawUI.CursorSize = $cursorSize
#        $host.ui.RawUI.BackgroundColor = $backCol
#        $host.ui.RawUI.WindowTitle = $title
#    }
#}

#kbd-indicator mit tray icons anstatt text
<#
.DESCRIPTION
    Zeigt Tray-Icons an, wenn CapsLock oder NumLock aktiviert sind.
#>
function kbd-tray() {
    $script:kbdjob = start-Job -ScriptBlock {
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | out-null
        [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')    | out-null
        
        $trayCaps = New-Object System.Windows.Forms.NotifyIcon
        $trayCaps.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$env:userprofile\CapsLock.ico") 
        $trayCaps.Text = "CapsLock active"
        $trayCaps.Visible = $false

        $trayNum = New-Object System.Windows.Forms.NotifyIcon
        $trayNum.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$env:userprofile\NumLock.ico") 
        $trayNum.Text = "NumLock active"
        $trayNum.Visible = $false

        try {
            while($true){
                $nlState = [console]::NumberLock
                $clState = [console]::CapsLock
                
                #Limit number of redraws to reduce CPU usage
                if (($clState -ne $clLast) -or ($nlState -ne $nlLast)) {
                    $trayCaps.Visible = $clState
                    $trayNum.Visible = $nlState
                }
                $clLast = $clState
                $nlLast = $nlState
                Sleep -Milliseconds 200
            }
        } finally {
            $trayNum.dispose()
            $trayCaps.dispose()
        }
    }
    Write-Host "Indicator started! (Warning: Closing this session will kill the idicator process!)"
    Write-Host "Job ID saved to `$kbdjob"
    return $script:kbdjob
}


function reset-kbd() {
    $w = New-Object -ComObject WScript.Shell; 
    if([console]::NumberLock){ 
        $w.SendKeys('{NUMLOCK}'); 
    }
    if([console]::CapsLock){ 
        $w.SendKeys('{CAPSLOCK}'); 
    }
    Release-Ref $w
    keyboard-status
}

# ===== Zeit =====

<#
.DESCRIPTION
    Countdown zu einer bestimmten Uhrzeit
#>
function countdown-to($str) {
    $tgtDate = get-date $str

    $nowDate = get-date
    while ($tgtDate -ge $nowDate) {
        $dateDiff = $tgtDate - $nowDate
        $CurrentLine  = $Host.UI.RawUI.CursorPosition.Y
        [Console]::SetCursorPosition(0,($CurrentLine - $i))
        Write-Host (([string]$dateDiff.Hours).PadLeft(2, '0') + ":" + ([string]$dateDiff.Minutes).PadLeft(2, '0') + ":" + ([string]$dateDiff.Seconds).PadLeft(2, '0')) -NoNewLine
        sleep -Milliseconds 1000
        $nowDate = get-date
    }
}


# ===== Readline =====

# ZSH-like autocomplete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

#ZSH-like Up/Down history
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

#Disable audio bell
Set-PSReadlineOption -BellStyle Visual


# ===== Prompt =====
#Prompt Design kopiert vom Oh-My-Zsh Design "gallois", mit ein paar eigenen Änpassungen
$IsAdmin = (
    New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
).IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator
)

#With great power comes great responsibility.
if ($IsAdmin) {
    Write-Warning "PowerShell is running with administrator privileges! Think before you type!"
}
    
function prompt() {
    $cmdStatus = $?
    #$lastExit = $LASTEXITCODE
    $hostname = [environment]::machinename

    if ($cmdStatus -eq $True) {
        $exitColor = "Green"
    } else {
        $exitColor = "Red"
    }

    #Default
    $gitStatus = ""
    $gitFG = "Green"
    $gitBranch = ""
    
    if ($GITINSTALLED) {
        Try {
            & $GITCMD status >$null 2>&1 | out-null
            
            $isGitRepo = $?
            if ($isGitRepo) {
                $gitBranch = $(& $GITCMD branch --show-current) #TODO: Detached head state
                
                
                #Check for changes in the current repo
                if (& $GITCMD status --porcelain | Where {$_ -notmatch '^\?\?'}){ 
                    $gitStatus = "±"
                    $gitFG = "Yellow"
                }
            }
        } catch {
            $gitBranch = ""
        }
    }
    if ($IsAdmin) {
        Write-Host "?" -NoNewLine -ForegroundColor "yellow"
    }
    
    Write-Host "[$env:UserName@$hostname][$pwd]"  -NoNewLine -ForegroundColor "Cyan"

    if ($gitBranch) {
        Write-Host "($gitBranch$GitStatus)" -NoNewLine -ForegroundColor $gitFG
    }
    #Write-Host "(ERROR)" -NoNewLine -ForegroundColor "White" -BackgroundColor "Red"
   
    
    Write-Host "$" -NoNewLine -ForegroundColor $exitColor
    return " "
}