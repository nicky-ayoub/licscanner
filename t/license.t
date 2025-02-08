use Test::More;

require_ok( 'Lic::Scanner::License' );

 my @tests = (
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
  ['Feature', "FEATURE feature vendor feat_version exp_date num_lic VENDOR_STRING=\"this is a vendor string\" \\\n AUTH={ a=\"str\" b=(a b c) sign3=\"x y x\"} SIGN=\"<...>\"\n",1],


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