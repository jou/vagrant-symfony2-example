class sf2_example::current_apt_index {
  exec {"apt-get-update":
    command => "/usr/bin/apt-get update",
  }
}
