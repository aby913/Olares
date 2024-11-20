Function pickFile(){
    <#
    .SYNOPSIS
        Pick a file from PowerShell.
    .DESCRIPTION
        Ask user to pick a file in a script
    .PARAMETER User
        $initialDirectory start from user's Desktop  
    .EXAMPLE
        pickFile
    .NOTES
        Author: Ratan Mohapatra
        Last Update: December 30, 2019 
    #>    
        $initialDirectory = "$env:USERPROFILE\desktop"
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "PS1 (*.ps1)| *.ps1"
        $OpenFileDialog.ShowDialog() | Out-Null
        return $OpenFileDialog.filename
        }

function MakeMySignCert{
    <#
    .SYNOPSIS
        Creates a self-signed certificate to sign your PowerShell scripts.
    .DESCRIPTION
        Codesigning a script allows you white list the CodeSigning Certificate and to run the script on remote machines
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    .PARAMETER User
        $yourEmail is stored in the CN field of certificate   
    .EXAMPLE
        MakeMySignCert -yourEmail 'me@myemail.edu'
    .NOTES
        Author: Ratan Mohapatra
        https://github.com/ratanGit/code-sign-PS
        Last Update: December 30, 2019 
    #>
    [CmdletBinding()]
    param(
        [string]$yourEmail
        )
    $cnString = 'CN=' + $yourEmail
    #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-6
    New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my `
    -Subject $cnString `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
    -KeyExportPolicy Exportable `
    -KeyUsage DigitalSignature `
    -Type CodeSigningCert

    #list certs in my cert dir
    write-host -BackgroundColor Green -ForegroundColor White "`nYou have the following Code Signing Certs available!"
    dir cert:\currentuser\my -CodeSigningCert
    }

Write-Host -BackgroundColor Green -ForegroundColor White "`nRatan's CodeSigning Script 2020`n"

$chk = [int](Read-Host "Select your options (e.g., 2): `n1`tWant to create a new CodeSigning Certificate `n2`tWant to sign a script`n`t")


switch($chk){
    1{
      $email = Read-Host 'What is your email : e.g., me@myemail.edu '
      MakeMySignCert -yourEmail $email
      }
    2{
      $fl = pickfile
      #$cert = @(Get-ChildItem cert:\CurrentUser\My -codesigning)[1]
      $cert = @(Get-ChildItem cert:\CurrentUser\My -codesigning) ; $cert
      $WhichCert = Read-Host 'Please select the Certificate you want to use, e.g., 0,1,2,... '
      $UseCert = $cert[$WhichCert]
      Set-AuthenticodeSignature -FilePath $fl -Certificate $UseCert
      }
    default{end}
    }
