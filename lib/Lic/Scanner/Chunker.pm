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

    my @extracted = extract_multiple( $line,
        [ \&extract_bracketed, \&extract_quotelike, qr/\s*=\s*/, qr/\s+/, ] );
    @extracted = grep { !/^\s+$/ } @extracted;
    $extracted[0] = uc( $extracted[0] );           # Normalize the first element
    my %attrs = Lic::Scanner::Chunker::hasher(\@extracted);
    push @extracted, \%attrs if %attrs;
    say Data::Dumper::Dumper( \@extracted );
    say "_" x 80;
    return @extracted;
}

sub hasher {
    my $array = shift;
    my %attrs;
    my @found;
    for my $i ( 0 .. $#{$array} ) {
       if ($array->[$i] eq "=") {
           if (! defined $attrs{$array->[$i-1]} ) {
               $attrs{$array->[$i-1]} = [ $i-1,$array->[$i+1] ];
               push @found, $i;
           } else {
                say "Error: Duplicate Key: $array->[$i-1]";
           }
       }
    }
    foreach my $i (reverse @found) {
        splice @$array, $i-1, 3;
    }
    return %attrs;
}
1;
