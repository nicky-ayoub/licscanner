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
        if ( ref $elements[-1] eq ref {} ) {
            %attrs = %{ $elements[-1] };
            pop @elements;
        }
        if ( $elements[0] eq "SERVER" ) {
            $ok = $ok && _server( $line, \@elements, \%attrs );
        }
        elsif ( $elements[0] eq "VENDOR" ) {
            $ok = $ok && _vendor( $line, \@elements, \%attrs );
        }
        elsif ( $elements[0] eq "USE_SERVER" ) {
            $ok = $ok && _useserver( $line, \@elements, \%attrs );
        }
        elsif ( $elements[0] eq "FEATURE" ) {
            $ok = $ok && 1;
        }
        else {
            printf( "-e- Unhandled Option : '%s'\n", $line );
            $ok = 0;
        }
    }

    # Empty returns 1;
    return $ok;
}

sub _server {
    my $line     = shift;
    my $elements = shift;
    my $attrs    = shift;

    my $command = shift @$elements;
    my $host    = shift @$elements;
    my $hostid  = shift @$elements;

    unless ($host) {
        printf( "-e- No Host : '%s'\n", $line );
        return 0;
    }
    unless ($hostid) {
        printf( "-e- No Hostid : '%s'\n", $line );
        return 0;
    }
    my @removedElements = extract_by { uc() eq 'PRIMARY_IS_MASTER' } @$elements;
    if ( scalar @removedElements > 1 ) {
        printf( "-e- Duplicate PRIMARY_IS_MASTER : '%s'\n", $line );
        return 0;
    }
    my $primary_is_master = @removedElements;
    my $port              = shift @$elements;
    if ( $port and $port !~ /^\d+$/ ) {
        printf( "-e- Invalid Port : '%s'\n", $line );
        return 0;
    }
    if (@$elements) {
        printf( "-e- Unhandled Options : '%s'\n", $line );
        return 0;
    }
    foreach my $key ( keys %$attrs ) {
        if ( uc($key) eq 'HEARTBEAT_INTERVAL' ) {
            my $value = $attrs->{$key}->[1];
            if ( $value !~ /^\d+$/ ) {
                printf( "-e- Invalid HEARTBEAT_INTERVAL value '%d' : '%s'\n",
                    $value, $line );
                return 0;
            }
        }
        else {
            print("-e- Unhandled Option Key '$key': '$line'\n");
            return 0;
        }
    }
    return 1;
}

sub _vendor {
    my $line     = shift;
    my $elements = shift;
    my $attrs    = shift;

    my $command = shift @$elements;
    my $vendor  = shift @$elements;
    my $port;
    my $options;
    my $daemonpath;

    unless ($vendor) {
        printf( "-e- No Host : '%s'\n", $line );
        return 0;
    }
    $port    = $attrs->{PORT}->[1]    if defined $attrs->{PORT};
    $options = $attrs->{OPTIONS}->[1] if defined $attrs->{OPTIONS};
    delete $attrs->{PORT}    if defined $attrs->{PORT};
    delete $attrs->{OPTIONS} if defined $attrs->{OPTIONS};
    if ( keys %$attrs ) {
        printf( "-e- Unhandled keys : '%s'\n", join ', ', keys %$attrs );
        return 0;
    }

    if ( $port and $options ) {

        if (@$elements) {    # Must be a path
            $daemonpath = shift @$elements;
            if (@$elements) {
                printf( "-e- Too many params : '%s'\n", $line );
                return 0;
            }
        }
    }
    else {
        $daemonpath = shift @$elements;
        if (!$options) {
            $options = shift @$elements;
        }        
        if (!$port) {
            $port = shift @$elements;
        }
    }
    if ( $port && $port !~ /^\d+$/ ) {
        printf( "-e- Invalid Port  $port: '%s'\n", $line );
        return 0;
    }
    $port       //= "''";
    $options    //= "''";
    $daemonpath //= "''";
    printf( ">>> $command: %s, Daemonpath: %s, Options: %s, Port: %s\n",
        $vendor, $daemonpath, $options, $port );

    return 1;
}

sub _useserver {
    my $line     = shift;
    my $elements = shift;
    my $attrs    = shift;

    my $command = shift @$elements;

    if (@$elements) {
        printf( "-e- USE_SERVER to many parameters : '%s'\n", $line );
        return 0;
    }
    if (keys %$attrs) {
        printf( "-e- USE_SERVER to many options : '%s'\n", $line );
        return 0;
    }
    return 1;
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
