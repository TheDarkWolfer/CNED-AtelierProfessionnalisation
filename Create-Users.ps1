Import-Module ActiveDirectory

# Chemin vers le CSV
$csvPath = "C:\temp\Users.csv"
$users = Import-Csv -Path $csvPath

# Tableau pour stocker les informations de crédentiels (username:password)
$credentielsOutput = @()

foreach ($user in $users) {
    Write-Output "Création de l'utilisateur $($user.SamAccountName)..."
    
    New-ADUser `
        -Name              $user.Name `
        -SamAccountName    $user.SamAccountName `
        -UserPrincipalName $user.UPN `
        -AccountPassword   (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
        -Enabled           $true `
        -Path              $user.OU

    # Ajout de l'utilisateur au groupe s'il existe
    if ($user.Group -and (Get-ADGroup $user.Group -ErrorAction SilentlyContinue)) {
        Add-ADGroupMember -Identity $user.Group -Members $user.SamAccountName
    } else {
        Write-Warning "Le groupe $($user.Group) n'existe pas ou n'a pas été trouvé."
    }
    
    # Ajouter la ligne de crédentiels au tableau
    $credentielsOutput += "$($user.SamAccountName): $($user.Password)"
}

Write-Host "Import terminé !"

# Définir le chemin du document Word sur le bureau de l'utilisateur courant
$desktopPath = [Environment]::GetFolderPath("Desktop")
$docPath = Join-Path $desktopPath "InfosLoginUtilisateur-ices.docx"

# Créer une instance de Word via COM
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()

# Insérer les crédentiels dans le document Word
$range = $doc.Range()
foreach ($line in $credentielsOutput) {
    $range.InsertAfter("$line`r`n")
    # Mettre à jour le range à la fin du document
    $range = $doc.Range($doc.Content.End - 1, $doc.Content.End - 1)
}

# Sauvegarder le document et fermer Word
$doc.SaveAs([ref] $docPath)
$doc.Close()
$word.Quit()

Write-Host "Les identifiants ont été enregistrés dans : $docPath"

# Exemple de contenu du fichier `Users.csv`
# Name,SamAccountName,UPN,OU,Password,Group
# Jean Dupont,jdupont,jdupont@tierslieux86.local,"OU=RechercheEtDeveloppement,OU=VladEtec,DC=tierslieux86,DC=local",Password123,G_RnD
# Marie Moreau,mmoreau,mmoreau@tierslieux86.local,"OU=Commercial,OU=VladEtec,DC=tierslieux86,DC=local",Password123,G_Commercial
# Luc Bernard,lbernard,lbernard@tierslieux86.local,"OU=Direction,OU=VladEtec,DC=tierslieux86,DC=local",Password123,G_Direction

# Nota Bene : Dans un environement de production, stocker des mots de passe en clair est une
# TRÈS mauvaise idée, car cela compromet la sécurité de tous ces comptes. De plus, ça 
# contrevient au RGPD, surtout à l'article 32 qui définit les règles quand au stockage
# des données personnelles.