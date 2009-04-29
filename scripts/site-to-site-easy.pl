#!/usr/bin/perl
#
# Module: site-to-site-easy.pl
# 
# **** License ****
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# This code was originally developed by Vyatta, Inc.
# Portions created by Vyatta are Copyright (C) 2007 Vyatta, Inc.
# All Rights Reserved.
# 
# Author: Michael Larson
# Date: April 2009
# Description: Script to archive backup and restore
# 
# **** End License ****
#

use lib "/opt/vyatta/share/perl5";
#use warnings;
use strict;
use POSIX;
use File::Copy;
use Getopt::Long;

my ($get);


sub execute_set {
    my ($tunnelname,$peerip,$presharedkey,$lnet,$rnet);

    # set up config session
    my $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }

    # apply config command
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer $tunnelname tunnel");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }


    # apply config command
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer $peerip");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }


    # apply config command
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer name authentication pre-shared-secret $presharedkey");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }


    # apply config command
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set get vpn ipsec site-to-site peer <name> tunnel <number> local-subnet $lnet");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }


    # apply config command
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set set vpn ipsec site-to-site peer <name> tunnel <number> remote-subnet $rnet");
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }

    # commit
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit"); 
    if ($err != 0) {
	system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
	exit 1;
    }
    $err = system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end");
   
}

sub execute_get {
    #just need to pull the ip from the config
    print "VERBATIM_OUTPUT\n";

    my $out = `/opt/vyatta/sbin/vyatta-output-config.pl system ntp-server`;
    my @values = split(' ', $out);
    print "<ntp-server>$values[1]</ntp-server>";
}

##########################################################################
#
# start of main
#
##########################################################################
sub usage() {
    print "       $0 --set=<key:value,key:value...>\n";
    print "       $0 --get\n";
    exit 0;
}

#pull commands and call command
GetOptions(
    "set=s"              => \$set,
    "get"                => \$get,
    ) or usage();

if (defined $set ) {
    execute_set();
}
else {
    execute_get();
}
exit 0;