class wordpress::vhost::standalone (
  $document_root,
  $domain,
) inherits wordpress::vhost::base {
  $apache = $::osfamily ? {
    'RedHat' => 'httpd',
    'Debian' => 'apache2',
    default  => httpd,
  }

  $phpmysql = $::osfamily ? {
    'RedHat' => 'php-mysql',
    'Debian' => 'php5-mysql',
    default  => 'php-mysql',
  }

  $php = $::osfamily ? {
    'RedHat' => 'php',
    'Debian' => 'libapache2-mod-php5',
    default  => 'php',
  }

  $packages = [
    $apache,
    $php,
    $phpmysql,
  ]

  wordpress::install_dependency { $packages: }

  $vhost_path = $apache ? {
    httpd    => '/etc/httpd/conf.d/wordpress.conf',
    apache2  => '/etc/apache2/sites-enabled/000-default',
    default  => '/etc/httpd/conf.d/wordpress.conf',
  }

  file {
    'wordpress_vhost':
      ensure   => file,
      path     => $vhost_path,
      content  => template('wordpress/wordpress.conf.erb'),
      replace  => true,
      require  => Package[$apache];
  }

  service { $apache:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$apache, $php, $phpmysql],
    subscribe  => File['wordpress_vhost'];
  }
}