Import-Module ActiveDirectory

# Définition de la liste des OU à créer.
# Pour chaque OU, on définit :
# - Name : le nom de l'OU à créer
# - ParentPath : le conteneur (DN) dans lequel l'OU sera créée

$ouList = @(
    @{ Name = "VladEtec"; ParentPath = "DC=tierslieux86,DC=local" },
    @{ Name = "RechercheEtDeveloppement"; ParentPath = "OU=VladEtec,DC=tierslieux86,DC=local" },
    @{ Name = "Commercial"; ParentPath = "OU=VladEtec,DC=tierslieux86,DC=local" },
    @{ Name = "Direction"; ParentPath = "OU=VladEtec,DC=tierslieux86,DC=local" }
)

foreach ($ou in $ouList) {
    $name = $ou.Name
    $parentPath = $ou.ParentPath

    # Vérifier si l'OU existe déjà dans le parent spécifié
    $exists = Get-ADOrganizationalUnit -Filter "Name -eq '$name'" -SearchBase $parentPath -ErrorAction SilentlyContinue

    if ($exists) {
        Write-Host "L'OU '$name' existe déjà dans '$parentPath'."
    }
    else {
        Write-Host "Création de l'OU '$name' dans '$parentPath'..."
        New-ADOrganizationalUnit -Name $name -Path $parentPath
    }
}

Write-Host "Création des OU terminée !"
