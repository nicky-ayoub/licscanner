package Lic::Scanner::Options;
use strict;
use warnings;
use 5.36.0;
# ABSTRACT: Flex License Manager Options
use Lic::Scanner::File;

# Feature pattern:
#   feature:keyword=value
# or alternate quoted syntax if a feature contains a colon.
#   "feature keyword=value"
# This is really strict on spacing. No spaces around the colon or equal is permitted.
# We could loosen this up to match more patterns but this matches the spec in the docs:
# https://docs.revenera.com/fnp/2024r2/LicAdmin_Guide/Content/helplibrary/Options_File_Syntax.htm#fla_options_999688564_1055263
my $featurepat =
    qr{
       (?:
            (?: (?<feature>[a-zA-Z0-9]+) )
                |
            (?: (?<feature>[a-zA-Z0-9]+) : (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+))  
                | 
            (?: " (?<feature>[a-zA-Z0-9:]+)  \s+ (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+) ")
       )
    }sxm
;
my $entitlementpat =
    qr{
       (?:
            (?: (?<feature>[a-zA-Z0-9]+) )
                |
            (?: (?<feature>[a-zA-Z0-9]+) : (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+))  
       )
    }sxm
;


sub Scan {
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok = 1;
    for my $line (@lines) {
        next if ! $line;
        if ( $line =~ /^(AUTOMATIC_REREAD)\s+(on|off )\s*$/isxm) {
            my ($key, $val) = (uc($1), uc($2));
            printf("%s %s\n", $key, $val);
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)(ACTIVATION_LOWWATER)\s+ $entitlementpat \s+ (?<count>\d+)\s*$/sxm) {
            if (defined $+{keyword} ) {
                my ($key, $entitlement, $fid, $fidid, $count) = (uc($1), $+{feature},$+{keyword}, $+{value}, 0+ $+{count});     
                printf("%s %s:%s=%s %d\n", $key,  $entitlement, $fid, $fidid, $count);
            }else {
                 my ($key, $entitlement, $count) = (uc($1),$+{feature}, $+{count});    
                printf("%s %s %d\n", $key, $entitlement, $count); 
            }
            $ok = $ok and 1;

        } elsif ( $line =~ /^(?i)(ACTIVATION_EXPIRY_DAYS)\s+ $entitlementpat \s+ (?<days>\d+)\s*$/sxm) {   
            if (defined $+{keyword} ) {
                my ($key, $entitlement, $fid, $fidid, $days) = (uc($1), $+{feature},$+{keyword}, $+{value}, 0+ $+{days});     
                printf("%s %s:%s=%s %d\n", $key,  $entitlement, $fid, $fidid, $days);
            }else {
                 my ($key, $entitlement, $days) = (uc($1),$+{feature}, $+{days});    
                printf("%s %s %d\n", $key, $entitlement, $days); 
            }
        }  elsif ( $line =~ /^(?i)(BORROW_LOWWATER|MAX_BORROW_HOURS|MAX_OVERDRAFT)\s+  $featurepat \s+ (?<count>\d+)\s*$/sxm) {  
            if (defined $+{keyword} ) {
                my ($key, $feature, $keyword, $value, $count) = (uc($1), $+{feature},$+{keyword}, $+{value}, 0+ $+{count});     
                printf("%s %s:%s=%s %d\n", $key,  $feature, $keyword, $value, $count);
            }else {
                 my ($key, $feature, $count) = (uc($1),$+{feature}, $+{count});    
                printf("%s %s %d\n", $key, $feature, $count); 
            }
        } elsif ( $line =~ /^(?i)(DAEMON_SELECT_TIMEOUT)\s+ (\d+)\s*$/sxm) {   
            my ($key, $seconds) = (uc($1),0+$2);    
            printf("%s %d\n", $key, $seconds); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)(DEBUGLOG)\s+ (\+)? (\S+)/sxm) { 
            my $orig = $line;
            $line =~ s/^(?i)(DEBUGLOG)\s+ (\+)? (\S+)//sxm;
            my $key="DEBUGLOG";
            my $plus = $2; 
            my $path = $3;
            my $OBF_ADDMARK;
            if ($line =~ s/\s*(?i)(OBF_ADDMARK)\s*//sxm) {
                $OBF_ADDMARK="OBF_ADDMARK"
            }
            my $AUTO_ROLLOVER ;
            my $AUTO_ROLLOVER_SIZE ;
            if ($line =~ s/(?i)\s*(AUTO_ROLLOVER)\s+(\d+)\s*//sxm) {
                $AUTO_ROLLOVER_SIZE = 0 + $2;
                $AUTO_ROLLOVER="AUTO_ROLLOVER";
            }
            my $str ="";
            $line =~ s/\s//g;
            if ($line) {
                $ok = 0;
                #printf (STDERR "Remainder : '%s'\n", $orig);
            } else {
                my $str = sprintf ("%s %s", $key, $path);
                $str .= " OBF_ADDMARK" if $OBF_ADDMARK;
                $str .= " AUTO_ROLLOVER $AUTO_ROLLOVER_SIZE" if  $AUTO_ROLLOVER;
                $str .= " # with append..." if defined $plus;
                printf("%s\n", $str);
                $ok = $ok and 1;
            }
         } elsif ( $line =~ /^(?i)((?:IN|EX)CLUDE(?:_BORROW)?)\s+ $featurepat \s+ (?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm) {
            if (defined $+{keyword} ) {
                my ($key, $feature, $keyward, $value, $type, $name) = (uc($1), $+{feature},$+{keyword}, $+{value}, $+{type}, $+{name} );     
                printf("%s %s:%s=%s %s %s\n", $key,  $feature, $keyward, $value, $type, $name);
            }else {
                 my ($key, $feature, $type, $name) = (uc($1),$+{feature}, $+{type}, $+{name});    
                printf("%s %s %s %s\n", $key, $feature, $type, $name); 
            }
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)((?:IN|EX)CLUDE_ENTITLEMENT)\s+ (?<entid>\S+) \s+ (?<type>USER|HOST|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm) {
            my ($key, $entid, $type, $name) = (uc($1),$+{entid}, $+{type}, $+{name});    
            printf("%s %s %s %s\n", $key, $entid, $type, $name); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)((?:IN|EX)CLUDEALL)\s+(?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm) {
            my ($key, $type, $name) = (uc($1), $+{type}, $+{name});    
            printf("%s %s %s\n", $key, $type, $name); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)((?:IN|EX)CLUDEALL_ENTITLEMENT)\s+(?<type>USER|HOST|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm) {
            my ($key, $type, $name) = (uc($1), $+{type}, $+{name});    
            printf("%s %s %s\n", $key, $type, $name); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)(FQDN_MATCHING) \s+ (?<term>EXACT|LENIENT) \s* $/sxm) {
            my ($key, $term) = (uc($1), $+{term});    
            printf("%s %s\n", $key, $term); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(?i)((?:HOST_)?GROUP) \s+ (?<grname>\S+) \s+ (?<members>\S.*) /sxm) {
            my ($key, $grname, $members) = (uc($1), $+{grname}, $+{members}); 
            my @members = split ' ' , $members;

            printf("%s %s %s\n", $key, $grname, join(", ", @members)); 
            $ok = $ok and 1;
        } elsif ( $line =~ /^(GROUPCASEINSENSITIVE)\s+(on|off )\s*$/isxm) {
            my ($key, $val) = (uc($1), uc($2));
            printf("%s %s\n", $key, $val);
            $ok = $ok and 1;        
        }  elsif ( $line =~ /^(?i)(LINGER|TIMEOUT)\s+  ($featurepat \s+)? (?<seconds>\d+)\s*$/sxm) {  
            if (defined $+{keyword} ) {
                my ($key, $feature, $keyword, $value, $seconds) = (uc($1), $+{feature},$+{keyword}, $+{value}, 0+ $+{seconds});     
                printf("%s %s:%s=%s %d\n", $key,  $feature, $keyword, $value, $seconds);
            }else {
                 if (defined $+{feature} ) {
                    my ($key, $feature, $seconds) = (uc($1),$+{feature}, $+{seconds});    
                    printf("%s %s %d\n", $key, $feature, $seconds); 
                 } else{ 
                    my ($key, $seconds) = (uc($1), $+{seconds});    
                    printf("%s %d\n", $key, $seconds);   
                 }

            }
         } elsif ( $line =~ /^(?i)(MAX|RESERVE)\s+ (?<num_lic>\d+) \s+  $featurepat \s+ (?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm) {
            if (defined $+{keyword} ) {
                my ($key, $num_lic, $feature, $keyward, $value, $type, $name) = (uc($1),  0 + $+{num_lic},  $+{feature},$+{keyword}, $+{value}, $+{type}, $+{name} );     
                printf("%s %d %s:%s=%s %s %s\n", $key,  $num_lic, $feature, $keyward, $value, $type, $name);
            }else {
                 my ($key, $num_lic, $feature, $type, $name) = (uc($1),  0 + $+{num_lic}, $+{feature}, $+{type}, $+{name});    
                printf("%s %d %s %s %s\n", $key, $num_lic, $feature, $type, $name); 
            }
         } elsif ( $line =~ /^(?i)(MAX_CONNECTIONS|TIMEOUTALL) \s+ (\d+) \s*$/sxm) {
             my ($key, $num_conn) = (uc($1),  0 + $2);  
            printf("%s %d\n", $key, $num_conn); 
        } elsif ( $line =~ /^(NOLOG)\s+(IN | OUT | DENIED | QUEUED | UNSUPPORTED | UPGRADE | DEQUEUED )\s*$/isxm) {
            my ($key, $val) = (uc($1), uc($2));
            printf("%s %s\n", $key, $val);
            $ok = $ok and 1;      
        } elsif ( $line =~ /^(REPORTLOG)\s+/isxm) {
            my $key = uc($1);
            $line =~ s{^(REPORTLOG)\s+}{}isxm;

            my $found = ($line =~ s{\s*(HIDE_USER)\s*$}{}isxm); # pull from the end of line
            my $hide = $found ? "HIDE_USER" : "";
            #say "2 <$hide> '$line'";

            $found = ($line =~ s{^([+])\s*}{}); # pull from the beginning of line
            my $plus = $found ? "+" : "";
            #say "3 [$plus] '$line'";

            my $file = $line ;# the file is all that's left
         
            printf("%s [%s] '%s' <%s>\n", $key, $plus, $file, $hide );
            if ($file) {
                $ok = $ok and 1; # if we have a file, all is good
            } else {
                $ok=0 # no file found
            }  
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