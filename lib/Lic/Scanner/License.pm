package Lic::Scanner::License;
use strict;
use warnings;
use 5.36.0;
use List::UtilsBy qw( extract_by );
# ABSTRACT: Flex License Manager File Scanner
use Lic::Scanner::File;
use Lic::Scanner::Chunker;

sub Scan {
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok    = 1;
    for my $line (@lines) {
        next if !$line;

        #print(STDERR "'$line'\n");
        my @elements = Lic::Scanner::Chunker::chunker($line);

        my %attrs;
        if ( ref $elements[-1] eq ref {}) {
            %attrs = %{$elements[-1]};
            pop @elements;
        }
        if ( $elements[0] eq "SERVER" ) {
            my $command = shift @elements;
            my $host    = shift @elements;
            my $hostid = shift @elements;
            unless ( $host ) {
                printf( "-e- No Host : '%s'\n", $line );
                $ok = 0;
                next;
            }
            unless ( $hostid ) {
                printf( "-e- No Hostid : '%s'\n", $line );
                $ok = 0;
                next;
            }
            my @removedElements = extract_by { uc() eq 'PRIMARY_IS_MASTER' } @elements;
            if ( scalar @removedElements > 1 ) {
                printf( "-e- Duplicate PRIMARY_IS_MASTER : '%s'\n", $line );
                $ok = 0;
                next;
            }
            my $primary_is_master =  @removedElements;
            my $port = shift @elements;
            if ( $port and $port !~ /^\d+$/ ) {
                printf( "-e- Invalid Port : '%s'\n", $line );
                $ok = 0;
                next;
            }
            if (@elements) {
                printf( "-e- Unhandled Options : '%s'\n", $line );
                $ok = 0;
                next;
            }
            foreach my $key (keys %attrs) {
                if ( uc($key) eq 'HEARTBEAT_INTERVAL' ) {
                    my $value = $attrs{$key}->[1];
                    if ( $value !~ /^\d+$/ ) {
                        printf( "-e- Invalid HEARTBEAT_INTERVAL value '%d' : '%s'\n", $value, $line );
                        $ok = 0;
                        next;
                    }
                } else {
                    print( "-e- Unhandled Option Key '$key': '$line'\n");
                    $ok = 0;
                }
            }
            $ok = $ok and 1;
        }
        elsif ( $elements[0] eq "FEATURE" ) {
            $ok = $ok and 1;
        }
        else {
            printf( "-e- Unhandled Option : '%s'\n", $line );
            $ok = 0;
        }
    }

    # Empty returns 1;
    return $ok;
}

1;
__END__
=head1 NAME Lic::Scanner::License

 - 

=head1 VERSION

This documentation refers to :: version 0.0.1

=head1 SYNOPSIS
 
    use Lic::Scanner::License;
  
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
