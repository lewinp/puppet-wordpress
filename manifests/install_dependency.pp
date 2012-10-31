define wordpress::install_dependency (
  $package_name = $name,
) {
  $defined_absent = defined_with_params(Package[$package_name], { ensure => 'absent' })
  $defined_purged = defined_with_params(Package[$package_name], { ensure => 'purged' })

  if ( $defined_absent or $defined_purged ) {
    fail("Package $package_name must be installed but defined not present.")
  }
  else {
    if ! defined(Package[$package_name]) {
      package { $package_name:
        ensure => 'latest',
      }
    }
    else {
      notify {"Package $package_name already defined, skipping.":}
    }
  }
}
