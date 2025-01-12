use Test::More;

require_ok( 'Lic::Scanner::File' );

my $input = 'one

two\
two
# Comment 1
three\
 three\ 
 three
# Comment 2

';
my $expected = 'one
twotwo
three three three
';

my @expected = ("one", "twotwo","three three three");

my $got = Lic::Scanner::File::processBackSlash($input);

my @got = Lic::Scanner::File::processBackSlash($input);

is($got, $expected, "scalar");\
is_deeply(\@got, \@expected, "lines");

done_testing();

