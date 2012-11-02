class wordpress::app (
  $version,
  $document_root,
  $setup_root,
) {

  $packages = [
    'wget',
    'unzip',
  ]

  wordpress::install_dependency { $packages: }

  if $version == 'latest' {
    $wordpress_archive = 'latest.zip'
    $release_url       = "http://wordpress.org/${wordpress_archive}"
  }
  else {
    $wordpress_archive = 'wordpress-${version}.zip'
    $release_url       = "http://wordpress.org/download/release-archive/${wordpress_archive}"
  }

  exec {
    'wordpress_application_dir':
      command => "mkdir -p ${document_root}",
      creates => $document_root,
      path    => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      before  => File['wordpress_setup_files_dir'];
  }

  $needed_files = [
    'wordpress_php_configuration',
    'wordpress_themes',
    'wordpress_plugins',
    'wordpress_htaccess_configuration',
  ]

  file {
    'wordpress_setup_files_dir':
      ensure  =>  directory,
      path    =>  $setup_root,
      before  =>  [ File[$needed_files], Exec['wordpress_download_installer'] ];
    'wordpress_php_configuration':
      ensure     =>  file,
      path       =>  "${document_root}/wp-config.php",
      content    =>  template('wordpress/wp-config.erb'),
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_htaccess_configuration':
      ensure     =>  file,
      path       =>  "${document_root}/.htaccess",
      source     =>  'puppet:///modules/wordpress/.htaccess',
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_themes':
      ensure     => directory,
      path       => "${setup_root}/themes",
      source     => 'puppet:///modules/wordpress/themes/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_themes'],
      subscribe  => Exec['wordpress_extract_installer'];
    'wordpress_plugins':
      ensure     => directory,
      path       => "${setup_root}/plugins",
      source     => 'puppet:///modules/wordpress/plugins/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_plugins'],
      subscribe  => Exec['wordpress_extract_installer'];
  }

  exec {
    'wordpress_download_installer':
      command   => "wget ${release_url} -O ${setup_root}/${wordpress_archive}",
      logoutput => on_failure,
      creates   => "$setup_root/${wordpress_archive}",
      path      => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      notify    =>  Exec['wordpress_extract_installer'],
      require   => [ Package['wget'] ];
    'wordpress_extract_installer':
      command      => "unzip -o $setup_root/${wordpress_archive} -d ${setup_root}/ &&
                       mkdir -p `dirname ${document_root}` &&
                       cp -r --update ${setup_root}/wordpress/* ${document_root}/",
      refreshonly  => true,
      require      => Package['unzip'],
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
    'wordpress_extract_themes':
      command      => "/bin/sh -c 'for themeindex in `ls ${setup_root}/themes/*.zip`;
                      do unzip -o \$themeindex -d ${document_root}/wp-content/themes/;
                      done'",
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      refreshonly  => true,
      require      => Package['unzip'],
      subscribe    => File['wordpress_themes'];
    'wordpress_extract_plugins':
      command      => "/bin/sh -c 'for pluginindex in `ls ${setup_root}/plugins/*.zip`;
                      do unzip -o \$pluginindex -d ${document_root}/wp-content/plugins/;
                      done'",
      path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'],
      refreshonly  => true,
      require      => Package['unzip'],
      subscribe    => File['wordpress_plugins'];
  }
}
