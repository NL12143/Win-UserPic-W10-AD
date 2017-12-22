[byte[]](Get-Content "\\$env:USERDNSDOMAIN\NETLOGON\defaultuser.jpg" -Encoding byte)

#Set-ADPicture-AG-Keys.ps1
#source Blog http://blog.jocha.se/tech/ad-user-pictures-in-windows-10, by Jocha AB
#based on https://blog.jourdant.me/post/ps-setting-windows-8-account-picture-from-ad, 
#Uses module Resize-Image-A-PowerShell-3d26ef68, by Patrick Lambert
#edits for company and added image resizing using function 
#authors: Roeland Cerfonteijn; Sencer Demir 

TRY {
#region Set script variables 
$Error.Clear()
$StartDir = "C:\Users\Public\AccountPictures" 
#$StartDir = "C:\Program Files (x86)\Internal\Workplace\AcountPicture"

Set-Location $StartDir  
Import-Module .\Set-ADpicture-Resize.ps1 
$DefaultPic = "$StartDir\Set-ADpicture-Default.jpg" 
$LogFile = "$StartDir\Set-ADpicture-Log.log"  
#Get user object from AD and store in script variables 
$user = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
$userName = $env:username
$userSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

#Set picture to ADpicture or default 
If ($user.thumbnailphoto -eq $null) { 
$userphoto = [byte[]](Get-Content $DefaultPic -Encoding byte) 
$userphoto = [byte[]](Get-Content $photo -Encoding byte) 
$photo = Get-Content $DefaultPic -Encoding byte
$photo ="$StartDir\Set-ADpicture-Default.jpg"
$photo
$DefaultPic
$userphoto
}
Else {
$userPhoto = $user.thumbnailphoto 
}
$userphoto
#endregion 

#Region Setup image sizes and base path
$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
$image_mask = "Image{0}.jpg"
$image_base =  "C:\Users\Public\AccountPictures" 
#DEFAULT  C:\ProgramData\Microsoft\User Account Pictures > User, Guest
#CUSTOM   C:\ProgramData\Microsoft\Custom Account Pictures > DAT files 
#UserEdit C:\Users\Public\AccountPictures\<User_SID>\ > #After upload by user resize is stored here
#History C:\Users\G18554\AppData\Roaming\Microsoft\Windows\AccountPictures\ Last uploaded pictures 
#Prepare folder to store temp images 
#C:\Users\Public\AccountPictures\<User_SID>\ as when user changes himself
$dir = $image_base + "\" + $userSID
If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }
#Prepare registry keys for AccountPictures
#HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\
$reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
#Windows uses HKLM for this to be able to show before user logon ;-)  
$reg_key = [string]::format($reg_base, $userSID)
$reg_value_mask = "Image{0}"
If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key } 
#endregion
#Save photo imported from AD 
$imageAD = $dir + "\" + "imageAD.jpg" 
$userphoto | Set-Content -Path $imageAD -Encoding Byte -Force 
$userphoto
#region Loop for picture sizes
ForEach ($size in $image_sizes) {
    #Save image to disk C:\Users\Public\AccountPictures\<User_SID>\ 
    $file_name = ([string]::format($image_mask, $size))
    $path = $dir + "\" + $file_name
    Resize-Image -InputFile $imageAD -Width $size -Height $size -OutputFile $path 
    #Save image path in registry, overwrite existing entries
    $name = [string]::format($reg_value_mask, $size)
    $value = New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
}
#endregion loop

#region logging
$text1 = "$(Get-Date -format yyyy-MM-dd-HH:mm:ss). No error running picture script."    
$text2 = "Pictures for user $UserName stored in C:\Users\Public\AccountPictures\$UserSID" 
Set-Content $text1 -Path $LogFile -ErrorAction SilentlyContinue
Add-Content $text2 -Path $LogFile -ErrorAction SilentlyContinue
#endregion logging 
}
#endregion TRY

#region CATCH 
CATCH { 
If ($Error) {
Set-Content $(Get-Date -format yyyy-MM-dd-HH:mm:ss) –path $LogFile -ErrorAction SilentlyContinue 
Add-Content $Error.Exception.Message -Path $LogFile -ErrorAction SilentlyContinue }
Else {Set-Content "Catch but no error" $(Get-Date -format yyyy-MM-dd-HH:mm:ss) –path $LogFile }
#endregion CATCH

#ToDo 
#Add for production: -ErrorAction SilentlyContinue
#Add a default picture when user has no thumbnail in AD.
#Add a catch in case the loop fails. 
#Add a time-out value to quit after 10 ms.
