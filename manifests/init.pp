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

  $document_root = $wordpress::params::document_root,
  $setup_root    = $wordpress::params::setup_root,
) inherits wordpress::params {
  class { 'wordpress::app':
    version       => $version,
    document_root => $document_root,
    setup_root    => $setup_root,
  }

  mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $db_host,
    grant    => ['all'],
    require  => Class['mysql::config'],
  }
}
