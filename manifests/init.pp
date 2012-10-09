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
class wordpress(
        $db_name='wordpress',
        $db_host='localhost',
        $db_user = 'wordpress',
        $db_password='ThereIsN0CowL3v3l')
    {
  class { 'wordpress::app': }

  class { 'mysql::server':
        config_hash => {
            'root_password' => "Use0nlyinc4seof3merg3ncy",
        },
    }
  class { 'mysql::server::account_security': }
  database { "$db_name":
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
  class { 'mysql::backup':
        backupuser      => 'backups',
        backuppassword  => 'youD0haveAbackup-right?',
        backupdir      => '/var/tmp',
    }
}
