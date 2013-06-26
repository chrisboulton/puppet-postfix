class postfix(
  $transport_file = '/etc/postfix/transport'
) {
  package { 'postfix':
    ensure => 'present',
  }

  service { 'postfix':
    ensure  => true,
    enable  => true,
    require => Package['postfix'],
  }

  file { ['/etc/postfix/main.cf', '/etc/postfix/master.cf']:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# managed by puppet\n",
    replace => false,
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  file { '/etc/postfix/transport':
    ensure  => 'present',
    content => '# managed by puppet',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => false,
    require => Package['postfix'],
    notify  => Exec['rebuild postfix transport'],
  }

  # puppet in masterless mode won't synchronize augeas lenses, so do this manually
  file { '/usr/share/augeas/lenses/postfix_transport.aug':
    source => "puppet:///modules/${module_name}/augeas/postfix_transport.aug",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  exec { 'rebuild postfix transport':
    command     => "postmap ${transport_file}",
    refreshonly => true,
  }
}