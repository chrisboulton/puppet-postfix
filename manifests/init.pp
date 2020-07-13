class postfix(
  $transport_file = '/etc/postfix/transport',
  $service_enable = true,
  $service_ensure = 'running',
) {
  package { 'postfix':
    ensure => 'present',
    notify => Exec['rebuild postfix transport'],
  }

  service { 'postfix':
    ensure  => $service_ensure,
    enable  => $service_enable,
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

  # The custom version of augeas lense for master.cf.
  # The stock version does not (yet) support the unix-dgram service type.
  # This causes issues with the default master.cf on buster.
  # Hence this fix until upstream gets updated.
  file { '/etc/postfix/augeas':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
  file { '/etc/postfix/augeas/postfix_master.aug':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => file('postfix/augeas/postfix_master.aug'),
    require => File['/etc/postfix/augeas']
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

  exec { 'rebuild postfix transport':
    command     => "postmap ${transport_file}",
    refreshonly => true,
  }
}
