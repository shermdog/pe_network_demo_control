class profile::cisco_demo (
  String $int1_ipaddress        = '172.16.1.1',
  Integer $int1_netmask         = 24,
  Integer $int1_mtu             = 1500,
  Boolean $int1_enable          = false,
  String $int2_ipaddress        = '172.16.2.2',
  Integer $int2_netmask         = 24,
  Integer $int2_mtu             = 1500,
  Boolean $int2_enable          = false,
  String $int3_ipaddress        = '172.16.3.3',
  Integer $int3_netmask         = 24,
  Integer $int3_mtu             = 1500,
  Boolean $int3_enable          = false,
  String $int4_ipaddress        = '172.16.4.4',
  Integer $int4_netmask         = 24,
  Integer $int4_mtu             = 1500,
  Boolean $int4_enable          = false
) {

  include ciscopuppet::install

  cisco_interface { 'ethernet1/1':
    ensure                                         => 'present',
    ipv4_address                                   => $int1_ipaddress,
    ipv4_netmask_length                            => $int1_netmask,
    mtu                                            => $int1_mtu,
    shutdown                                       => $int1_enable,
    switchport_mode                                => 'disabled',
  }

cisco_interface { 'ethernet1/2':
    ensure                                         => 'present',
    ipv4_address                                   => $int2_ipaddress,
    ipv4_netmask_length                            => $int2_netmask,
    mtu                                            => $int2_mtu,
    shutdown                                       => $int2_enable,
    switchport_mode                                => 'disabled',
  }

cisco_interface { 'ethernet1/3':
    ensure                                         => 'present',
    ipv4_address                                   => $int3_ipaddress,
    ipv4_netmask_length                            => $int3_netmask,
    mtu                                            => $int3_mtu,
    shutdown                                       => $int3_enable,
    switchport_mode                                => 'disabled',
  }

cisco_interface { 'ethernet1/4':
    ensure                                         => 'present',
    ipv4_address                                   => $int4_ipaddress,
    ipv4_netmask_length                            => $int4_netmask,
    mtu                                            => $int4_mtu,
    shutdown                                       => $int4_enable,
    switchport_mode                                => 'disabled',
  }

  cisco_interface { 'loopback1':
    ensure                                         => 'present',
    description                                    => 'Puppet FTW',
    ipv4_address                                   => '3.3.3.3',
    ipv4_netmask_length                            => '24',
  }

  cisco_vxlan_vtep { 'nve1':
    ensure                          => present,
    description                     => 'Configured by puppet',
    host_reachability               => 'evpn',
    shutdown                        => 'false',
    source_interface                => 'loopback1',
  }

  cisco_vxlan_vtep_vni {'nve1 10000':
    ensure              => present,
    assoc_vrf           => false,
    ingress_replication => 'static',
    peer_list           => ['4.4.4.4', '5.5.5.5'],
  }

  cisco_bgp { '65001 default':
    ensure        => 'present',
    maxas_limit   => '8',
    router_id     => '192.0.2.4',
    shutdown      => 'false',
  }

  cisco_bgp_neighbor { '65001 default 192.0.3.1':
    ensure                 => 'present',
    remote_as              => '65004',
    require                => Cisco_bgp['65001 default'],
  }

}
