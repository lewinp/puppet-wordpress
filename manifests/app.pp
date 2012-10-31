class wordpress::app (
  $version = 'latest'
) {

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
    'wget',
    'unzip',
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

  service { $apache:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$apache, $php, $phpmysql],
    subscribe  => File['wordpress_vhost'];
  }

  if $version == 'latest' {
    $wordpress_archive = 'latest.zip'
    $release_url       = "http://wordpress.org/${wordpress_archive}"
  }
  else {
    $wordpress_archive = 'wordpress-${version}.zip'
    $release_url       = "http://wordpress.org/download/release-archive/${wordpress_archive}"
  }
  

  exec {
    'wordpress_download_installer':
      command   => "wget $release_url -O /opt/wordpress/setup_files/${wordpress_archive}",
      logoutput => on_failure,
      creates   => "/opt/wordpress/setup_files/${wordpress_archive}",
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      notify  =>  Exec['wordpress_extract_installer'],
      require   => [ Package["wget"] ];
  }

  $needed_files = [
    'wordpress_php_configuration',
    'wordpress_themes',
    'wordpress_plugins',
    'wordpress_htaccess_configuration',
  ]

  file {
    'wordpress_application_dir':
      ensure  =>  directory,
      path    =>  '/opt/wordpress',
      before  =>  File['wordpress_setup_files_dir'];
    'wordpress_setup_files_dir':
      ensure  =>  directory,
      path    =>  '/opt/wordpress/setup_files',
      before  =>  [ File[$needed_files], Exec['wordpress_download_installer'] ];
    'wordpress_php_configuration':
      ensure     =>  file,
      path       =>  '/opt/wordpress/wp-config.php',
      content    =>  template('wordpress/wp-config.erb'),
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_htaccess_configuration':
      ensure     =>  file,
      path       =>  '/opt/wordpress/.htaccess',
      source     =>  'puppet:///modules/wordpress/.htaccess',
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_themes':
      ensure     => directory,
      path       => '/opt/wordpress/setup_files/themes',
      source     => 'puppet:///modules/wordpress/themes/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_themes'],
      subscribe  => Exec['wordpress_extract_installer'];
    'wordpress_plugins':
      ensure     => directory,
      path       => '/opt/wordpress/setup_files/plugins',
      source     => 'puppet:///modules/wordpress/plugins/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_plugins'],
      subscribe  => Exec['wordpress_extract_installer'];
    'wordpress_vhost':
      ensure   => file,
      path     => $vhost_path,
      source   => 'puppet:///modules/wordpress/wordpress.conf',
      replace  => true,
      require  => Package[$apache];
  }

  exec {
    'wordpress_extract_installer':
      command      => "unzip -o\
                      /opt/wordpress/setup_files/${wordpress_archive}\
                      -d /opt/",
      refreshonly  => true,
      require      => Package['unzip'],
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
    'wordpress_extract_themes':
      command      => '/bin/sh -c \'for themeindex in `ls \
                      /opt/wordpress/setup_files/themes/*.zip`; \
                      do unzip -o \
                      $themeindex -d \
                      /opt/wordpress/wp-content/themes/; done\'',
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      refreshonly  => true,
      require      => Package['unzip'],
      subscribe    => File['wordpress_themes'];
    'wordpress_extract_plugins':
      command      => '/bin/sh -c \'for pluginindex in `ls \
                      /opt/wordpress/setup_files/plugins/*.zip`; \
                      do unzip -o \
                      $pluginindex -d \
                      /opt/wordpress/wp-content/plugins/; done\'',
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      refreshonly  => true,
      require      => Package['unzip'],
      subscribe    => File['wordpress_plugins'];
  }
}
