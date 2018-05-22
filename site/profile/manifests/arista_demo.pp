class profile::arista_demo (
  Hash $interfaces = {},
) {

  package { 'rbeapi':
    ensure   => 'installed',
    provider => 'puppet_gem',
  }

  $interfaces.each |$interface, $parameters| {
    eos_ipinterface { $interface:
      ensure  => 'present',
      address => $parameters[ipaddress],
      mtu     => $parameters[mtu],
    }
  }

  eos_interface { 'Loopback1':
    ensure => 'present',
    enable => true,
  }

  eos_vxlan { 'Vxlan1':
    source_interface => 'Loopback1',
    udp_port         => 5500,
    require          => Eos_interface['Loopback1'],
  }

  eos_bgp_config { '65001':
    ensure             => present,
    enable             => true,
    router_id          => '192.0.2.4',
    maximum_paths      => 8,
    maximum_ecmp_paths => 8,
  }

  eos_bgp_neighbor { 'Edge':
    ensure         => 'present',
    enable         => 'true',
    next_hop_self  => 'disable',
    send_community => 'disable',
  }

  eos_bgp_neighbor { '192.0.3.1':
    ensure          => 'present',
    enable          => 'false',
    next_hop_self   => 'enable',
    peer_group      => 'Edge',
    remote_as       => '65004',
    send_community  => 'enable',
    require         => Eos_bgp_neighbor['Edge'],
  }

  # Purge unmanaged resources
  # We do not want to modify the managment interface
  eos_ipinterface { 'Management1': ensure  => 'present' }
  # Vxlan1 ipinterface is automatically created by eos_vxlan
  eos_ipinterface { 'Vxlan1': ensure  => 'present' }
  # Loopbacks are also ip interfaces by default
  eos_ipinterface { 'Loopback1': ensure  => 'present' }
  resources { 'eos_ipinterface': purge => true }
  resources { 'eos_vxlan': purge => true }
  resources { 'eos_bgp_config': purge => true }
  resources { 'eos_bgp_neighbor': purge => true }
}
