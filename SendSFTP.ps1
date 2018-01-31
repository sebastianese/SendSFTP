###########################################################################################
# Title     :  Powershell script to automate uploads to  SFTP
# Filename  :  SendSFTP.ps1       
# Created by:   Seastian Schlesinger           
# Date      :   12/20/2018                
# Version   :   1.0        
###########################################################################################


# Load the Posh-SSH module
import-module Posh-ssh
# Set the credentials
$Password = ConvertTo-SecureString 'PASSWORD' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ('USER', $Password)

# Set local file path and SFTP path
$FilePath = "\\SourcePath"
$SftpPath = '/ROOT' # Target path at SFTP site
$Files = Get-ChildItem  -File -Path $FilePath
# Set the IP of the SFTP server
$SftpIp = 'FTP IP'




#Script Execution
Set-Location $FilePath

# Establish the SFTP connection
New-SFTPSession -ComputerName $SftpIp -Credential $Credential -AcceptKey -port 21
$session = Get-SFTPSession | Select-Object -ExpandProperty "SessionID"


# Upload the file to the SFTP path
Foreach ($file in $Files){ 
Set-SFTPFile -SessionId $session -LocalFile $File -RemotePath $SftpPath
}

# Disconnect SFTP session
Remove-SFTPSession -SessionId $session

#Sends Email Report
$directoryInfo = Get-ChildItem -Recurse $FilePath  | Measure-Object
If ($directoryInfo.count -ne 0)
{
$Date = Get-Date
$Date2 = get-date -f yyyyMMdd
$Body1 = $Files | Select-Object -ExpandProperty Name | Out-String
$Body2 = "The following files were sent through SFTP on $Date :
"
$Body4 = "





Please do not reply to this email. This mailbox is not monitored"
$Body3 = $Body2 + $Body1 + $Body4
$users = "user@mail.com"
$fromemail = "Daily SFTP Transfer <SFTPTransfer@yourdomain.com>" 
$server = "Your email server" 
$Subject = "Transfer Log $Date2"
send-mailmessage -from $fromemail -to $users -subject $Subject  -Body $Body3  -priority Normal -smtpServer $server
}


#Remove Files
foreach ($file in $Files){
Remove-Item -Force $file 
}