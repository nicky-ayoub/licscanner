package Lic::Scanner::File;
use strict;
use warnings;

use Path::Tiny;

# ABSTRACT: File reader that supports backslash line continuations

sub slurp {
    my $filename = shift;

    my $guts = path($filename)->slurp_utf8;

    if ( wantarray ) {  
        my @data =  processBackSlash($guts);
        return @data;
    } else {
        my $data =  processBackSlash($guts);
        return $data;
    }
}

sub processBackSlash {
    my $string = shift;
    $string =~ s/\\\s*\n//smxg; # remove line continuations
    $string =~ s/^(?:\s*\#.*)$//mxg; # Remove Comments.
    $string =~ s/(\n\s*)+/\n/smxg; # Remove lines.
    if ( wantarray ) {  
        return  split /\n/x, $string
    } else {
        return $string;
    }
}

1;
__END__
=head1 NAME Lic::Scanner::File

 - 

=head1 VERSION

This documentation refers to :: version 0.0.1

=head1 SYNOPSIS
 
    use Lic::Scanner::File;
  
=head1 DESCRIPTION



=head1 DIAGNOSTICS



=head1 CONFIGURATION AND ENVIRONMENT



=head1 DEPENDENCIES



=head1 INCOMPATIBILITIES



=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to Quinn Weaver <quinn@fairpath.com>
Patches are welcome.
 
=head1 AUTHOR

Quinn Weaver <quinn@fairpath.com>

=head1 LICENSE AND COPYRIGHT
 
Copyright (c) 2025 Nicky Ayoub (<nicky.ayoub@gmail.com>). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 