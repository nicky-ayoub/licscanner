package Lic::Scanner::Chunker;

use strict;
use warnings;
use 5.36.0;
use Data::Dumper;
use Text::Balanced qw (
  extract_delimited
  extract_bracketed
  extract_quotelike
  extract_codeblock
  extract_variable
  extract_tagged
  extract_multiple
  gen_delimited_pat
  gen_extract_tagged
);

# ABSTRACT: Chunker for License Scanner

sub chunker {
    my $line = shift;
    return () if !$line;

    my @extracted = extract_multiple(
        $line,
        [
            \&extract_bracketed, sub { extract_delimited( $_[0], q{'"} ) },
            qr/\s*=\s*/,         qr/\s+/,
        ]
    );
    @extracted = grep { !/^\s+$/ } @extracted;
    $extracted[0] = uc( $extracted[0] );           # Normalize the first element

    Lic::Scanner::Chunker::hasher( \@extracted );
    return @extracted;
}

sub hasher {
    my $array = shift;

    my $len =  @{$array};
    my $i = $len-1;
    while ( --$i >= 1 ) {
        if ( $array->[$i] eq "=" ) {
            splice @{$array}, $i - 1, 3,
              [ uc($array->[ $i - 1 ]), $array->[ $i + 1 ] ];
              --$i;
              #say "$i:( $array->[ $i ][0], $array->[ $i ][1])";
        }
    }
}
1;
