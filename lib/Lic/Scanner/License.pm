package Lic::Scanner::License;
use strict;
use warnings;
use 5.36.0;
# ABSTRACT: Flex License Manager File Scanner
use Lic::Scanner::File;

sub Scan { 
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok = 1;
    for my $line (@lines) {
        next if ! $line;
        #print(STDERR "'$line'\n");
        if ( $line =~ m{^Server}isxm) {
            if ( $line =~ s{^(Server)\s+(\S+)\s+(\S+)\s*}{}isxm) {
                my $host  = $2;
                my $hostid = $3;

                my $primary_is_master;
                if ($line =~ s{\bprimary_is_master\b}{}isxm) {
                    $primary_is_master="primary_is_master"
                }
                
                my $heartbeat_interval ;
                my $heartbeat_interval_seconds ;
                if ($line =~ s{\bheartbeat_interval\s*=\s*(\d+)\s*}{}isxm) {
                    $heartbeat_interval_seconds = 0 + $1;
                    $heartbeat_interval="HEARTBEAT_INTERVAL";
                }
                my $port = "";
                if ($line =~ s{\b(\d+)\s*}{}isxm) {
                    $port = 0 + $1;
                }
                if ($line !~ m{^\s*$}) {
                    $ok = 0;
                    next
                }
                
                $ok = $ok and 1;
                my $str = "SERVER $host $hostid";
                $str .= " $port" if $port;
                $str .= " $primary_is_master" if $primary_is_master;
                $str .= " $heartbeat_interval=$heartbeat_interval_seconds" if $heartbeat_interval;
                printf("-i- %s\n", $str);
            } else {
                printf ("-e- Server not enough arguments : '%s'\n", $line);
                $ok = 0;
            }
        } else {
            printf ("-e- Unhandled Option : '%s'\n", $line);
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
