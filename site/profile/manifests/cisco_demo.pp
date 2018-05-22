class profile::cisco_demo (
  Hash $interfaces = {},
  Hash $vlans = {},
) {

  include ciscopuppet::install

  $vlans.each |$vlan, $parameters| {
    cisco_vlan { $vlan:
      ensure    => $parameters[ensure],
      shutdown  => $parameters[shutdown],
      state     => $parameters[state],
      vlan_name => $parameters[vlan_name],
    }
  }

  $interfaces.each |$interface, $parameters| {
    cisco_interface { $interface:
      ensure              => 'present',
      ipv4_address        => $parameters[ipaddress],
      ipv4_netmask_length => $parameters[netmask],
      mtu                 => $parameters[mtu],
      shutdown            => $parameters[shutdown],
      access_vlan         => $parameters[access_vlan],
      switchport_mode     => $parameters[switchport_mode],
    }
  }

  cisco_interface { 'loopback1':
    ensure              => 'present',
    description         => 'Puppet FTW',
    ipv4_address        => '3.3.3.3',
    ipv4_netmask_length => '24',
  }

  cisco_vxlan_vtep { 'nve1':
    ensure            => present,
    description       => 'Configured by puppet',
    host_reachability => 'evpn',
    shutdown          => false,
    source_interface  => 'loopback1',
  }

  cisco_vxlan_vtep_vni {'nve1 10000':
    ensure              => present,
    assoc_vrf           => false,
    ingress_replication => 'static',
    peer_list           => ['4.4.4.4', '5.5.5.5'],
  }


  cisco_bgp { '65001 default':
    ensure      => 'present',
    maxas_limit => '8',
    router_id   => '192.0.2.4',
    shutdown    => false,
  }

  cisco_bgp_neighbor { '65001 default 192.0.3.1':
    ensure    => 'present',
    remote_as => '65004',
    require   => Cisco_bgp['65001 default'],
  }

  # Purge unmanaged resources
  resources { 'cisco_vlan': 
    purge => true,
    before => Cisco_vlan[keys($vlans)]
  }
  resources { 'cisco_vxlan_vtep': purge => true }
  resources { 'cisco_vxlan_vtep_vni': purge => true }
  resources { 'cisco_bgp': purge => true }
  resources { 'cisco_bgp_neighbor': purge => true }
  # ciscopuppet module does not allow changing mgmt interfaces
  # but we need this here to prevent purge from trying
  cisco_interface { 'mgmt0': ensure => 'present' }
  resources { 'cisco_interface': purge => true }
}
