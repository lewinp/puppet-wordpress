class wordpress::vhost::nginx (
  $document_root,
  $domain,
) inherits wordpress::vhost::base {
  nginx::resource::vhost { $domain:
    ensure   => present,
    www_root => $document_root,
  }
}
