# Chemin vers le fichier CSV.
$UserList = "chemin\vers\le\fichier.csv"

# Lire le fichier CSV.
$Users = Import-Csv -Path $UserList -Delimiter ";" -Encoding UTF8

# Création d'un mot de passe aléatoire.
Function RandomPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [int] $Length=12,

        [Parameter(Mandatory=$true)]
        [int] $Upper=2,

        [Parameter(Mandatory=$true)]
        [int] $Digits=2,

        [Parameter(Mandatory=$true)]
        [int] $Special=2
    )

    Begin {
        $Lower = $Length - $Special - $Digits - $Upper
        $ArrayLower = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
        $ArrayUpper = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
        $ArraySpecial = @('&','~','#','=','+','$','£','*','ù','%','!','§',':','/')
    }

    Process {
        [string] $NewPassword = $ArrayLower | Get-Random -Count $Lower
        $NewPassword += 0..9 | Get-Random -Count $Digits
        $NewPassword += $ArrayUpper | Get-Random -Count $Upper
        $NewPassword += $ArraySpecial | Get-Random -Count $Special
        $NewPassword = $NewPassword.Replace(' ', '')
        $MixedCharacters = $NewPassword.ToCharArray()
        $Mess = $MixedCharacters | Get-Random -Count $MixedCharacters.Length
        $FinalPassword = -join $Mess
    }

    End {
        return $FinalPassword
    }
}




Foreach ($User in $Users){
    $UserName = $User.Prenom
    $UserLastname = $User.Nom
    $UserDepartment = $User.Departement
    $UserJob = $User.Fonction
    $UserLogin = ($UserName).Substring(0,1) + "." + $UserLastname
    $UserMail = "$UserLogin@bober.lan"
    $UserPassword = RandomPassword
    # Boucle pour récupérer les informations sur chaque utilisateurs. 
    $Read= "_RO"
    $Write= "_RW"
    $Edit= "_RWM"
    $Right= "GDL_$UserDepartment"

# Déposer les utilisateurs dans les groupes de droits. 
    Add-ADGroupMember -Identity $Right$Read -Members $UserLogin
    Add-ADGroupMember -Identity $Right$Write -Members $UserLogin
    Add-ADGroupMember -Identity $Right$Edit -Members $UserLogin
}

# Vérification de la présence ou non de l'utilisateur 
if (Get-ADUser -Filter {SamAccountName -eq $UserLogin})
{
    Write-Warning "$UserLogin est déjà présent dans l'AD"
}
else {
    New-ADUser -Path "OU=$Username,OU=$UserDepartment,OU=Utilisateurs,OU=TOULOUSE,DC=bober,DC=lan"
            -Name "$UserName $UserLastname"
            -GivenName "$UserName"
            -Surname $UserLastname
            -SamAccountName $UserLogin 
            -EmailAddress $UserMail 
            -Title $UserJob  
            -AccountPassword(ConvertTo-SecureString $UserPassword -AsPlainText -Force) 
            -ChangePasswordAtLogon $true
            -Enabled $true

            Write-Output " L'utilisateur $UserName a été crée !  "
}



