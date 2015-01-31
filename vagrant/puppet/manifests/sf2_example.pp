node "vagrant-sf2-example" {
  include sf2_example
  class { 'composer':
    suhosin_enabled => false,
  }
}
