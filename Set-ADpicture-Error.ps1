#Set-ADpicture-Error.ps1
#Module to generate error to log

#Script variables 
$StartDir = "C:\Users\Public\AccountPictures\"
$LogFile = "$StartDir\Set-ADpicture-AG-Log.log"  
$LogFile
$Username = "TestUserName" 
$UserSID = "TestUserSID" 
$Error | Get-Member  
$Error.Exception.Message
$Error.Clear()

#region 
TRY { 
#Log when TRY done 
$text1 = "$(Get-Date -format yyyy-MM-dd-HH:mm:ss). No error running picture script."    
$text2 = "Pictures for user $UserName stored in C:\Users\Public\AccountPictures\$UserSID" 
Set-Content $text1 -Path $LogFile 
Add-Content $text2 -Path $LogFile 
}
#endregion TRY

#region CATCH
CATCH {
#Log when catch
$LogFile = "$StartDir\Set-ADPicture-AG-Log.log"  
If ($Error) {
Set-Content $(Get-Date -format yyyy-MM-dd-HH:mm:ss) –path $LogFile -ErrorAction SilentlyContinue 
Add-Content "Errors when running the picture script. Details below:" –path $LogFile -ErrorAction SilentlyContinue
Add-Content $Error.Exception.Message -Path $LogFile -ErrorAction SilentlyContinue 
} 
Else { Set-Content "Catch but no error $(Get-Date -format yyyy-MM-dd-HH:mm:ss)" –path $LogFile }
} 
#endregion CATCH 

#Add for production: -ErrorAction SilentlyContinue
