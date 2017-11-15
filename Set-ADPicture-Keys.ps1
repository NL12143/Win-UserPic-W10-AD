#Set-ADPicture-AG-Keys.ps1
#source Blog http://blog.jocha.se/tech/ad-user-pictures-in-windows-10, by Jocha AB
#based on https://blog.jourdant.me/post/ps-setting-windows-8-account-picture-from-ad, 
#Uses module Resize-Image-A-PowerShell-3d26ef68, by Patrick Lambert
#edits for company and added image resizing using function 
#authors: Roeland Cerfonteijn; Sencer Demir 

#region Set script variables and load image resizer 
#Get user object from AD and store in script variables 
$user = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
#Store user properties
$user_name = $env:username
$user_photo = $user.thumbnailphoto
$user_sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

#Setup image sizes and base path
$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
$image_mask = "Image{0}.jpg"
$image_base =  "C:\Users\Public\AccountPictures" 
#DEFAULT  C:\ProgramData\Microsoft\User Account Pictures > User, Guest
#CUSTOM   C:\ProgramData\Microsoft\Custom Account Pictures > DAT files 
#UserEdit C:\Users\Public\AccountPictures\<User_SID>\ > #After upload by user resize is stored here
#History C:\Users\G18554\AppData\Roaming\Microsoft\Windows\AccountPictures\ Last uploaded pictures 

#Create folder to store temp images 
#C:\Users\Public\AccountPictures\<User_SID>\ as when user changes himself
$dir = $image_base + "\" + $user_sid
If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }

#Prepare registry keys for AccountPictures
#HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\
$reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
#Windows uses HKLM for this to be able to show before user logon ;-)  
$reg_key = [string]::format($reg_base, $user_sid)
$reg_value_mask = "Image{0}"
If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key } 

#Save photo imported from AD 
$pathAD = $dir + "\" + "imageAD.jpg"  
$user_photo | Set-Content -Path $pathAD -Encoding Byte -Force 

#Load module for image resizer 
pushD "C:\Program Files (x86)\Internal\Workplace"
Import-Module .\Set-ADpicture-AG-Resize.ps1 
#Get-Location 
#Get-ChildItem

#endregion

ForEach ($size in $image_sizes) {
    #Save image to disk C:\Users\Public\AccountPictures\<User_SID>\ 
    $file_name = ([string]::format($image_mask, $size))
    $path = $dir + "\" + $file_name
    Resize-Image -InputFile $pathAD -Width $size -Height $size -OutputFile $path 

    #Save image path in registry, overwrite existing entries
    $name = [string]::format($reg_value_mask, $size)
    $value = New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
    }

#Add a default picture when user has no thumbnail in AD.
#Add a catch in case loop fials. 



