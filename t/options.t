use Test::More;

require_ok( 'Lic::Scanner::Options' );
require_ok( 'Lic::Scanner::File' );

my $input = '# This is a OK
AUTOMATIC_REREAD ON
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "AUTOMATIC_REREAD ON");

my $input = '# This is a OK
AUTOMATIC_REREAD OFF
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "AUTOMATIC_REREAD OFF");

my $input = '# This is a OK
automatic_reread on
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "automatic_reread on");

my $input = '# This is a OK
automatic_reread off
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "automatic_reread off");

my $input = '# This is a OK
AUTOMATIC_REREAD BAD
';

my $ret = Lic::Scanner::Options::Scan($input);
ok( !$ret, "AUTOMATIC_REREAD BAD value");

my $input = '# This is BAD
AUTOMATI_REREAD OFF
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( !$ret, "AUTOMATIC_REREAD Unrecognized keyword");

my $input = '# This is BAD
AUTOMATIC_REREAD OFF extra
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( !$ret, "AUTOMATIC_REREAD extra data");

#---------
my $input = '# This is OK
ACTIVATION_LOWWATER ABC 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "ACTIVATION_LOWWATER simple");

my $input = '# This is OK
ACTIVATION_LOWWATER ABC:FID=231abc 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "ACTIVATION_LOWWATER complex");

my $input = '# This is OK
ACTIVATION_LOWWATER "SPACE FID = 231abc " 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "ACTIVATION_LOWWATER complex string space");

my $input = '# This is OK
ACTIVATION_LOWWATER "SPACE : FID = 231abc " 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "ACTIVATION_LOWWATER complex string colon");


#---------
my $input = '# This is OK
BORROW_LOWWATER f1 3 
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "BORROW_LOWWATER simple");

my $input = '# This is OK
BORROW_LOWWATER ABC:FID=231abc 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "BORROW_LOWWATER complex");

my $input = '# This is OK
BORROW_LOWWATER "SPACE FID = 231abc " 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "BORROW_LOWWATER complex string space");

my $input = '# This is OK
BORROW_LOWWATER "SPACE : FID = 231abc " 1
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "BORROW_LOWWATER complex string colon");

#-------
my $input = '# This is OK
DAEMON_SELECT_TIMEOUT 32
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "DAEMON_SELECT_TIMEOUT simple");

my $input = '# This is bad
DAEMON_SELECT_TIMEOUT
';
my $ret = Lic::Scanner::Options::Scan($input);
ok(! $ret, "DAEMON_SELECT_TIMEOUT no value");
my $input = '# This is bad
  DAEMON_SELECT_TIMEOUT word
';
my $ret = Lic::Scanner::Options::Scan($input);
ok(! $ret, "DAEMON_SELECT_TIMEOUT no number");


#-------
my $input = '# This is OK
DEBUGLOG /var/log/data.txt
';
my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "DEBUGLOG  simple");

my $input = '# This is ok
DEBUGLOG  +/var/log/data.txt
';
my $ret = Lic::Scanner::Options::Scan($input);
ok($ret, "DEBUGLOG  plus");

my $input = '# This is ok
  DEBUGLOG  somepath OBF_ADDMARK 
';
my $ret = Lic::Scanner::Options::Scan($input);
ok($ret, "DEBUGLOG  OBF_ADDMARK");

my $input = '# This is bad
  DEBUGLOG  somepath OBF_ADDMARK  OBF_ADDMARK
';
my $ret = Lic::Scanner::Options::Scan($input);
ok(!$ret, "DEBUGLOG  double OBF_ADDMARK");

my $input = '# This is ok
  DEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23
';
my $ret = Lic::Scanner::Options::Scan($input);
ok($ret, "DEBUGLOG AUTO_ROLLOVER  OBF_ADDMARK");

my $input = '# This is ok
  DEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23
';
my $ret = Lic::Scanner::Options::Scan($input);
ok($ret, "DEBUGLOG AUTO_ROLLOVER  OBF_ADDMARK");

my $input = '# This is bad
  DEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER five
';
my $ret = Lic::Scanner::Options::Scan($input);
ok(!$ret, "DEBUGLOG AUTO_ROLLOVER bad value");

my $input = '# This is bad
  DEBUGLOG  somepath OBF_ADDMARK  AUTO_ROLLOVER 23 OBF_ADDMARK
';
my $ret = Lic::Scanner::Options::Scan($input);
ok(!$ret, "DEBUGLOG AUTO_ROLLOVER  double OBF_ADDMARK");
done_testing();

