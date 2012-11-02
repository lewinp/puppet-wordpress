class { 'wordpress':
  db_name     => 'wordpressdb',
  db_user     => 'wordpress',
  db_password => 'password',
  httpd       => 'standalone',
}
