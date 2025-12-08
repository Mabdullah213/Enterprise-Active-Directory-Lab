# 1. Ask who to fire
$TargetUser = Read-Host "Enter the Username to terminate (e.g. Jim.Halpert)"

# 2. Define the Graveyard
$GraveyardPath = "OU=_Terminated Users,DC=corp,DC=local"

# 3. Check if user exists
try {
    $UserObj = Get-ADUser -Identity $TargetUser -Properties Description
    
    # 4. The Termination Sequence
    # Disable the account
    Disable-ADAccount -Identity $TargetUser
    
    # Scramble the password so they can never guess it again
    $RandomPass = -join ((33..126) | Get-Random -Count 50 | % {[char]$_})
    $SecurePass = ConvertTo-SecureString $RandomPass -AsPlainText -Force
    Set-ADAccountPassword -Identity $TargetUser -NewPassword $SecurePass -Reset
    
    # Stamp the date on their forehead (Description field)
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm"
    Set-ADUser -Identity $TargetUser -Description "TERMINATED on $Date by Script"
    
    # Move the body to the graveyard
    Move-ADObject -Identity $UserObj.DistinguishedName -TargetPath $GraveyardPath
    
    Write-Host "Successfully terminated $TargetUser. Goodbye." -ForegroundColor Cyan
}
catch {
    Write-Host "User '$TargetUser' not found! Are you sure you spelled it right?" -ForegroundColor Red
}