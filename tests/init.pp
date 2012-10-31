$hostname = 'ubuntu1204'

class { 'mysql::server':
  config_hash => {
    'root_password' => "Use0nlyinc4seof3merg3ncy",
  },
}

class { 'mysql::backup':
  backupuser      => 'backups',
  backuppassword  => 'youD0haveAbackup-right?',
  backupdir       => '/var/tmp',
}

class {'wordpress':
  db_name =>      "mydbname",
  db_user =>      "mydbuser",
  db_password =>  "mydbpassword"
}
