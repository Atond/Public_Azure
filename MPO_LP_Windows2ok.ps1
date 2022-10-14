#==========================================================================
# NOM           : MPO_LP_Windows2.ps1
# SOCIETE       : 
# VERSIONS      : 1.0
#
#
# DESCRIPTION   : Préparation VM Azure, pack de langue et autres 2ème partie. 
# PREREQUIS     : Powershell 3.0+
#
#==========================================================================
#               Code Commun (Fonctions essentielles au script)
#==========================================================================
    ## Fonction de d'ecriture dans le fichier de log
    Function Write-Log([String]$Value){
        $Time=(Get-Date).tostring('dd-MM HH-mm-ss')
        $ValueLog="[$Time] $Value"
        Add-Content -Path $Log_Path -Value $ValueLog
    }
    
    ## Fonction d'ecriture d'un message d'etat (Code retour)
    Function Write-Msg($msg,$exitcode) {
            
        if ($exitcode -eq 0) 
          {write-log -Value "$($msg) : OK - ExitCode $($exitcode)"}
        else
          {write-log -Value "$($msg) : KO - ExitCode $($exitcode)"}
    }
#==========================================================================   
#       Code de traitement (Fonctions pour la tache a realiser)   
#========================================================================== 
<#
Function NOMFONCTION {
    write-log "..." #adapter le contenue au besoin
    Try {
        
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        mail_erreur_runbook
        write-log "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) {$script:errors++} # Verifie si une erreur a ete rencontree
    Write-Msg "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
} 
#>

## Modification langue, heure etc.
Function change_lp {
    write-log "Modification langue, heure etc." #adapter le contenue au besoin
    Try {
        write-log "========== Modification langue Serveur ==========" -ForegroundColor Yellow
        Set-TimeZone -Id "Romance Standard Time"
        write-log "========== TimeZone => OK ==========" -ForegroundColor Green
        Set-Culture fr-FR
        write-log "========== Culture => OK ==========" -ForegroundColor Green
        Set-WinSystemLocale -SystemLocale fr-FR
        write-log "========== System => OK ==========" -ForegroundColor Green
        Set-WinHomeLocation 84
        write-log "========== Region => OK ==========" -ForegroundColor Green
        Set-WinUserLanguageList -LanguageList (New-WinUserLanguageList -Language "fr-FR" -ErrorAction SilentlyContinue) -force
        write-log "========== Menu => OK ==========" -ForegroundColor Green
        Set-WinUILanguageOverride -Language fr-FR
        write-log "========== Interface => OK ==========" -ForegroundColor Green
        tzutil.exe /s "Romance Standard Time"
        write-log "========== TimeZone => OK ==========" -ForegroundColor Green
        $script:ExitCode = 0 # Ne pas supprimer
    }
    Catch {
        write-log "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) {$script:errors++} # Verifie si une erreur a ete rencontree
    Write-Msg "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
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
    if ($script:ExitCode -ne 0) {$script:errors++} # Verifie si une erreur a ete rencontree
    Write-Host "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
}
#==========================================================================
#                         Declaration des variables   
#==========================================================================
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Ne pas Modifier!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## En cas d'erreur on s'arrête
$ErrorActionPreference = "Stop" 

## Nombre d'erreurs total rencontrees
$script:errors  = 0 

#!!!!!!!!!!!!!!!!!!!!Change le comportement du script!!!!!!!!!!!!!!!!!!!!!!

$os = (Get-WmiObject Win32_OperatingSystem).caption

#==================================Logs====================================

$log_directory = 'c:\Dynamips\Scripts\LP'
    
if(!(Test-Path $log_directory )){
    [void](New-Item -ItemType Directory -Path $log_directory )
    }

$Log_Path = $log_directory + '\' + 'LP2_' + $((Get-Date).tostring('dd-MM-yyyy_HH-mm-ss')) + '.log'

#!!!!!!!!!!!!!!!!!!!!!!!!!Variables de traitement!!!!!!!!!!!!!!!!!!!!!!!!!!

#==========================================================================
#                                 Execution
#==========================================================================
write-log  "######################### Début du script ##########################"
## Au besoin utiliser cette partie pour executer des prerequis sinon remplacer 0 par le nom de la fonction
$script:ExitAction1 = change_lp


# Initialisation variables d'execution
$script:ExitAction2 = 1 ## add_runonce
$script:ExitAction3 = 1 ## auto_login

## Appeler chaque fonction necessaire a la realisation des actions sur l'AD
if ($script:ExitAction1 -eq 0) {$script:ExitAction2 = add_runonce}
if ($script:ExitAction2 -eq 0) {$script:ExitAction3 = auto_login}

## Fin 
## Nombre d'erreur rencontrees
write-log "ERREURS RENCONTREES : $($script:errors)" 
write-log "######################### Fin du script ##########################"