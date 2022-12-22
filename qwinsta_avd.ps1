#==========================================================================
# NOM           : MPO_qwinsta_avd.ps1
# SOCIETE       : 
# VERSIONS      : 1.0
#
#
# DESCRIPTION   : Script executant des commandes en local suite à l'appel du script MPO_Extinction_AVD.ps1
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
        write-log "$($_.exception.message)" # adapter au besoin
        $script:ExitCode = 1 # Ne pas supprimer
    }
    if ($script:ExitCode -ne 0) {$script:errors++} # Verifie si une erreur a ete rencontree
    Write-Msg "Code retour $($Script:ExitCode)" # Remonte dans les logs le code retour
    Return $script:ExitCode
} 
#>

## Vérification des sessions sur la VM
Function verif_session {
    write-log "Vérification des sessions sur la VM" #adapter le contenue au besoin
    Try {
        Write-log "========== Lancement fonction Get-TSSessions =========="
        $query = Get-TSSessions
        Write-log "========== Lancement fonction Get-TSSessions => OK =========="
        Write-log "========== Vérification de chaque session =========="
        foreach ($q in $query) {
            if (($q.ID -like '*D*co*') -and ($q.SESSION -notlike 'services')) {
                rwinsta $q.UTILISATEUR
            }
            if ($q.ÉTAT -like 'Actif') {
                $count ++
            }
            if ($count -eq 0) {
                $state = 'OFF'
            }
            else {
                $state = 'ON'
            }
        Write-log "========== Vérification de chaque session => OK =========="
        $state
        Write-log "========== l'état de la VM est $state =========="
        }
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

#==========================================================================
#                         Declaration des variables   
#==========================================================================
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Ne pas Modifier!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## En cas d'erreur on s'arrète
$ErrorActionPreference = "Stop" 

## Nombre d'erreurs total rencontrees
$script:errors = 0 

#!!!!!!!!!!!!!!!!!!!!Change le comportement du script!!!!!!!!!!!!!!!!!!!!!!
## Fonction listant les sessions sur la VM
function Get-TSSessions {
    param(
        $ComputerName = 'localhost'
    )
    qwinsta /server:$ComputerName |
    #Parse output
    ForEach-Object {
        $_.Trim() -replace '\s+', ','
    } |
    #Convert to objects
    ConvertFrom-Csv
}

## Compteur nécessaire pour savoir si quelqu'un est en ligne ou pas sur le serveur
$count = 0

#==================================Logs====================================

$log_directory = 'c:\Dynamips\Scripts\AVD\logs'
    
if(!(Test-Path $log_directory )){
    [void](New-Item -ItemType Directory -Path $log_directory )
    }

$Log_Path = $log_directory + '\' + 'AVD_' + $((Get-Date).tostring('dd-MM-yyyy_HH-mm-ss')) + '.log'

#!!!!!!!!!!!!!!!!!!!!!!!!!Variables de traitement!!!!!!!!!!!!!!!!!!!!!!!!!!

#==========================================================================
#                                 Execution
#==========================================================================
write-log  "######################### Début du script ##########################"
## Au besoin utiliser cette partie pour executer des prerequis sinon remplacer 0 par le nom de la fonction
$script:ExitAction1 = verif_session

write-log  "######################### Fin du script ##########################"
