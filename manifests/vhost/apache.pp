class wordpress::vhost::apache (
  $document_root,
  $domain,
) inherits wordpress::vhost::base {
  include apache
  include apache::mod::php

  include php

  php::module { ['mysql']:
    notify => Class['apache::mod::php'],
  }

  apache::vhost { $domain:
    priority => '10',
    port     => '80',
    docroot  => "${document_root}/",
  }
}
