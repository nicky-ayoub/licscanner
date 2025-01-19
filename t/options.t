use Test::More;

require_ok( 'Lic::Scanner::Options' );

@tests = (
  # AUTOMATIC_REREAD
  ['AUTOMATIC_REREAD ON', "# This is a OK\nAUTOMATIC_REREAD ON\n", 1],
  ['AUTOMATIC_REREAD OFF', "# This is a OK\nAUTOMATIC_REREAD OFF\n", 1],
  ['automatic_reread on lower case', "# This is a OK\nautomatic_reread on\n", 1],
  ['automatic_Reread Off mixed case', "# This is a OK\nautomatic_Reread Off\n", 1],
  ['automatic_Reread BAD value', "# This is a OK\nAUTOMATIC_REREAD BAD\n",0],
  ['AUTO_REREAD Unrecognized keyword', "# This is a OK\nAUTO_REREAD OFF\n",0],
  ['AUTOMATIC_REREAD to many option extras', "# This is a OK\nAUTOMATIC_REREAD ON extra\n",0],
  # ACTIVATION_LOWWATER
  ['ACTIVATION_LOWWATER simple', "# This is a OK\nACTIVATION_LOWWATER ANC 1\n", 1],
  ['ACTIVATION_LOWWATER complex', "# This is a OK\nACTIVATION_LOWWATER ABC:FID=231abc 1\n", 1],
  ['ACTIVATION_LOWWATER complex string space', "# This is a OK\nACTIVATION_LOWWATER \"SPACE FID = 231abc \" 1\n", 1],
  ['ACTIVATION_LOWWATER complex string colon', "# This is a OK\nACTIVATION_LOWWATER \"SPACE : FID = 231abc \" 1\n", 1],
  # BORROW_LOWWATER
  ['BORROW_LOWWATER simple', "# This is a OK\nBORROW_LOWWATER f1 3\n", 1],
  ['BORROW_LOWWATER complex', "# This is a OK\nBORROW_LOWWATER ABC:FID=231abc 3\n", 1],
  ['BORROW_LOWWATER complex string space', "# This is a OK\nBORROW_LOWWATER \"SPACE FID = 231abc \" 1\n", 1],
  ['BORROW_LOWWATER complex string colon', "# This is a OK\nBORROW_LOWWATER \"SPACE : FID = 231abc \" 1\n", 1],
  # DAEMON_SELECT_TIMEOUT
  ['DAEMON_SELECT_TIMEOUT simple', "# This is a OK\nDAEMON_SELECT_TIMEOUT 32\n", 1],
  ['DAEMON_SELECT_TIMEOUT no value', "# This is a OK\nDAEMON_SELECT_TIMEOUT\n",0],
  ['DAEMON_SELECT_TIMEOUT no number', "# This is a OK\nDAEMON_SELECT_TIMEOUT work\n",0],
  # DEBUGLOG
  ['DEBUGLOG simple', "# This is a OK\nDEBUGLOG /var/log/data.txt\n", 1],
  ['DEBUGLOG plus', "# This is a OK\nDEBUGLOG +/var/log/data.txt\n", 1],
  ['DEBUGLOG OBF_ADDMARK', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK\n", 1],
  ['DEBUGLOG double OBF_ADDMARK', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK OBF_ADDMARK\n",$should_fail],
  ['DEBUGLOG  AUTO_ROLLOVER', "# This is a OK\nDEBUGLOG  somepath AUTO_ROLLOVER 23\n", 1],
  ['DEBUGLOG  OBF_ADDMARK then AUTO_ROLLOVER', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23\n", 1],
  ['DEBUGLOG  AUTO_ROLLOVER then OBF_ADDMARK', "# This is a OK\nDEBUGLOG  somepath  AUTO_ROLLOVER 23 OBF_ADDMARK\n", 1],
  ['DEBUGLOG  AUTO_ROLLOVER not a number', "# This is a OK\nDEBUGLOG  somepath AUTO_ROLLOVER five\n",$should_fail],
  ['DEBUGLOG  OBF_ADDMARK then AUTO_ROLLOVER then 2nd OBF_ADDMARK', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23 OBF_ADDMARK\n",0],
  ['DEBUGLOG OBF_ADMARK invalid option', "# This is a OK\nDEBUGLOG  somepath OBF_ADMARK\n",0],
);

foreach my $t ( @tests ) {
  my $ret = Lic::Scanner::Options::Scan($t->[1]);
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

