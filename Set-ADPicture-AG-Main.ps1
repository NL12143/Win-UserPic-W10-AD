#Set-ADPicture-AG-Main.ps1
#source Blog http://blog.jocha.se/tech/ad-user-pictures-in-windows-10, by Jocha AB
#uses module Resize-Image-A-PowerShell-3d26ef68, by Patrick Lambert
#edits for company and added image resizing using function 
#authors: Roeland Cerfonteijn 

$Error.Clear()

TRY {
	#Set script variables 
	$StartDir = "C:\Program Files (x86)\Workplace\AccountPicture" 
	$LogFile = "C:\ProgramData\Workplace\AccountPicture\Set-ADpicture-Log.log"  
  $DefaultPic = "$StartDir\Set-ADpicture-Default.png" 
	Set-Location $StartDir  
	Import-Module .\Set-ADpicture-Resize.psm1 

  #Contact Active Directory 
	$user = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
	$userName = $env:username
	$userSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

	#Set picture to ADpicture (found) or default (empty) 
	If ($user.thumbnailphoto -eq $null) {
	$userphoto = [byte[]](Get-Content $DefaultPic -Encoding byte) 
	$log1 = "$(Get-Date -format yyyy-MM-dd-HH:mm:ss). No UserPicture in AD, set to default picture."  
	$log2 = "Pictures for user $UserName stored in C:\Users\Public\AccountPictures\$UserSID" 
	}
	Else { 
	$userPhoto = $user.thumbnailphoto 
	$log1 = "$(Get-Date -format yyyy-MM-dd-HH:mm:ss). Found UserPicture in AD."    
	$log2 = "Pictures for user $UserName stored in C:\Users\Public\AccountPictures\$UserSID" 
	}

	#Setup folder for images and base path
	$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
	$image_mask = "Image{0}.jpg"
	$image_base =  "C:\Users\Public\AccountPictures" 
	#DEFAULT  C:\ProgramData\Microsoft\User Account Pictures > User, Guest
	#CUSTOM   C:\ProgramData\Microsoft\Custom Account Pictures > DAT files 
	#UserEdit C:\Users\Public\AccountPictures\<User_SID>\ > #After upload by user resize is stored here
	#History  C:\Users\G18554\AppData\Roaming\Microsoft\Windows\AccountPictures\ Last uploaded pictures 
	#Prepare folder to store temp images, and define file to store base image  
	$dir = $image_base + "\" + $userSID
	If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }
	$imageAD = $dir + "\" + "imageAD.jpg" 

	#Prepare registry keys for AccountPicture
	#HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\
	$reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
	#Windows uses HKLM for this to be able to show before user logon ;-)  
	$reg_key = [string]::format($reg_base, $userSID)
	$reg_value_mask = "Image{0}"
	If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key } 

	#Save photo imported from AD as a jpg  
	$userphoto | Set-Content -Path $imageAD -Encoding Byte -Force  

	ForEach ($size in $image_sizes) {
		#Save image to disk C:\Users\Public\AccountPictures\<User_SID>\ 
		$file_name = ([string]::format($image_mask, $size))
		$path = $dir + "\" + $file_name
		Resize-Image -InputFile $imageAD -Width $size -Height $size -OutputFile $path 
		#Save image path in registry, overwrite existing entries
		$name = [string]::format($reg_value_mask, $size)
		$value = New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
		}
	#Logging
	Set-Content $log1 -Path $LogFile -ErrorAction SilentlyContinue
	Add-Content $log2 -Path $LogFile -ErrorAction SilentlyContinue
}

CATCH { 
	$LogFile = "C:\ProgramData\AccountPictures\Set-ADpicture-Log.log"  
	If ($Error) {
	Set-Content $(Get-Date -format yyyy-MM-dd-HH:mm:ss) –path $LogFile  
	Add-Content $Error.Exception.Message -Path $LogFile  
	}
	Else {
	Set-Content "Catch but no error" $(Get-Date -format yyyy-MM-dd-HH:mm:ss) –path $LogFile 
	}
}

#ToDo 
#Add for production: -ErrorAction SilentlyContinue
#Add a default picture when user has no thumbnail in AD.
#Add a catch in case the loop fails. 
#Add a time-out value to quit after 10 ms.
