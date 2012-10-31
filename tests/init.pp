class { 'mysql::server':
  config_hash => {
    'root_password' => 'Use0nlyinc4seof3merg3ncy',
  },
}

class { 'mysql::backup':
  backupuser      => 'backups',
  backuppassword  => 'youD0haveAbackup-right?',
  backupdir       => '/var/tmp',
}

class {'wordpress':
  db_name     => 'wordpressdb',
  db_user     => 'wordpress',
  db_password => 'password',
}
