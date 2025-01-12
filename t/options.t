use Test::More;

require_ok( 'Lic::Scanner::Options' );
require_ok( 'Lic::Scanner::File' );

my $input = '# This is a OK
AUTOMATIC_REREAD ON
AUTOMATIC_REREAD OFF
';

my $ret = Lic::Scanner::Options::Scan($input);
ok( $ret, "AUTOMATIC_REREAD parsed");

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

done_testing();

