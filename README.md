# Account Picture Win10 
Automatic provision of Account Picture in Win10 from Active Directory 

Based on blogpost Get Active Directory pictures in Windows 10, by Jocha AB; 
http://blog.jocha.se/tech/ad-user-pictures-in-windows-10 
this uses Setting the Windows 8 Account Picture from AD, by Jourdan Templeton; 
https://blog.jourdant.me/post/ps-setting-windows-8-account-picture-from-ad, 

Script uses module Resize-Image-A-PowerShell, by Patrick Lambert 
https://gallery.technet.microsoft.com/scriptcenter/Resize-Image-A-PowerShell-3d26ef68, Patrick Lambert 
Module renamed to Set-ADpicture-Resize.ps1 to align with the name of the main script.
 
Script "Set-ADPicture-Keys.ps1" uses the following regions: 

#Set script variables and load image resizer 
#Get user object from AD and store in script variables 
#Prepare image sizes and base path 
#Create folder to store temp images 
#Prepare registry keys for AccountPictures 
#Save photo imported from AD 
#Load module for image resizer 
#ForEach ($size in $image_sizes) 
  #Save image to disk C:\Users\Public\AccountPictures\<User_SID>\ 
  #Save image path in registry, overwrite existing entries


