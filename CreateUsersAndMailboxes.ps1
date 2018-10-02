#Created by IT Solutions

Import-Module activedirectory
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<ServerFQDN>/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Enter-PSSession $Session
$users = Import-Csv C:\temp\IraqUsers.csv

# Password for users
$password = 'Qwerty123!' | ConvertTo-SecureString -AsPlainText -Force 




foreach($user in $users){
    
    $id = "'*" + $($user.HRNumber) + "*'"
    $aduser = get-aduser -filter "EmployeeID -like $id"
    
    
    
    if ((Get-Mailbox $aduser.SamAccountName).ServerName -like "*IQ*"){

    New-ADUser -Name $aduser.Name -GivenName $aduser.GivenName -samaccountname "$($aduser.SamAccountName).ext" `
     -Surname $aduser.Surname -userprincipalname "$($aduser.SamAccountName).ext@msk.lo" ` 
     -DisplayName $aduser.Name -Path "OU=ForMigrationFromIraq, OU=Users, OU=Dubai03, OU=UAE, OU=Regions,DC=msk, DC=lo"  `
     -AccountPassword $Password -ChangePasswordAtLogon $False -Enabled $True

        if ((Get-Mailbox -Database "DM_IraqUsers_Temp_DB_1").Count -gt 249){
    
            Enable-Mailbox -Database DM_IraqUsers_Temp_DB_2 -Identity "$($aduser.SamAccountName).ext" -PrimarySmtpAddress "$($aduser.Givenname).$($aduser.Surname).ext@lukoil-international.com"
            Add-MailboxPermission -Identity "$($aduser.SamAccountName).ext" -User $aduser.SamAccountName -AccessRights FullAccess -AutoMapping $false
            get-mailbox "$($aduser.SamAccountName).ext" | Add-ADPermission -User $aduser.SamAccountName -ExtendedRights "Send As"
            set-mailbox $aduser.SamAccountName -ForwardingAddress "$($aduser.SamAccountName).ext" -DeliverToMailboxAndForward $true

            }

        else {
    
            Enable-Mailbox -Database DM_IraqUsers_Temp_DB_1 -Identity "$($aduser.SamAccountName).ext" -PrimarySmtpAddress "$($aduser.Givenname).$($aduser.Surname).ext@lukoil-international.com"
            Add-MailboxPermission -Identity "$($aduser.SamAccountName).ext" -User $aduser.SamAccountName -AccessRights FullAccess -AutoMapping $false
            get-mailbox "$($aduser.SamAccountName).ext" | Add-ADPermission -User $aduser.SamAccountName -ExtendedRights "Send As"
            set-mailbox $aduser.SamAccountName -ForwardingAddress "$($aduser.SamAccountName).ext" -DeliverToMailboxAndForward $true

            }
        }

    }

Remove-PSSession $Session