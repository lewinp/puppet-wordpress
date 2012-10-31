# Class: wordpress
#
# This module manages wordpress
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class wordpress (
  $db_name     = $wordpress::params::db_name,
  $db_host     = $wordpress::params::db_host,
  $db_user     = $wordpress::params::db_user,
  $db_password = $wordpress::params::db_password,
  $domain      = $wordpress::params::domain,
) inherits wordpress::params {
  class { 'wordpress::app': }

  database { $db_name:
    ensure          => present,
    charset         => 'utf8',
  }

  database_user { "$db_user@%$db_host":
    ensure          => present,
    password_hash   => mysql_password("$db_password"),
  } 

  database_grant { "$db_user@$db_host/$db_name":
    privileges      => [all],
  }
}
