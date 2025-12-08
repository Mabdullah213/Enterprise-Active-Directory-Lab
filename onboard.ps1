# ==========================================
# SCRIPT: onboard_v3.ps1
# PURPOSE: Provision new users OR Re-hire terminated ones (FIXED LOGIC)
# ==========================================

$Users = Import-Csv "C:\Scripts\employees.csv"
$Password = ConvertTo-SecureString "CHANGE_ME" -AsPlainText -Force
# Password should be injected via KeyVault in production
$ParentOU = "OU=IT Department,DC=corp,DC=local"
$GraveyardOU = "OU=_Terminated Users,DC=corp,DC=local"

foreach ($User in $Users) {
    
    # 1. Dynamic Folder Setup
    $DepartmentName = $User.Department
    $TargetOU = "OU=$DepartmentName,$ParentOU"
    
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$DepartmentName'" -SearchBase $ParentOU -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $DepartmentName -Path $ParentOU
        Write-Host "Created Department: $DepartmentName" -ForegroundColor Cyan
    }

    $Username = $User.FirstName + "." + $User.LastName
    $HiredDate = Get-Date -Format "yyyy-MM-dd"

    # 2. Check if user exists
    $ExistingUser = Get-ADUser -Filter {SamAccountName -eq $Username} -Properties Enabled, DistinguishedName

    if ($ExistingUser) {
        # 3. If they exist, are they disabled (Terminated)?
        if ($ExistingUser.Enabled -eq $false) {
            Write-Host "  [!] Found terminated user $Username. Re-hiring..." -ForegroundColor Yellow
            
            # --- THE RE-HIRE SEQUENCE (CORRECTED ORDER) ---
            
            # A. Reset Password (new start) - Do this FIRST while we know where they are
            Set-ADAccountPassword -Identity $ExistingUser.DistinguishedName -NewPassword $Password -Reset
            
            # B. Update Stamp
            Set-ADUser -Identity $ExistingUser.DistinguishedName -Description "RE-HIRED on $HiredDate"
            
            # C. Enable the account
            Enable-ADAccount -Identity $ExistingUser.DistinguishedName
            
            # D. Move them back to their Department (Do this LAST)
            Move-ADObject -Identity $ExistingUser.DistinguishedName -TargetPath $TargetOU
            
            Write-Host "  [SUCCESS] Welcome back, $Username! Moved to [$DepartmentName]" -ForegroundColor Green
        }
        else {
            Write-Host "  [-] User $Username already active. Skipping." -ForegroundColor DarkGray
        }
    }
    else {
        # 4. Create Brand New User
        New-ADUser `
            -Name "$($User.FirstName) $($User.LastName)" `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@corp.local" `
            -Path $TargetOU `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $false `
            -Description "HIRED on $HiredDate"

        Write-Host "  [SUCCESS] Created New User: $Username in [$DepartmentName]" -ForegroundColor Green
    }
}