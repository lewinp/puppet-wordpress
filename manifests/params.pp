class wordpress::params {
  $version     = 'latest'

  $db_name     = 'wordpress'
  $db_host     = 'localhost'
  $db_user     = 'wordpress'
  $db_password = 'ThereIsN0CowL3v3l'

  $domain      = $::domain
}