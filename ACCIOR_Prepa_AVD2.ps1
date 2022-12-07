#==========================================================================
# NOM           : MPO_ACCIOR_AVD2.ps1
# SOCIETE       : 
# VERSIONS      : 1.0
#
#
# DESCRIPTION   : Préparation AVD pour ACCIOR (Changement de langue, installation logiciel)
# PREREQUIS     : Powershell 3.0+
#
#==========================================================================
#               Code Commun (Fonctions essentielles au script)
#==========================================================================
#==========================================================================   
#       Code de traitement (Fonctions pour la tache a realiser)   
#========================================================================== 
<#
Function NOMFONCTION {
    Write-Host "..." #adapter le contenue au besoin
    Try {
        
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        Write-Error "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) {$script:errors++} # Verifie si une erreur a ete rencontree
    Write-Host "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
} 
#>

## Installation d'application via Choco
Function install_app_choco {
    Write-Host "Installation application" #adapter le contenue au besoin
    Try {
        Write-Host "========== Upgrade Chocolatey ==========" -ForegroundColor Yellow
        choco upgrade chocolatey
        Write-Host "========== Upgrade Chocolatey => OK ==========" -ForegroundColor Green
        
        Write-Host "========== Installation 7Zip ==========" -ForegroundColor Yellow
        choco install 7zip.install -y
        Write-Host "========== Installation 7Zip => OK ==========" -ForegroundColor Green
        
        Write-Host "========== Installation pdfxchangeeditor ==========" -ForegroundColor Yellow
        choco install pdfxchangeeditor -y
        Write-Host "========== Installation pdfxchangeeditor => OK ==========" -ForegroundColor Green
        
        Write-Host "========== Installation adobereader ==========" -ForegroundColor Yellow
        choco install adobereader -y
        Write-Host "========== Installation adobereader => OK ==========" -ForegroundColor Green
        
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        Write-Error "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) { $script:errors++ } # Verifie si une erreur a ete rencontree
    Write-Host "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
} 

## Auto Login
Function auto_login {
    Write-Host "Reboot serveur" #adapter le contenue au besoin
    Try {
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-ItemProperty $RegPath "AutoAdminLogon" -Value "0" -type String 
        Set-ItemProperty $RegPath "DefaultUsername" -Value "" -type String 
        Set-ItemProperty $RegPath "DefaultPassword" -Value "" -type String
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        Write-Error "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) { $script:errors++ } # Verifie si une erreur a ete rencontree
    Write-Host "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
}

## Reboot serveur
Function reboot_server {
    write-log "Reboot serveur" #adapter le contenue au besoin
    Try {
        Restart-Computer 
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        write-log "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) { $script:errors++ } # Verifie si une erreur a ete rencontree
    Write-Msg "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
}
#==========================================================================
#                         Declaration des variables   
#==========================================================================
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Ne pas Modifier!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## En cas d'erreur on s'arrête
$ErrorActionPreference = "Stop" 

## Nombre d'erreurs total rencontrees
$script:errors = 0 

#!!!!!!!!!!!!!!!!!!!!Change le comportement du script!!!!!!!!!!!!!!!!!!!!!!

#==================================Logs====================================

#!!!!!!!!!!!!!!!!!!!!!!!!!Variables de traitement!!!!!!!!!!!!!!!!!!!!!!!!!!

#==========================================================================
#                                 Execution
#==========================================================================
Write-Host  "######################### Début du script ##########################"
## Au besoin utiliser cette partie pour executer des prerequis sinon remplacer 0 par le nom de la fonction
$script:ExitAction1 = install_app_choco

# Initialisation variables d'execution
$script:ExitAction2 = 1 ## auto_login
$script:ExitAction3 = 1 ## reboot_server

## Appeler chaque fonction necessaire a la realisation des actions sur l'AD
if ($script:ExitAction1 -eq 0) { $script:ExitAction2 = auto_login }
if ($script:ExitAction2 -eq 0) { $script:ExitAction3 = reboot_server }