class sf2_example {
  stage { 'apt-update': before => Stage['main'] }
  class { 'sf2_example::current_apt_index': stage => 'apt-update' }
  
  package { ["php5-fpm", "php5-cli", "nginx", "git"]:
    ensure => installed,
  }

  service { "php5-fpm":
    enable => true,
    ensure => running,
    require => Package["php5-fpm"],
  }

  service { "nginx":
    enable => true,
    ensure => running,
    require => Package["nginx"],
  }

  file { "/etc/nginx/sites-enabled/default":
    ensure => absent,
  }

  file { "/etc/nginx/sites-enabled/sf2-example-vhost":
    ensure => file,
    source => "puppet:///modules/sf2_example/nginx/sf2-example-vhost",
    notify => Service["nginx"],
  }

  file { "/etc/php5/conf.d/timezone.ini":
    ensure => file,
    content => 'date.timezone = "Europe/Zurich"',
    notify => Service["php5-fpm"],
  }

  # Bind mount sf2 cache and log directories to local directories. We can't
  # put those on the shared folder because firstly, PHP rund under www-data
  # and /vagrant belongs to vagrant. Secondly, putting many and/or large files
  # on vboxsf is a bad idea
  file { ["/tmp/sf2", "/tmp/sf2/cache", "/tmp/sf2/logs"]:
    ensure => directory,
    # user www-data comes with the nginx package so we require it here
    require => Package["nginx"],
    owner => "www-data",
    mode => 777,
  }

  file { ["/vagrant/app/cache", "/vagrant/app/logs"]:
    ensure => directory,
  }

  temp_bind_mount { "sf2-cache":
    source => "/tmp/sf2/cache",
    dest   => "/vagrant/app/cache",
  }

  temp_bind_mount { "sf2-logs":
    source => "/tmp/sf2/logs",
    dest   => "/vagrant/app/logs",
  }

  # Install composer dependencies. We do this inside the VM so the person checking the project
  # doesn't need to care about it and it works whether the host machine has PHP and composer
  # available.
  composer::exec { 'composer-install':
    cmd => 'install',
    cwd => '/vagrant',
    dev => true,
    no_scripts => false,
    require => [Package["php5-cli"], Temp_bind_mount["sf2-cache"], Temp_bind_mount["sf2-logs"]]
  }

  # Composer runs as root, so if it creates cache entries, the web process can't change them
  exec { "fix-cache-owner":
    command => "/bin/chown -R www-data:www-data /vagrant/app/cache/*",
    require => Composer::Exec['composer-install'],
  }

  # We can't use puppet's built in 'mount' resource since that
  # would generate an entry in /etc/fstab. But the target doesn't
  # exist at boot time since Vagrant has yet to mount it, so
  # rebooting will fail.
  define temp_bind_mount ( $dest = $title, $source ) {
    exec { "bind_mount_${title}":
      command => "mount --bind ${source} ${dest}",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      unless => "grep -q ${dest} /etc/mtab 2>/dev/null",
      require => [File[$dest], File[$source]],
    }
  }
}
