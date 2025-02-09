use Test::More;

require_ok( 'Lic::Scanner::Options' );

 my @tests = (
  # AUTOMATIC_REREAD
  ['AUTOMATIC_REREAD ON', "# This is a OK\nAUTOMATIC_REREAD ON\n", 1],
  ['AUTOMATIC_REREAD OFF', "# This is a OK\nAUTOMATIC_REREAD OFF\n", 1],
  ['automatic_reread on lower case', "# This is a OK\nautomatic_reread on\n", 1],
  ['automatic_Reread Off mixed case', "# This is a OK\nautomatic_Reread Off\n", 1],
  ['automatic_Reread BAD value', "# This is a bad\nAUTOMATIC_REREAD BAD\n",0],
  ['AUTO_REREAD Unrecognized keyword', "# This is a bad\nAUTO_REREAD OFF\n",0],
  ['AUTOMATIC_REREAD to many option extras', "# This is a bad\nAUTOMATIC_REREAD ON extra\n",0],

  # BORROW_LOWWATER
  ['BORROW_LOWWATER simple', "# This is a OK\nBORROW_LOWWATER f1 3\n", 1],
  ['BORROW_LOWWATER complex', "# This is a OK\nBORROW_LOWWATER ABC:FID=231abc 3\n", 1],
  ['BORROW_LOWWATER complex string space', "# This is a OK\nBORROW_LOWWATER \"SPACE FID=231abc\" 1\n", 1],
  # DAEMON_SELECT_TIMEOUT
  ['DAEMON_SELECT_TIMEOUT simple', "# This is a OK\nDAEMON_SELECT_TIMEOUT 32\n", 1],
  ['DAEMON_SELECT_TIMEOUT no value', "# This is a bad\nDAEMON_SELECT_TIMEOUT\n",0],
  ['DAEMON_SELECT_TIMEOUT no number', "# This is a bad\nDAEMON_SELECT_TIMEOUT work\n",0],
  # DEBUGLOG
  ['DEBUGLOG simple', "# This is a OK\nDEBUGLOG /var/log/data.txt\n", 1],
  ['DEBUGLOG plus', "# This is a OK\nDEBUGLOG +/var/log/data.txt\n", 1],
  ['DEBUGLOG OBF_ADDMARK', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK\n", 1],
  ['DEBUGLOG double OBF_ADDMARK', "# This is a bad\nDEBUGLOG  somepath OBF_ADDMARK OBF_ADDMARK\n",0],
  ['DEBUGLOG  AUTO_ROLLOVER', "# This is a OK\nDEBUGLOG  somepath AUTO_ROLLOVER 23\n", 1],
  ['DEBUGLOG  OBF_ADDMARK then AUTO_ROLLOVER', "# This is a OK\nDEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23\n", 1],
  ['DEBUGLOG  AUTO_ROLLOVER not a number', "# This is a bad\nDEBUGLOG  somepath AUTO_ROLLOVER five\n",0],
  ['DEBUGLOG  OBF_ADDMARK then AUTO_ROLLOVER then 2nd OBF_ADDMARK', "# This is a bad\nDEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23 OBF_ADDMARK\n",0],
  ['DEBUGLOG OBF_ADMARK invalid option', "# This is a bad\nDEBUGLOG  somepath OBF_ADMARK\n",0],
  # EXCLUDE
  ['EXCLUDE type USER',"# This is a OK\nEXCLUDE f1 USER hank\n", 1],
  ['EXCLUDE type host',"# This is a OK\nEXCLUDE f1 host server\n",1],
  ['EXCLUDE BAD type',"# This is a bad\nEXCLUDE f1 BAD hank\n", 0],
  ['EXCLUDE complex feature colon',"# This is a OK\nEXCLUDE f1:K=v USER hank\n", 1],
  ['EXCLUDE complex feature quote',"# This is a OK\nEXCLUDE \"f:1 K=v\" USER hank\n", 1],
  # EXCLUDE_BORROW
  ['EXCLUDE_BORROW type USER',"# This is a OK\nEXCLUDE_BORROW f1 USER hank\n", 1],
  ['EXCLUDE_BORROW type host',"# This is a OK\nEXCLUDE_BORROW f1 host server\n",1],
  ['EXCLUDE_BORROW BAD type',"# This is a bad\nEXCLUDE_BORROW f1 BAD hank\n", 0],
  ['EXCLUDE_BORROW missing host',"# This is a bad\nEXCLUDE_BORROW f1 host\n", 0],
  ['EXCLUDE_BORROW complex feature colon',"# This is a OK\nEXCLUDE_BORROW f1:K=v USER hank\n", 1],
  ['EXCLUDE_BORROW complex feature quote',"# This is a OK\nEXCLUDE_BORROW \"f:1 K=v\" USER hank\n", 1],
  # EXCLUDE_ENTITLEMENT
  [ 'EXCLUDE_ENTITLEMENT simple', "# This is a OK\nEXCLUDE_ENTITLEMENT AB456 USER pete\n",1],
  [ 'EXCLUDE_ENTITLEMENT host', "# This is a OK\nEXCLUDE_ENTITLEMENT AB456 HOST server\n",1],
  [ 'EXCLUDE_ENTITLEMENT project', "# This is a bad\nEXCLUDE_ENTITLEMENT AB456 PROJECT pete\n",0],
  # EXCLUDEALL
  [ 'EXCLUDEALL simple', "# This is a OK\nEXCLUDEALL  USER pete\n",1],
  [ 'EXCLUDEALL host', "# This is a OK\nEXCLUDEALL  host hostname\n",1],
  [ 'EXCLUDEALL project', "# This is a OK\nEXCLUDEALL  project name\n",1],
  [ 'EXCLUDEALL no name', "# This is a bad\nEXCLUDEALL  host\n",0],
  [ 'EXCLUDEALL bad', "# This is a bad\nEXCLUDEALL  bad type\n",0],  
  # EXCLUDEALL_ENTITLEMENT
  [ 'EXCLUDEALL_ENTITLEMENT simple', "# This is a OK\nEXCLUDEALL_ENTITLEMENT  USER pete\n",1],
  [ 'EXCLUDEALL_ENTITLEMENT host', "# This is a OK\nEXCLUDEALL_ENTITLEMENT  host hostname\n",1],
  [ 'EXCLUDEALL_ENTITLEMENT project', "# This is a bad\nEXCLUDEALL_ENTITLEMENT  project name\n",0],
  [ 'EXCLUDEALL_ENTITLEMENT no name', "# This is a bad\nEXCLUDEALL_ENTITLEMENT  host\n",0],
  [ 'EXCLUDEALL_ENTITLEMENT bad', "# This is a bad\nEXCLUDEALL_ENTITLEMENT  bad type\n",0],
  # FQDN_MATCHING
  ['FQDN_MATCHING lenient', "# This is a OK\nFQDN_MATCHING LENIENT\n", 1],
  ['FQDN_MATCHING exact', "# This is a OK\nFQDN_MATCHING EXACT\n", 1],
  ['FQDN_MATCHING lenient lower case', "# This is a OK\nFQDN_MATCHING lenient\n", 1],
  ['FQDN_MATCHING exact lower case', "# This is a OK\nFQDN_MATCHING exact\n", 1],
  ['FQDN_MATCHING EXact mixed case', "# This is a OK\nFQDN_MATCHING EXact\n", 1],
  ['FQDN_MATCHING not exact or lenient', "# This is a BAD\nFQDN_MATCHING bad\n",0],
  # GROUP
  ['GROUP simple', "group Hackers bob   howard    james\n", 1],
  ['GROUP simple', "Group Hackers bob\n", 1],
  ['GROUP no members', "group Hacker\n", 0],
  ['GROUP no group name', "group\n", 0],
  # GROUPCASEINSENSITIVE
  ['GROUPCASEINSENSITIVE ON', "# This is a OK\nGROUPCASEINSENSITIVE ON\n", 1],
  ['GROUPCASEINSENSITIVE OFF', "# This is a OK\nGROUPCASEINSENSITIVE OFF\n", 1],
  ['groupcaseinsensitive on lower case', "# This is a OK\ngroupcaseinsensitive on\n", 1],
  ['groupCaseInsensitive Off mixed case', "# This is a OK\ngroupCaseInsensitive Off\n", 1],
  ['groupcaseinsensitive BAD value', "# This is a bad\ngroupCaseInsensitive BAD\n",0],
  # HOST_GROUP
  ['HOST_GROUP simple', "host_group server bob   howard    james\n", 1],
  ['HOST_GROUP single', "HOST_GROUP servers bob\n", 1],
  ['HOST_GROUP no members', "HOST_GROUP servers\n", 0],
  ['HOST_GROUP no hostgroup name', "HOST_GROUP\n", 0],
  # INCLUDE
  ['INCLUDE type USER',"# This is a OK\nINCLUDE f1 USER hank\n", 1],
  ['INCLUDE type host',"# This is a OK\nINCLUDE f1 host server\n",1],
  ['INCLUDE BAD type',"# This is a bad\nINCLUDE f1 BAD hank\n", 0],
  ['INCLUDE complex feature colon',"# This is a OK\nINCLUDE f1:K=v USER hank\n", 1],
  ['INCLUDE complex feature quote',"# This is a OK\nINCLUDE \"f:1 K=v\" USER hank\n", 1],
    # INCLUDE_BORROW
  ['INCLUDE_BORROW type USER',"# This is a OK\nINCLUDE_BORROW f1 USER hank\n", 1],
  ['INCLUDE_BORROW type host',"# This is a OK\nINCLUDE_BORROW f1 host server\n",1],
  ['INCLUDE_BORROW BAD type',"# This is a bad\nINCLUDE_BORROW f1 BAD hank\n", 0],
  ['INCLUDE_BORROW missing host',"# This is a bad\nINCLUDE_BORROW f1 host\n", 0],
  ['INCLUDE_BORROW complex feature colon',"# This is a OK\nINCLUDE_BORROW f1:K=v USER hank\n", 1],
  ['INCLUDE_BORROW complex feature quote',"# This is a OK\nINCLUDE_BORROW \"f:1 K=v\" USER hank\n", 1],
  # INCLUDE_ENTITLEMENT
  [ 'INCLUDE_ENTITLEMENT simple', "# This is a OK\nINCLUDE_ENTITLEMENT AB456 USER pete\n",1],
  [ 'INCLUDE_ENTITLEMENT host', "# This is a OK\nINCLUDE_ENTITLEMENT AB456 HOST server\n",1],
  [ 'INCLUDE_ENTITLEMENT project', "# This is a bad\nINCLUDE_ENTITLEMENT AB456 PROJECT pete\n",0],
    # INCLUDEALL
  [ 'INCLUDEALL simple', "# This is a OK\nINCLUDEALL  USER pete\n",1],
  [ 'INCLUDEALL host', "# This is a OK\nINCLUDEALL  host hostname\n",1],
  [ 'INCLUDEALL project', "# This is a OK\nINCLUDEALL  project name\n",1],
  [ 'INCLUDEALL no name', "# This is a bad\nINCLUDEALL  host\n",0],
  [ 'INCLUDEALL bad', "# This is a bad\nINCLUDEALL  bad type\n",0],  
  # INCLUDEALL_ENTITLEMENT
  [ 'INCLUDEALL_ENTITLEMENT simple', "# This is a OK\nINCLUDEALL_ENTITLEMENT  USER pete\n",1],
  [ 'INCLUDEALL_ENTITLEMENT host', "# This is a OK\nINCLUDEALL_ENTITLEMENT  host hostname\n",1],
  [ 'INCLUDEALL_ENTITLEMENT project', "# This is a bad\nINCLUDEALL_ENTITLEMENT  project name\n",0],
  [ 'INCLUDEALL_ENTITLEMENT no name', "# This is a bad\nINCLUDEALL_ENTITLEMENT  host\n",0],
  [ 'INCLUDEALL_ENTITLEMENT bad', "# This is a bad\nINCLUDEALL_ENTITLEMENT  bad type\n",0],
  # LINGER
  ['LINGER simple', "# This is a OK\nLINGER f1 3\n", 1],
  ['LINGER simple', "# This is a OK\nLINGER 0\n", 1], # This is seen in some options files.
  ['LINGER complex', "# This is a OK\nLINGER ABC:FID=231abc 3\n", 1],
  ['LINGER complex string space', "# This is a OK\nLINGER \"SPACE FID=231abc\" 1\n", 1],
  # MAX
  ['MAX type USER',"# This is a OK\nMAX 5 f1 USER hank\n", 1],
  ['MAX type host',"# This is a OK\nMAX 5 f1 host server\n",1],
  ['MAX BAD type',"# This is a bad\nMAX 5 f1 BAD hank\n", 0],
  ['MAX complex feature colon',"# This is a OK\nMAX 5 f1:K=v USER hank\n", 1],
  ['MAX complex feature quote',"# This is a OK\nMAX 5 \"f:1 K=v\" USER hank\n", 1],
  ['MAX type USER',"# This is a OK\nMAX nan f1 USER hank\n", 0],
  ['MAX type host',"# This is a OK\nMAX nan f1 host server\n",0],
  ['MAX complex feature colon',"# This is a OK\nMAX nan f1:K=v USER hank\n", 0],
  ['MAX complex feature quote',"# This is a OK\nMAX nan \"f:1 K=v\" USER hank\n", 0],
  # MAX_BORROW_HOURS
  ['MAX_BORROW_HOURS simple', "# This is a OK\nMAX_BORROW_HOURS f1 3\n", 1],
  ['MAX_BORROW_HOURS complex', "# This is a OK\nMAX_BORROW_HOURS ABC:FID=231abc 3\n", 1],
  ['MAX_BORROW_HOURS complex string space', "# This is a OK\nMAX_BORROW_HOURS \"SPACE FID=231abc\" 1\n", 1],
  # MAX_CONNECTIONS
  ['MAX_CONNECTIONS simple', "# This is a OK\n   MAX_CONNECTIONS    1233\n", 1],
  ['MAX_CONNECTIONS no args', "# This is a OK\nMAX_CONNECTIONS\n", 0],
  ['MAX_CONNECTIONS too many numbers', "# This is a OK\nMAX_CONNECTIONS 12 32\n", 0],
  ['MAX_CONNECTIONS nan', "# This is a OK\nMAX_CONNECTIONS twelve\n", 0],
  # MAX_OVERDRAFT
  ['MAX_OVERDRAFT simple', "# This is a OK\n MAX_OVERDRAFT f1 3\n", 1],
  ['MAX_OVERDRAFT complex', "# This is a OK\nMAX_OVERDRAFT ABC:FID=231abc 3\n", 1],
  ['MAX_OVERDRAFT complex string space', "# This is a OK\nMAX_OVERDRAFT \"SPACE FID=231abc\" 1\n", 1],
  # NOLOG
  ['NOLOG IN', "# This is a OK\nNOLOG IN\n", 1],
  ['NOLOG OUT', "# This is a OK\nNOLOG OUT\n", 1],
  ['NOLOG denied', "# This is a OK\nNOLOG denied\n", 1],
  ['NOLOG Queued', "# This is a OK\nNOLOG Queued\n", 1],
  ['NOLOG unsupported lower case', "# This is a OK\nNOLOG unsupported\n", 1],
  ['NOLOG upgrade', "# This is a OK\nNOLOG upgrade\n", 1],
  ['NOLOG deQueued', "# This is a OK\nNOLOG deQueued\n", 1],
  ['NOLOG BAD value', "# This is a bad\nNOLOG BAD\n",0],
  ['NOLOG only', "# This is a bad\nNOLOG\n",0],
  # RESERVE
  ['RESERVE type USER',"# This is a OK\nRESERVE 5 f1 USER hank\n", 1],
  ['RESERVE type host',"# This is a OK\nRESERVE 5 f1 host server\n",1],
  ['RESERVE BAD type',"# This is a bad\nRESERVE 5 f1 BAD hank\n", 0],
  ['RESERVE complex feature colon',"# This is a OK\nRESERVE 5 f1:K=v USER hank\n", 1],
  ['RESERVE complex feature quote',"# This is a OK\nRESERVE 5 \"f:1 K=v\" USER hank\n", 1],
  ['RESERVE type USER',"# This is a OK\nRESERVE nan f1 USER hank\n", 0],
  ['RESERVE type host',"# This is a OK\nRESERVE nan f1 host server\n",0],
  ['RESERVE complex feature colon',"# This is a OK\nRESERVE nan f1:K=v USER hank\n", 0],
  ['RESERVE complex feature quote',"# This is a OK\nRESERVE nan \"f:1 K=v\" USER hank\n", 0],
  # TIMEOUT
  ['TIMEOUT simple', "# This is a OK\nTIMEOUT f1 3\n", 1],
  ['TIMEOUT simple', "# This is a OK\nTIMEOUT 0\n", 1], # This is seen in some options files.
  ['TIMEOUT complex', "# This is a OK\nTIMEOUT ABC:FID=231abc 3\n", 1],
  ['TIMEOUT complex string space', "# This is a OK\nTIMEOUT \"SPACE FID=231abc\" 1\n", 1],
  # TIMEOUTALL
  ['TIMEOUTALL simple', "# This is a OK\n   TIMEOUTALL    1233\n", 1],
  ['TIMEOUTALL no args', "# This is a OK\nTIMEOUTALL\n", 0],
  ['TIMEOUTALL too many numbers', "# This is a OK\nTIMEOUTALL 12 32\n", 0],
  ['TIMEOUTALL nan', "# This is a OK\nTIMEOUTALL twelve\n", 0],
  # REPORTLOG
  ['REPORTLOG file', "# This is a OK\nREPORTLOG /var/log/data.txt\n", 1],
  ['REPORTLOG plus file', "# This is a OK\nreportlog +/var/log/data.txt\n", 1],
  ['REPORTLOG plus file hide', "# This is a OK\nREPORTLOG +/var/log/data.txt hide_USER\n", 1],
  ['REPORTLOG hide', "# This is a OK\nREPORTLOG /var/log/data.txt hide_USER\n", 1],
  ['REPORTLOG nothing', "# This is a OK\nREPORTLOG\n", 0],
  ['REPORTLOG plushide, no file', "# This is a OK\nREPORTLOG + hide_USER\n", 0],
  ['REPORTLOG only plus', "# This is a OK\nREPORTLOG +\n", 0],

    # ACTIVATION_EXPIRY_DAYS
  ['ACTIVATION_EXPIRY_DAYS entid 4', "# This is a OK\nACTIVATION_EXPIRY_DAYS entid 1\n", 1],
  ['ACTIVATION_EXPIRY_DAYS entid 4', "# This is a OK\nACTIVATION_EXPIRY_DAYS entid:FID=filid4 2\n", 1],
  ['ACTIVATION_EXPIRY_DAYS no params', "# This is a bad\nACTIVATION_EXPIRY_DAYS\n",0],
  ['ACTIVATION_EXPIRY_DAYS no number', "# This is a bad\nACTIVATION_EXPIRY_DAYS entid\n",0],
  # ACTIVATION_LOWWATER
  ['ACTIVATION_LOWWATER simple', "# This is a OK\nACTIVATION_LOWWATER  ANC 1\n", 1],
  ['ACTIVATION_LOWWATER complex', "# This is a OK\nACTIVATION_LOWWATER  ABC:FID=231abc 2\n", 1],

  
  
  # These must fail with unquoted and missing the colon.
  ['TIMEOUT complex string ', "# This is a bad\nTIMEOUT SPACE FID=231abc 1\n", 0],
  ['MAX_OVERDRAFT complex string ', "# This is a bad\nMAX_OVERDRAFT SPACE FID=231abc 1\n", 0],
  ['MAX_BORROW_HOURS complex string ', "# This is a bad\nMAX_BORROW_HOURS SPACE FID=231abc 1\n", 0],
  ['LINGER complex string ', "# This is a bad\nLINGER SPACE FID=231abc 1\n", 0],
  ['BORROW_LOWWATER complex string ', "# This is a bad\nBORROW_LOWWATER SPACE FID=231abc 1\n", 0],

  # These may be the way it works, quotes must be used if colon is replaced by space.
  ['TIMEOUT  complex string no colon', "# This is a bad\nTIMEOUT \"SPACE FID=231abc\" 1\n", 1],
  ['MAX_OVERDRAFT  complex string no colon', "# This is a bad\nMAX_OVERDRAFT \"SPACE FID=231abc\" 1\n", 1],
  ['MAX_BORROW_HOURS  complex string no colon', "# This is a bad\nMAX_BORROW_HOURS \"SPACE FID=231abc\" 1\n", 1],
  ['LINGER  complex string no colon', "# This is a bad\nLINGER \"SPACE FID=231abc\" 1\n", 1],
  ['BORROW_LOWWATER  complex string no colon', "# This is a bad\nBORROW_LOWWATER \"SPACE FID=231abc\" 1\n", 1],
  
  ['ACTIVATION_LOWWATER no complex no colon', "# This is a bad, not quotes\nACTIVATION_LOWWATER FeatureNoColon FID=231abc 4\n", 0],
  ['ACTIVATION_LOWWATER no complex string no colon', "# This is a bad\nACTIVATION_LOWWATER \"FeatureNoColon FID=231abc\" 4\n", 1],
);

# These test fail in Scan but pass in Scan3. 
 my @tests2 = (
  
  # Scan does not see the order as a probelm
  ['DEBUGLOG  AUTO_ROLLOVER then OBF_ADDMARK', "# This is a bad order\nDEBUGLOG  somepath  AUTO_ROLLOVER 23 OBF_ADDMARK\n", 0],

  # I think the quotes in the pattern may be part of the issue
  ['ACTIVATION_LOWWATER complex string',    "# This is a bad\nACTIVATION_LOWWATER   \"ent:FID=231abc\" 3\n", 1],

  # These may be bad, but they are properly scanned.
  ['TIMEOUT complex string colon but OK in string', "# This was bad\nTIMEOUT \"SPACE:FID=231abc\" 1\n", 1],
  ['MAX_OVERDRAFT complex string colon but OK in string', "# This was bad\nMAX_OVERDRAFT \"SPACE:FID=231abc\" 1\n", 1],
  ['MAX_BORROW_HOURS complex string colon but OK in string', "# This was bad\nMAX_BORROW_HOURS \"SPACE:FID=231abc\" 1\n", 1],
  ['LINGER complex string colon but OK in string', "# This was bad\nLINGER \"SPACE:FID=231abc\" 1\n", 1],
  ['BORROW_LOWWATER complex string colon but OK in string', "# This was bad\nBORROW_LOWWATER \"SPACE:FID=231abc\" 1\n", 1],

 );
  
  foreach my $t ( @tests, @tests2 ) {
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

foreach my $t ( @tests, @tests2 ) {
  my $ret = Lic::Scanner::Options::Scan2($t->[1]);
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

# These tests a fail when using Scan. The behave ok in Scan2.
  # foreach my $t ( @tests2 ) {
  #   my $ret = Lic::Scanner::Options::Scan($t->[1]);
  #   if( @$t == 3){
  #     if ($t->[2]) {
  #     ok( $ret, $t->[0] );
  #     }else {
  #     ok( !$ret, $t->[0] );
  #     }
  #   } else {
  #     ok( 0, "In valid test: " . $t->[0] );
  #   }
  # }

done_testing();

