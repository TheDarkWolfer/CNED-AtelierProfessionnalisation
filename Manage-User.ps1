param(
    [Parameter(Mandatory=$true)]
    [string]$UserName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Add", "Remove")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Role
)

# Charger le module ActiveDirectory
Import-Module ActiveDirectory

# Vérifier que l'utilisateur existe
$user = Get-ADUser -Identity $UserName -ErrorAction SilentlyContinue
if (-not $user) {
    Write-Error "L'utilisateur '$UserName' n'existe pas dans l'AD."
    exit 1
}

# Vérifier que le groupe existe
$group = Get-ADGroup -Identity $Role -ErrorAction SilentlyContinue
if (-not $group) {
    Write-Error "Le groupe '$Role' n'existe pas dans l'AD."
    exit 1
}

# Effectuer l'action demandée
if ($Action -eq "Add") {
    try {
        Add-ADGroupMember -Identity $Role -Members $UserName
        Write-Host "L'utilisateur.ice '$UserName' a été ajouté au groupe '$Role'."
    }
    catch {
        Write-Error "Erreur lors de l'ajout de '$UserName' au groupe '$Role' : $_"
    }
}
elseif ($Action -eq "Remove") {
    try {
        Remove-ADGroupMember -Identity $Role -Members $UserName -Confirm:$false
        Write-Host "L'utilisateur.ice '$UserName' a été retiré du groupe '$Role'."
    }
    catch {
        Write-Error "Erreur lors du retrait de '$UserName' du groupe '$Role' : $_"
    }
}


# La création des groupes se ferait comme suit :
# Par exemple, le groupe G_RnD se créerait comme suit dans l'OU "RechercheEtDeveloppement" sous "ValorElec"
# New-ADGroup -Name "G_RnD" -GroupScope Global -GroupCategory Security -Path "OU=RechercheEtDeveloppement,OU=ValorElec,DC=tierslieux86,DC=local"
