package Lic::Scanner::Options;
use strict;
use warnings;
# ABSTRACT: Flex License Manager Options


sub Scan {
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok = 1;
    for my $line (@lines) {
        next if ! $line;
        if ( $line =~ /^(?i)(AUTOMATIC_REREAD)\s+((?i) ON |OFF )\s*$/sxm) {
            my ($key, $val) = ($1, $2);
            $ok = $ok and 1;
        } else {
            printf ("Unhandled Option : '%s'\n", $line);
            $ok = 0;
        }
    }
    # Empty returns 1;
    return $ok;
}

1;
__DATA__
AUTOMATIC_REREAD OFF|ON
ACTIVATION_LOWWATER entitlementID count
ACTIVATION_LOWWATER entitlementID:FID=fulfillmentID count
ACTIVATION_EXPIRY_DAYS entitlementID days
ACTIVATION_EXPIRY_DAYS entitlementID:FID=fulfillmentID days
BORROW_LOWWATER feature[:keyword=value] n
DAEMON_SELECT_TIMEOUT value_in_seconds
DEBUGLOG [+]debug_log_path [OBF_ADDMARK] [AUTO_ROLLOVER size]
EXCLUDE feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
EXCLUDE_BORROW feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
EXCLUDE_ENTITLEMENT entitlementId type {name | group_name}
    type One of USER, HOST, GROUP, or HOST_GROUP.
EXCLUDEALL type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
EXCLUDEALL_ENTITLEMENT type {name | group_name}
    type One of USER, HOST, GROUP, or HOST_GROUP
FQDN_MATCHING exact | lenient
GROUP group_name user_list
GROUPCASEINSENSITIVE OFF|ON
HOST_GROUP group_name host_list
INCLUDE feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
INCLUDE_BORROW feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
INCLUDE_ENTITLEMENT entitlementId type {name | group_name}
    type One of USER, HOST, GROUP, or HOST_GROUP
INCLUDEALL type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
INCLUDEALL_ENTITLEMENT type {name | group_name}
    type One of USER, HOST, GROUP, or HOST_GROUP
LINGER feature[:keyword=value] seconds
MAX num_lic feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
MAX_BORROW_HOURS feature[:keyword=value] num_hours
MAX_CONNECTIONS num_con
MAX_OVERDRAFT feature[:keyword=value] num_lic
NOLOG {IN | OUT | DENIED | QUEUED | UNSUPPORTED | UPGRADE | DEQUEUED}
REPORTLOG [+]report_log_path [HIDE_User]
RESERVE num_lic feature[:keyword=value] type {name | group_name}
    type One of USER, HOST, DISPLAY, INTERNET, PROJECT, GROUP, or HOST_GROUP
TIMEOUT feature[:keyword=value] seconds
TIMEOUTALL seconds


__END__
=head1 NAME Lic::Scanner::Options

 - 

=head1 VERSION

This documentation refers to :: version 0.0.1

=head1 SYNOPSIS
 
    use Lic::Scanner::Options;
  
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