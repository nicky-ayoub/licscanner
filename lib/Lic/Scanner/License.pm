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

        my @elements = Lic::Scanner::Chunker::chunker($line);

        # map function to elements[0]. If it exists call it with line and elements
        my $fname = "_" . lc($elements[0]);
        no strict qw/refs/; 
        if ( ! defined( &{$fname} ) ) {
            printf( "-e- Unhandled Command %s : '%s'\n", $elements[0], $line );
            $ok = 0;
            next;
        }
        $ok = $ok && &{$fname}( $line, \@elements );
        use strict qw/refs/;
    }

    # Empty returns 1;
    return $ok;
}

sub _server {
    my $line     = shift;
    my $elements = shift;

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
    my $port;
    if ( ref $elements->[0] ne ref [] ) {
        $port = shift @$elements;
    }
    if ( $port and $port !~ /^\d+$/ ) {
        printf( "-e- Invalid Port : '%s'\n", $line );
        return 0;
    }
    my $heartbeat_interval;
    if ( ref $elements->[0] eq ref [] ) {
        my $kv = shift @$elements;
        if ( $kv->[0] eq 'HEARTBEAT_INTERVAL' ) {
            $heartbeat_interval = $kv->[1];
            if ( $heartbeat_interval !~ /^\d+$/ ) {
                printf( "-e- Invalid HEARTBEAT_INTERVAL value '%d' : '%s'\n",
                    $heartbeat_interval, $line );
                return 0;
            }
        }
        else {
            printf( "-e- Unhandled Option %s : '%s'\n", $kv->[0], $line );
            return 0;
        }
    }
    if (@$elements) {
        printf( "-e- Too many parameters or invalid option: %s\n", $line );
        return 0;
    }
    $port               ||= "";
    $heartbeat_interval ||= "";
    $primary_is_master  ||= "";
    if ($heartbeat_interval) {
        $heartbeat_interval = "HEARTBEAT_INTERVAL='$heartbeat_interval'";
    }
    if ($primary_is_master) {
        $primary_is_master = "PRIMARY_IS_MASTER";
    }
    printf( "$command %s %s %s %s %s\n",
        $host, $hostid, $port, $primary_is_master, $heartbeat_interval );

    return 1;
}

sub _vendor {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $vendor  = shift @$elements;
    my $port;
    my $options;
    my $daemonpath;

    unless ($vendor) {
        printf( "-e- No Host : '%s'\n", $line );
        return 0;
    }
    if ( ref $elements->[0] ne ref [] ) {
        $daemonpath = shift @$elements;
        if ( ref $elements->[0] ne ref [] ) {
            $options = shift @$elements;
            if ( ref $elements->[0] ne ref [] ) {
                $port = shift @$elements;
            }
        }
    }
    for my $kv (@$elements) {
        if ( ref $kv ne ref [] ) {
            printf( "-e- Only Options should remain : '%s'\n", $line );
            return 0;
        }
        elsif ( $kv->[0] eq 'OPTIONS' ) {
            if ($options) {
                printf( "-e- Duplicate OPTIONS : '%s'\n", $line );
                return 0;
            }
            $options = $kv->[1];
        }
        elsif ( $kv->[0] eq 'PORT' ) {
            if ($port) {
                printf( "-e- Duplicate PORT : '%s'\n", $line );
                return 0;
            }
            $port = $kv->[1];
        }
        else {
            printf( "-e- Unhandled Option %s : '%s'\n", $kv->[0], $line );
            return 0;
        }
    }

    if ( $port && $port !~ /^\d+$/ ) {
        printf( "-e- Invalid Port  $port: '%s'\n", $line );
        return 0;
    }
    $port       //= "";
    $options    //= "";
    $daemonpath //= "";
    if ($port) {
        $port = "PORT='$port'";
    }
    if ($options) {
        $options = "OPTIONS='$options'";
    }
    printf( "$command %s %s %s %s\n", $vendor, $daemonpath, $options, $port );

    return 1;
}

sub _use_server {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;

    if (@$elements) {
        printf( "-e- USE_SERVER to many parameters : '%s'\n", $line );
        return 0;
    }
    printf("$command\n");
    return 1;
}

sub _increment {
    goto &_feature;
}

sub _feature {
    my $line     = shift;
    my $elements = shift;

    my $command      = shift @$elements;
    my $feature      = shift @$elements;
    my $vendor       = shift @$elements;
    my $feat_version = shift @$elements;
    my $exp_date     = shift @$elements;
    my $num_lic      = shift @$elements;

    unless ($feature) {
        printf( "-e- No Feature : '%s'\n", $line );
        return 0;
    }
    unless ($vendor) {
        printf( "-e- No Vendor : '%s'\n", $line );
        return 0;
    }

    unless ($feat_version) {
        printf( "-e- No Feature Version : '%s'\n", $line );
        return 0;
    }
    unless ($exp_date) {
        printf( "-e- No Expiration Date : '%s'\n", $line );
        return 0;
    }
    if (    $exp_date !~ /^0{1,4}$/
        and lc($exp_date) ne 'permanent'
        and $exp_date !~ /^\d{1,2}-[a-z]{3}-\d{4}$/ )
    {
        printf( "-e- Invalid Expiration Date $exp_date : '%s'\n", $line );
        return 0;
    }
    unless ($num_lic) {
        printf( "-e- No Number of Licenses : '%s'\n", $line );
        return 0;
    }
    if ( $num_lic !~ /^\d+$/ and lc($num_lic) ne 'uncounted' ) {
        printf( "-e- Invalid Number of Licenses $num_lic : '%s'\n", $line );
        return 0;
    }

    my @kvs = extract_by { ref $_ eq ref [] } @$elements;
    if (@$elements) {
        printf( "-e- Unhandled Options : '%s'\n", $line );
        return 0;
    }
    printf( "$command %s %s %s %s %s ",
        $feature, $vendor, $feat_version, $exp_date, $num_lic );
    foreach my $kv (@kvs) {
        printf( "%s=%s ", $kv->[0], $kv->[1] );
    }
    say "";

    return 1;

}

sub _package {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $package = shift @$elements;
    my $vendor  = shift @$elements;
    my $package_version;

    if ( ref $elements->[0] ne ref [] ) {
        $package_version = shift @$elements;
    }

    my @kvs =
      extract_by { ref $_ eq ref [] } @$elements;    # extract key value pairs

    if (@$elements) {
        printf( "-e- PACKAGE extra parameters : %s\n'%s'\n",
            "@$elements", $line );
        return 0;
    }
    printf( "$command %s %s %s ", $package, $vendor, $package_version );
    foreach my $kv (@kvs) {
        printf( "%s='%s' ", $kv->[0], $kv->[1] );
    }
    say "";

    return 1;
}

sub _upgrade {
    my $line     = shift;
    my $elements = shift;

    my $command  = shift @$elements;
    my $feature  = shift @$elements;
    my $vendor   = shift @$elements;
    my $from     = shift @$elements;
    my $to       = shift @$elements;
    my $exp_date = shift @$elements;
    my $num_lic  = shift @$elements;

    unless ($feature) {
        printf( "-e- No Feature : '%s'\n", $line );
        return 0;
    }
    unless ($vendor) {
        printf( "-e- No Vendor : '%s'\n", $line );
        return 0;
    }
    unless ($from) {
        printf( "-e- No From Feature Version : '%s'\n", $line );
        return 0;
    }
    unless ($to) {
        printf( "-e- No To Feature Version : '%s'\n", $line );
        return 0;
    }
    unless ($exp_date) {
        printf( "-e- No Expiration Date : '%s'\n", $line );
        return 0;
    }
    if (    $exp_date !~ /^0{1,4}$/
        and lc($exp_date) ne 'permanent'
        and $exp_date !~ /^\d{1,2}-[a-z]{3}-\d{4}$/ )
    {
        printf( "-e- Invalid Expiration Date $exp_date : '%s'\n", $line );
        return 0;
    }
    unless ($num_lic) {
        printf( "-e- No Number of Licenses : '%s'\n", $line );
        return 0;
    }
    if ( $num_lic !~ /^\d+$/ and lc($num_lic) ne 'uncounted' ) {
        printf( "-e- Invalid Number of Licenses $num_lic : '%s'\n", $line );
        return 0;
    }

    my @kvs = extract_by { ref $_ eq ref [] } @$elements;

    if (@$elements) {
        printf( "-e- Unhandled Options : '%s'\n", $line );
        return 0;
    }
    printf( "$command: %s %s %s %s %s %s ",
        $feature, $vendor, $from, $to, $exp_date, $num_lic );
    foreach my $kv (@kvs) {
        printf( "%s='%s' ", $kv->[0], $kv->[1] );
    }
    say "";

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
