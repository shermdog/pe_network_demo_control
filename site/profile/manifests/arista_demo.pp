class profile::arista_demo {

  package { 'rbeapi':
    ensure   => 'installed',
    provider => 'puppet_gem',
  }

  eos_ipinterface { 'Ethernet1':
    ensure  => 'present',
    address => '1.1.1.1/24',
    mtu     => '1500',
  }

  eos_ipinterface { 'Ethernet2':
    ensure  => 'present',
    address => '2.2.2.2/24',
    mtu     => '1500',
  }

  eos_interface { 'Loopback1':
    ensure => 'present',
    enable => 'true',
  }
  
  eos_vxlan { 'Vxlan1':
    source_interface => 'Loopback1',
    udp_port => 5500,
    require => Eos_interface['Loopback1'],
  }

  eos_bgp_config { '65001':
    ensure             => present,
    enable             => true,
    router_id          => '192.0.2.4',
    maximum_paths      => 8,
    maximum_ecmp_paths => 8,
  }
  
  eos_bgp_neighbor { '192.0.3.1':
    ensure         => present,
    enable         => true,
    peer_group     => 'Edge',
    remote_as      => 65004,
    send_community => 'enable',
    next_hop_self  => 'enable',
  }
}
