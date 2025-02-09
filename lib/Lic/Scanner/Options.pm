package Lic::Scanner::Options;
use strict;
use warnings;
use 5.36.0;

# ABSTRACT: Flex License Manager Options
use Lic::Scanner::File;
use Lic::Scanner::Chunker;

# Feature pattern:
#   feature:keyword=value
# or alternate quoted syntax if a feature contains a colon.
#   "feature keyword=value"
# This is really strict on spacing. No spaces around the colon or equal is permitted.
# We could loosen this up to match more patterns but this matches the spec in the docs:
# https://docs.revenera.com/fnp/2024r2/LicAdmin_Guide/Content/helplibrary/Options_File_Syntax.htm#fla_options_999688564_1055263
my $featurepat = qr{
        (?: 
            (?: ["]? (?<feature>[a-zA-Z0-9]+) : (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+) ["]?)  
                |
            (?: " (?<feature>[a-zA-Z0-9:]+)  \s+ (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+) ")
                |
            (?: (?<feature>[a-zA-Z0-9]+) )   
       )
    }sxm
  ;
my $entitlementpat = qr{
       (?:
            (?: ["]? (?<feature>[a-zA-Z0-9]+) : (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+) ["]?)  
                |
            (?: " (?<feature>[a-zA-Z0-9:]+)  \s+ (?<keyword>[a-zA-Z0-9]+) = (?<value>[a-zA-Z0-9]+) ")
                |   
            (?: (?<feature>[a-zA-Z0-9]+) )
       )
    }sxm
  ;

sub Scan2 {
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok    = 1;
    for my $line (@lines) {
        next if !$line;

        my @elements = Lic::Scanner::Chunker::chunker($line);

        # say Data::Dumper::Dumper(\@elements);

       # map function to elements[0]. If it exits call it with line and elements
        my $fname = "_" . lc( $elements[0] );

        # say $fname;
        ## no critic
        no strict qw/refs/;
        if ( !defined( &{$fname} ) ) {
            printf( "-e- Unhandled Command '%s' : '%s'\n", $fname, $line );
            $ok = 0;
            next;
        }
        $ok = $ok && &{$fname}( $line, \@elements );
        use strict qw/refs/;
        ## use critic
    }

    # Empty returns 1;
    return $ok;
}

sub Scan {
    my $input = shift;
    my @lines = Lic::Scanner::File::processBackSlash($input);
    my $ok    = 1;
    for my $line (@lines) {
        next if !$line;

        # my @elements = Lic::Scanner::Chunker::chunker($line);
        # say Data::Dumper::Dumper(\@elements);

        if ( $line =~ /^(AUTOMATIC_REREAD)\s+(on|off )\s*$/isxm ) {    ##PORTED
            my ( $key, $val ) = ( uc($1), uc($2) );
            printf( "%s %s\n", $key, $val );
            $ok = $ok and 1;
        }
        elsif ( $line =~
/^(?i)(ACTIVATION_LOWWATER)\s+ $entitlementpat \s+ (?<count>\d+)\s*$/sxm
          )
        {       
            my $com =   uc($1);                                                     ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $entitlement, $fid, $fidid, $count ) = (
                     $com, $+{feature}, $+{keyword}, $+{value},
                    0 + $+{count}
                );
                printf( "%s %s:%s=%s %d\n",
                    $key, $entitlement, $fid, $fidid, $count );
            }
            else {
                my ( $key, $entitlement, $count ) =
                  ( $com, $+{feature}, $+{count} );
                printf( "%s %s %d\n", $key, $entitlement, $count );
            }
            $ok = $ok and 1;

        }
        elsif ( $line =~
/^(?i)(ACTIVATION_EXPIRY_DAYS)\s+ $entitlementpat \s+ (?<days>\d+)\s*$/sxm
          )
        {    ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $entitlement, $fid, $fidid, $days ) = (
                    uc($1), $+{feature}, $+{keyword}, $+{value},
                    0 + $+{days}
                );
                printf( "%s %s:%s=%s %d\n",
                    $key, $entitlement, $fid, $fidid, $days );
            }
            else {
                my ( $key, $entitlement, $days ) =
                  ( uc($1), $+{feature}, $+{days} );
                printf( "%s %s %d\n", $key, $entitlement, $days );
            }
        }
        elsif ( $line =~
/^(?i)(BORROW_LOWWATER|MAX_BORROW_HOURS|MAX_OVERDRAFT)\s+  $featurepat \s+ (?<count>\d+)\s*$/sxm
          )
        {    ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $feature, $keyword, $value, $count ) = (
                    uc($1), $+{feature}, $+{keyword}, $+{value},
                    0 + $+{count}
                );
                printf( "%s %s:%s=%s %d\n",
                    $key, $feature, $keyword, $value, $count );
            }
            else {
                my ( $key, $feature, $count ) =
                  ( uc($1), $+{feature}, $+{count} );
                printf( "%s %s %d\n", $key, $feature, $count );
            }
        }
        elsif ( $line =~ /^(?i)(DAEMON_SELECT_TIMEOUT)\s+ (\d+)\s*$/sxm )
        {    ## PORTED
            my ( $key, $seconds ) = ( uc($1), 0 + $2 );
            printf( "%s %d\n", $key, $seconds );
            $ok = $ok and 1;
        }
        elsif ( $line =~ s{^(DEBUGLOG) \s+ (\+)? (\S+)}{}isxm ) {    ## PORTED
            my $key  = "DEBUGLOG";
            my $plus = $2;
            my $path = $3;

            if ($line =~ m{\bAUTO_ROLLOVER.*?\bOBF_ADDMARK\b}isxm) {
                # out of order
                $ok = 0;
                next;
            }

            my $OBF_ADDMARK;
            if ( $line =~ s{\bOBF_ADDMARK\b}{}isxm ) {
                $OBF_ADDMARK = "OBF_ADDMARK";
            }

            my $AUTO_ROLLOVER;
            my $AUTO_ROLLOVER_SIZE;
            if ( $line =~ s{\bAUTO_ROLLOVER\s+(\d+)\s*}{}isxm ) {
                $AUTO_ROLLOVER_SIZE = 0 + $1;
                $AUTO_ROLLOVER      = "AUTO_ROLLOVER";
            }

            $line =~ s{\s+}{}g;
            if ($line) {    # is there anything left?
                $ok = 0;
                next;
            }

            my $str =
              sprintf( "%s %s%s", $key, ( defined $plus ? "+" : "" ), $path );
            $str .= " OBF_ADDMARK"                       if $OBF_ADDMARK;
            $str .= " AUTO_ROLLOVER $AUTO_ROLLOVER_SIZE" if $AUTO_ROLLOVER;
            $str .= " # with append..."                  if defined $plus;
            printf( "%s\n", $str );
            $ok = $ok and 1;
        }
        elsif ( $line =~
/^(?i)((?:IN|EX)CLUDE(?:_BORROW)?)\s+ $featurepat \s+ (?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm
          )
        {    ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $feature, $keyward, $value, $type, $name ) = (
                    uc($1), $+{feature}, $+{keyword}, $+{value}, $+{type},
                    $+{name}
                );
                printf( "%s %s:%s=%s %s %s\n",
                    $key, $feature, $keyward, $value, $type, $name );
            }
            else {
                my ( $key, $feature, $type, $name ) =
                  ( uc($1), $+{feature}, $+{type}, $+{name} );
                printf( "%s %s %s %s\n", $key, $feature, $type, $name );
            }
            $ok = $ok and 1;
        }
        elsif ( $line =~
/^(?i)((?:IN|EX)CLUDE_ENTITLEMENT)\s+ (?<entid>\S+) \s+ (?<type>USER|HOST|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm
          )
        {    ## PORTED
            my ( $key, $entid, $type, $name ) =
              ( uc($1), $+{entid}, $+{type}, $+{name} );
            printf( "%s %s %s %s\n", $key, $entid, $type, $name );
            $ok = $ok and 1;
        }
        elsif ( $line =~
/^(?i)((?:IN|EX)CLUDEALL)\s+(?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm
          )
        {    ## PORTED
            my ( $key, $type, $name ) = ( uc($1), $+{type}, $+{name} );
            printf( "%s %s %s\n", $key, $type, $name );
            $ok = $ok and 1;
        }
        elsif ( $line =~
/^(?i)((?:IN|EX)CLUDEALL_ENTITLEMENT)\s+(?<type>USER|HOST|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm
          )
        {    ## PORTED
            my ( $key, $type, $name ) = ( uc($1), $+{type}, $+{name} );
            printf( "%s %s %s\n", $key, $type, $name );
            $ok = $ok and 1;
        }
        elsif ( $line =~
            /^(?i)(FQDN_MATCHING) \s+ (?<term>EXACT|LENIENT) \s* $/sxm )
        {    ## PORTED
            my ( $key, $term ) = ( uc($1), $+{term} );
            printf( "%s %s\n", $key, $term );
            $ok = $ok and 1;
        }
        elsif ( $line =~
            /^(?i)((?:HOST_)?GROUP) \s+ (?<grname>\S+) \s+ (?<members>\S.*) /sxm
          )
        {    ## PORTED
            my ( $key, $grname, $members ) =
              ( uc($1), $+{grname}, $+{members} );
            my @members = split ' ', $members;

            printf( "%s %s %s\n", $key, $grname, join( ", ", @members ) );
            $ok = $ok and 1;
        }
        elsif ( $line =~ /^(GROUPCASEINSENSITIVE)\s+(on|off )\s*$/isxm )
        {    ## PORTED
            my ( $key, $val ) = ( uc($1), uc($2) );
            printf( "%s %s\n", $key, $val );
            $ok = $ok and 1;
        }
        elsif ( $line =~
            /^(?i)(LINGER|TIMEOUT)\s+ ($featurepat \s+)? (?<seconds>\d+)\s*$/sxm
          )
        {    ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $feature, $keyword, $value, $seconds ) = (
                    uc($1), $+{feature}, $+{keyword}, $+{value}, 0 + $+{seconds}
                );
                printf( "%s %s:%s=%s %d\n",
                    $key, $feature, $keyword, $value, $seconds );
            }
            else {
                if ( defined $+{feature} ) {
                    my ( $key, $feature, $seconds ) =
                      ( uc($1), $+{feature}, $+{seconds} );
                    printf( "%s %s %d\n", $key, $feature, $seconds );
                }
                else {
                    my ( $key, $seconds ) = ( uc($1), $+{seconds} );
                    printf( "%s %d\n", $key, $seconds );
                }

            }
        }
        elsif ( $line =~
/^(?i)(MAX|RESERVE)\s+ (?<num_lic>\d+) \s+  $featurepat \s+ (?<type>USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)\s+(?<name>\S+)\s*$/sxm
          )
        { ## PORTED
            if ( defined $+{keyword} ) {
                my ( $key, $num_lic, $feature, $keyward, $value, $type, $name )
                  = (
                    uc($1), 0 + $+{num_lic},
                    $+{feature}, $+{keyword}, $+{value}, $+{type}, $+{name}
                  );
                printf( "%s %d %s:%s=%s %s %s\n",
                    $key, $num_lic, $feature, $keyward, $value, $type, $name );
            }
            else {
                my ( $key, $num_lic, $feature, $type, $name ) =
                  ( uc($1), 0 + $+{num_lic}, $+{feature}, $+{type}, $+{name} );
                printf( "%s %d %s %s %s\n",
                    $key, $num_lic, $feature, $type, $name );
            }
        }
        elsif ( $line =~ /^(?i)(MAX_CONNECTIONS|TIMEOUTALL) \s+ (\d+) \s*$/sxm )
        {    ## PORTED
            my ( $key, $num_conn ) = ( uc($1), 0 + $2 );
            printf( "%s %d\n", $key, $num_conn );
        }
        elsif ( $line =~
/^(NOLOG)\s+(IN|OUT|DENIED|QUEUED|UNSUPPORTED|UPGRADE|DEQUEUED )\s*$/isxm
          )
        {    ## PORTED
            my ( $key, $val ) = ( uc($1), uc($2) );
            printf( "%s %s\n", $key, $val );
            $ok = $ok and 1;
        }
        elsif ( $line =~ /^(REPORTLOG)\s+/isxm ) {    ## PORTED
            my $key = uc($1);
            $line =~ s{^(REPORTLOG)\s+}{}isxm;

            my $found = ( $line =~ s{\s*(HIDE_USER)\s*$}{}isxm )
              ;    # pull from the end of line
            my $hide = $found ? "HIDE_USER" : "";

            #say "2 <$hide> '$line'";

            $found =
              ( $line =~ s{^([+])\s*}{} );    # pull from the beginning of line
            my $plus = $found ? "+" : "";

            #say "3 [$plus] '$line'";

            my $file = $line;                 # the file is all that's left

            printf( "%s [%s] '%s' <%s>\n", $key, $plus, $file, $hide );
            if ($file) {
                $ok = $ok and 1;              # if we have a file, all is good
            }
            else {
                $ok = 0                       # no file found
            }
        }
        else {
            printf( "Unhandled Command : '%s'\n", $line );
            $ok = 0;
        }
    }

    # Empty returns 1;
    return $ok;
}

sub _automatic_reread {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $val     = shift @$elements;

    if ( $val !~ /^(on|off)$/isxm ) {
        printf( "-e- Invalid Value %s : '%s'\n", $val, $line );
        return 0;
    }
    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s\n", uc($command), uc($val) );
    return 1;
}

sub _activation_lowwater {
    my $line     = shift;
    my $elements = shift;

    if ( @$elements != 3 ) {
        printf( "-e- Parameter list should be 3: '%s'\n", $line );
        return 0;
    }

    my $command        = shift @$elements;
    my $entitlementstr = shift @$elements;
    my $count          = shift @$elements;

    if ( $count !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Days %s : '%s'\n", $count, $line );
        return 0;
    }
    $count = 0 + $count;

    if ( $entitlementstr =~ $entitlementpat ) {
        if ( defined $+{keyword} ) {
            my ( $entitlement, $fid, $fidid ) =
              ( $+{feature}, $+{keyword}, $+{value} );
            printf( "%s %s:%s=%s %d\n",
                $command, $entitlement, $fid, $fidid, $count );
        }
        else {
            my $entitlement = $+{feature};
            printf( "%s %s %d\n", $command, $entitlement, $count );
        }
    }
    else {
        printf( "-e- Invalid Entitlement %s : '%s'\n", $entitlementstr, $line );
        return 0;
    }

    return 1;
}

sub _activation_expiry_days {
    goto &_activation_lowwater;
}

sub _borrow_lowwater {
    my $line     = shift;
    my $elements = shift;

    if ( @$elements != 3 ) {
        printf( "-e- Invalid Parameter list : '%s'\n", $line );
        return 0;
    }

    my $command    = shift @$elements;
    my $featurestr = shift @$elements;
    my $count      = shift @$elements;

    if ( $count !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Days %s : '%s'\n", $count, $line );
        return 0;
    }
    $count = 0 + $count;

    if ( $featurestr =~ $featurepat ) {
        if ( defined $+{keyword} ) {
            my ( $feature, $fid, $fidid ) =
              ( $+{feature}, $+{keyword}, $+{value} );
            printf( "%s %s:%s=%s %d\n",
                $command, $feature, $fid, $fidid, $count );
        }
        else {
            my $feature = $+{feature};
            printf( "%s %s %d\n", $command, $feature, $count );
        }
    }
    else {
        printf( "-e- Invalid feature %s : '%s'\n", $featurestr, $line );
        return 0;
    }

    return 1;
}

sub _max_borrow {
    goto &_borrow_lowwater;
}

sub _max_borrow_hours {
    goto &_borrow_lowwater;
}

sub _max_overdraft {
    goto &_borrow_lowwater;
}

sub _debuglog {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $plus;
    if ( $elements->[0] eq "+" ) {
        $plus = shift @$elements;
    }
    my $path = shift @$elements;

    my $OBF_ADDMARK;
    if ( $elements->[0] && $elements->[0] eq "OBF_ADDMARK" ) {
        $OBF_ADDMARK = shift @$elements;
    }
    my $AUTO_ROLLOVER_SIZE;
    my $AUTO_ROLLOVER;
    if ( $elements->[0] && $elements->[0] eq "AUTO_ROLLOVER" ) {
        $AUTO_ROLLOVER      = shift @$elements;
        $AUTO_ROLLOVER_SIZE = shift @$elements;
    }
    if ( $AUTO_ROLLOVER_SIZE and $AUTO_ROLLOVER_SIZE !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Size %s : '%s'\n", $AUTO_ROLLOVER_SIZE, $line );
        return 0;
    }
    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    my $str = sprintf( "%s %s", uc($command), $path );
    $str .= " OBF_ADDMARK"                       if $OBF_ADDMARK;
    $str .= " AUTO_ROLLOVER $AUTO_ROLLOVER_SIZE" if $AUTO_ROLLOVER;
    printf( "%s\n", $str );
    return 1;
}

sub _daemon_select_timeout {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $seconds = shift @$elements;

    if ( $seconds and $seconds !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Duration %s : '%s'\n", $seconds, $line );
        return 0;
    }
    elsif ( !$seconds ) {
        printf( "-e- Duration not defined : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %d\n", uc($command), $seconds );
    return 1;
}

sub _exclude {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $feature = shift @$elements;
    my $type    = shift @$elements;
    if ($type) {
        if ( $type !~
            /^(USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)$/isxm )
        {
            printf( "-e- Invalid Type %s : '%s'\n", $type, $line );
            return 0;
        }
    }
    else {
        printf( "-e- Type not defined : '%s'\n", $line );
        return 0;
    }

    my $featurestr;

    if ( $feature =~ $featurepat ) {
        if ( defined $+{keyword} ) {
            my ( $feature, $keyword, $value ) =
              ( $+{feature}, $+{keyword}, $+{value} );
            $featurestr = sprintf( "%s:%s=%s", $feature, $keyword, $value );
        }
        else {
            if ( defined $+{feature} ) {
                $featurestr = $+{feature};
            }
        }
    }
    else {
        printf( "-e- Invalid Feature %s : '%s'\n", $feature, $line );
        return 0;
    }

    my $name = shift @$elements;
    if ( !$name ) {
        printf( "-e- Invalid Missing name : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s %s\n", $command, $featurestr, $type, $name );
    return 1;
}

sub _exclude_borrow {
    goto &_exclude;
}

sub _include {
    goto &_exclude;
}

sub _include_borrow {
    goto &_exclude;
}

sub _exclude_entitlement {
    my $line     = shift;
    my $elements = shift;

    my $command     = shift @$elements;
    my $entitlement = shift @$elements;
    my $type        = shift @$elements;
    if ($type) {
        if ( $type !~ /^(USER|HOST|GROUP|HOST_GROUP)$/isxm ) {
            printf( "-e- Invalid Type %s : '%s'\n", $type, $line );
            return 0;
        }
    }
    else {
        printf( "-e- Type not defined : '%s'\n", $line );
        return 0;
    }

    my $name = shift @$elements;
    if ( !$name ) {
        printf( "-e- Invalid Missing name : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s %s\n", $command, $entitlement, $type, $name );
    return 1;
}

sub _include_entitlement {
    goto &_exclude_entitlement;
}

sub _excludeall {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $type    = shift @$elements;
    if ($type) {
        if ( $type !~
            /^(USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)$/isxm )
        {
            printf( "-e- Invalid Type %s : '%s'\n", $type, $line );
            return 0;
        }
    }
    else {
        printf( "-e- Type not defined : '%s'\n", $line );
        return 0;
    }

    my $name = shift @$elements;
    if ( !$name ) {
        printf( "-e- Invalid Missing name : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s\n", uc($command), $type, $name );
    return 1;
}

sub _includeall {
    goto &_excludeall;
}

sub _excludeall_entitlement {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $type    = shift @$elements;
    if ($type) {
        if ( $type !~ /^(USER|HOST|GROUP|HOST_GROUP)$/isxm ) {
            printf( "-e- Invalid Type %s : '%s'\n", $type, $line );
            return 0;
        }
    }
    else {
        printf( "-e- Type not defined : '%s'\n", $line );
        return 0;
    }

    my $name = shift @$elements;
    if ( !$name ) {
        printf( "-e- Invalid Missing name : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s\n", uc($command), $type, $name );
    return 1;
}

sub _includeall_entitlement {
    goto &_excludeall_entitlement;
}

sub _fqdn_matching {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $term    = shift @$elements;

    if ( $term !~ /^(exact|lenient)$/isxm ) {
        printf( "-e- Invalid Term %s : '%s'\n", $term, $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s\n", uc($command), uc($term) );
    return 1;
}

sub _host_group {
    goto &_group;
}

sub _group {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $name    = shift @$elements;

    if ( !@$elements ) {
        printf( "-e- Missing $command List : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s\n", uc($command), $name, "@$elements" );
    return 1;
}

sub _groupcaseinsensitive {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $val     = shift @$elements;

    if ( $val !~ /^(on|off)$/isxm ) {
        printf( "-e- Invalid Value %s : '%s'\n", $val, $line );
        return 0;
    }
    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s\n", uc($command), uc($val) );
    return 1;
}


sub _linger {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;

    if (@$elements == 1)   {
        # valid case for "LINGER 10" that is used but not documented
        my $seconds = shift @$elements;
        if ( $seconds !~ /^\d+$/isxm ) {
            printf( "-e- Invalid Duration %s : '%s'\n", $seconds, $line );
            return 0;
        }
        $seconds = 0 + $seconds;
        printf( "%s %d\n", $command, $seconds );
        return 1;
    }

    my $feature = shift @$elements;
    my $seconds = shift @$elements;
    if ($seconds) {
        if ( $seconds !~ /^\d+$/isxm ) {
            printf( "-e- Invalid Duration %s : '%s'\n", $seconds, $line );
            return 0;
        }
    }
    elsif ( !$seconds ) {
        printf( "-e- Duration not defined : '%s'\n", $line );
        return 0;
    }
    $seconds = 0 + $seconds;

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }
    if ( $feature =~ $featurepat ) {
        if ( defined $+{keyword} ) {
            my ( $feature, $keyword, $value ) =
              ( $+{feature}, $+{keyword}, $+{value} );
            printf( "%s %s:%s=%s %d\n",
                $command, $feature, $keyword, $value, $seconds );
        }
        else {
            if ( defined $+{feature} ) {
                my ($feature) =
                  ( $+{feature} );
                printf( "%s %s %d\n", $command, $feature, $seconds );
            }
            else {

                printf( "%s %d\n", $command, $seconds );
            }

        }
    }
    return 1;
}
sub _timeout {
    goto &_linger;
}

sub _timeoutall {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $seconds = shift @$elements;

    if ( !$seconds ) {
        printf( "-e- Duration not defined : '%s'\n", $line );
        return 0;
    }

    if ( $seconds !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Duration %s : '%s'\n", $seconds, $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %d\n", uc($command), $seconds );
    return 1;
}

sub _max_connections {
    goto &_timeoutall;
}

sub _nolog {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $val     = shift @$elements;

    if ( !$val ) {
        printf( "-e- Missing Value : '%s'\n", $line );
        return 0;
    }

    if ( $val !~ /^(IN|OUT|DENIED|QUEUED|UNSUPPORTED|UPGRADE|DEQUEUED)$/isxm ) {
        printf( "-e- Invalid Value %s : '%s'\n", $val, $line );
        return 0;
    }
    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s\n", uc($command), uc($val) );
    return 1;
}

sub _reportlog {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    if ( !@$elements ) {
        printf( "-e- Missing Parameters : '%s'\n", $line );
        return 0;
    }

    my $plus;
    if ( $elements->[0] eq "+" ) {
        $plus = shift @$elements;
    }
    $plus //= "";
    my $path = shift @$elements;

    if ( !$path || uc($path) eq 'HIDE_USER' ) {
        printf( "-e- Missing File : '%s'\n", $line );
        return 0;
    }
    my $hide = @$elements ? shift @$elements : "";

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s %s\n", $command, $plus, $path, $hide );
    return 1;
}

sub _max {
    my $line     = shift;
    my $elements = shift;

    my $command = shift @$elements;
    my $num_lic = shift @$elements;

    if ( !$num_lic ) {
        printf( "-e- Num_Lic not defined : '%s'\n", $line );
        return 0;
    }

    if ( $num_lic !~ /^\d+$/isxm ) {
        printf( "-e- Invalid Num_Lic '%s' : '%s'\n", $num_lic, $line );
        return 0;
    }

    my $feature = shift @$elements;
    my $type    = shift @$elements;
    if ($type) {
        if ( $type !~
            /^(USER|HOST|DISPLAY|INTERNET|PROJECT|GROUP|HOST_GROUP)$/isxm )
        {
            printf( "-e- Invalid Type %s : '%s'\n", $type, $line );
            return 0;
        }
    }
    else {
        printf( "-e- Type not defined : '%s'\n", $line );
        return 0;
    }

    my $featurestr;

    if ( $feature =~ $featurepat ) {
        if ( defined $+{keyword} ) {
            my ( $feature, $keyword, $value ) =
              ( $+{feature}, $+{keyword}, $+{value} );
            $featurestr = sprintf( "%s:%s=%s", $feature, $keyword, $value );
        }
        else {
            if ( defined $+{feature} ) {
                $featurestr = $+{feature};
            }
        }
    }
    else {
        printf( "-e- Invalid Feature %s : '%s'\n", $feature, $line );
        return 0;
    }

    my $name = shift @$elements;
    if ( !$name ) {
        printf( "-e- Invalid Missing name : '%s'\n", $line );
        return 0;
    }

    if (@$elements) {
        printf( "-e- Extra Parameters : '%s'\n", $line );
        return 0;
    }

    printf( "%s %s %s %s %s\n", $command, $num_lic, $featurestr, $type, $name );
    return 1;
}

sub _reserve {
    goto &_max;
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
