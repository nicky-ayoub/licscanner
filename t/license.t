use Test::More;

require_ok( 'Lic::Scanner::License' );

 my @tests = (
  
  ['invalid command', "# This is a OK\nnope host hostid\n", 0],
     # Server host hostid
  ['Server host hostid', "# This is a OK\nServer host hostid\n", 1],
  ['Server host hostid 1234', "# This is a OK\nServer host hostid 1234\n", 1],
  ['Server host hostid primary_is_master', "# This is a OK\nServer host hostid primary_is_master\n", 1],
  ['Server host hostid heartbeat_interval=56', "# This is a OK\nServer host hostid heartbeat_interval=56\n", 1],
  ['Server host hostid primary_is_master heartbeat_interval=78', "# This is a bad\nServer host hostid primary_is_master heartbeat_interval=78\n",1],
  ['Server host hostid 4321 primary_is_master heartbeat_interval=89', "# This is a bad\nServer host hostid 4321 primary_is_master heartbeat_interval=89\n",1],
  ['Server host hostid 4321 primary_is_master heartbeat_inter=89', "# This is a bad\nServer host hostid 4321 primary_is_master heartbeat_inter=89\n",0],
  ['Server no options', "# This is a bad\nServer\n",0],
  ['Server no hostid', "# This is a bad\nServer host\n",0],
  ['Server host hostid bad_opt', "# This is a bad\nServer host hostid bad_opt\n",0],
  ['Server  primary_is_master twice', "# This is a bad\nServer host hostid primary_is_master heartbeat_interval=78 primary_is_master\n",0],
  
  ['Vendor minimal', "VENDOR vendor\n",1],
  ['Vendor D', "VENDOR vendor a/daemon/path\n",1],
  ['Vendor D O', "VENDOR vendor a/daemon/path options/file\n",1],
  ['Vendor D O P', "VENDOR vendor a/daemon/path options/file 4321\n",1],
  ['Vendor D P', "VENDOR vendor a/daemon/path 4321\n",1],
  ['Vendor D O P=', "VENDOR vendor a/daemon/path options/file port=4321\n",1],
  ['Vendor D O= P', "VENDOR vendor a/daemon/path options=options/file 4321\n",0], # is this true? once key/value start should be key=value
  ['Vendor D O= P=', "VENDOR vendor a/daemon/path options=options/file port=4321\n",1],
  ['Vendor D O= P= extra', "VENDOR vendor a/daemon/path options=options/file port=4321 extra\n",0],
  ['Vendor no daemon O=', "VENDOR vendor options=options/file\n",1],
  ['Vendor no daemon P=', "VENDOR vendor port=4321\n",1],
  ['Vendor no daemon O= P=', "VENDOR vendor options=options/file port=4321\n",1],
  ['Vendor no daemon P', "VENDOR vendor 4321\n",1],  # presents as a vendor daemon
  ['Vendor no daemon O', "VENDOR vendor options/file\n",1], # presents as a vendor daemon
  ['Vendor nodaemon O P=', "VENDOR vendor an/options/file port=4321\n",1],# presents as a vendor daemon
  ['Vendor nodaemon O P', "VENDOR vendor an/options/file 4321\n",1],# presents as a vendor daemon, options file
  ['Vendor nodaemon O= P', "VENDOR vendor OPTIONS=an/options/file 4321\n",0], 
  ['Vendor bad key', "VENDOR vendor a/daemon/path options=options/file porter=4321\n",0],
  ['Vendor 2 port keys', "VENDOR vendor a/daemon/path options=options/file port=4321  port=231\n",0],
  ['Vendor bad key', "VENDOR vendor a/daemon/path options=options/file porter=4321\n",0],
  ['Vendor bad key', "VENDOR vendor a/daemon/path options=options/file port=4321 boo=ghost\n",0],

  ['Use server', "USE_SERVER\n",1],
  ['Use server', "USE_SERVER to many paramaters\n",0],
  ['Use server', "USE_SERVER options=bad\n",0],

  ['Feature', "FEATURE featurename vendor 2023.111 31-dec-2024 15 VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Feature', "FEATURE featurename vendor 2023.111 31-dec-2024 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Feature', "FEATURE featurename vendor 2023.111 0000 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Feature', "FEATURE featurename vendor 2023.111 31-dec-2024 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Feature', "FEATURE featurename vendor 2023.111 permanent uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Increment', "Increment featurename vendor 2023.111 31-dec-2024 15 VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Increment', "Increment featurename vendor 2023.111 31-dec-2024 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Increment', "Increment featurename vendor 2023.111 0000 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Increment', "Increment featurename vendor 2023.111 31-dec-2024 uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],
  ['Increment', "Increment featurename vendor 2023.111 permanent uncounted VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],

  ['package', "PACKAGE suite sampled 1.0 SIGN=\"<...>\" COMPONENTS=\"apple:1.5:2 orange:3.0:4\"\n", 1],
  ['package missing quote', "PACKAGE suite sampled 1.0 SIGN=\"<...>\" COMPONENTS=\"apple:1.5:2 orange:3.0:4\n", 0],
  ['feature', "FEATURE suite sampled 1.0 31-dec-2020 3 SN=123 SIGN=\"<...>\"\n", 1],


  ['upgrade', "UPGRADE feature vendor from_feat_version to_feat_version \\\npermanent 15 SIGN=\"<...>\"\n",1],
  ['Increment', "Increment f1 sampled 1.000 31-dec-2020 5 SIGN=\"<...>\"\n",1],
  ['upgrade', "UPGRADE f1 sampled 1.000 2.000 31-dec-2020 2 SIGN=\"<...>\"\n",1],
 );

 foreach my $t ( @tests ) {
  my $ret = Lic::Scanner::License::Scan($t->[1]);
  if( @$t == 3){
    if ($t->[2]) {
     ok( $ret, $t->[0] );
    }else {
    ok( !$ret, $t->[0] );
    }
  } else {
    ok( 0, "In valid test: " . $t->[0] );
  }
}
done_testing();