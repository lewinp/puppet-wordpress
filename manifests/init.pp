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
  $version     = $wordpress::params::version,
  $db_name     = $wordpress::params::db_name,
  $db_host     = $wordpress::params::db_host,
  $db_user     = $wordpress::params::db_user,
  $db_password = $wordpress::params::db_password,
  $domain      = $wordpress::params::domain,
) inherits wordpress::params {
  class { 'wordpress::app':
    version => $version,
  }

  mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
    require  => Class['mysql::config'],
  }
}
