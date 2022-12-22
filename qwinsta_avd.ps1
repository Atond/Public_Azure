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
$count = 0

$query = Get-TSSessions

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
}

$state
