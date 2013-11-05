#!/usr/bin/perl
#################################################################
#
# Name: gcphonehome.pl name
#
# Description:
#   Use this to update Google Analytics for simple application tracking
#   It will also check for the software version being out of date.
#
# ChangeLog:
#   21 May 2013 tpg   Initial coding
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use LWP::UserAgent;

my($me, $mepath, $mesuffix) = fileparse($0, '\.pl');
(my $version = '$Revision: 1.5 $ ') =~ tr/[0-9].//cd;

my %opts = (
    homeurl => 'http://csg.sph.umich.edu/ph/',
    versionfile => "$mepath/../release_version.txt",
    freq => 30,
);

Getopt::Long::GetOptions( \%opts,qw(
    help
    verbose
    freq=n
    pgmname=s
    quiet
    version=s
    homeurl=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help} || $#ARGV < 0) {
    warn "$me$mesuffix [options] name\n" .
        "Version $version\n" .
        "Use this to check for a changed version of the GotCloud software.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $name = shift(@ARGV);
if ($name =~ /(\S+)\./) { $name = $1; }
if (! $opts{pgmname}) { $opts{pgmname} = $name; }

#-----------------------------------------------------------------
#   Get the current version.
#-----------------------------------------------------------------
#   Now get the version of the local software
my $ver = '';
if ($opts{version}) { $ver = $opts{version}; }
else {
    if (! open(IN, $opts{versionfile})) {
        if ($opts{verbose}) { die "Unable to read file '$opts{versionfile}': $!\n"; }
        exit(1);
    }
    $ver = <IN>;
    close(IN);
    chomp($ver);
}

#-----------------------------------------------------------------
#   Check version for name. This has a side effect that we
#   check each invocation.
#-----------------------------------------------------------------
my $ua = LWP::UserAgent->new();
my $url = $opts{homeurl} . '?pgm=gotcloud:' . $name . '.php&vsn=' . $ver;
my $response = $ua->get($url);
if (! $response->is_success) {
    if ($opts{verbose}) { die "Unable to contact '$url' Err=" . $response->status_line . "\n"; }
    exit(1);
}
my $msg = $response->decoded_content();
if ($opts{verbose}) { warn "Retrieved " . length($msg) . " bytes.\n  Msg=$msg\n"; }
if ($opts{quiet}) { exit; }

#   Don't generate a message about a new version every time
my $n = int(rand(100));
if ($opts{verbose}) { warn "Random chance is $n  (compared to $opts{freq})\n"; }
if ($n > $opts{freq}) { exit; }

#print "\n\nmessage = $msg\n\n";

my $newestver = '';
foreach (split("\n", $msg)) {
    if (/version is .(\S+)./) { $newestver = $1; last; }
}


#   Compare versions and warn that a new version exists
if ($opts{verbose}) { warn "Current version=$ver, lastest version=$newestver\n"; }
if ($ver lt $newestver) { die "A new version of '$opts{pgmname}' is available  [$newestver]\n"; }

exit;


#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

gcphonehome.pl - update Google Analytics and check the software version

=head1 SYNOPSIS

  gcphonehome.pl align
  gcphonehome.pl -pgmname GotCloud align
  gcphonehome.pl -quiet umake
  gcphonehome.pl -freq 80 align
  gcphonehome.pl -ver 1.10 umake
  gcphonehome.pl -version 1.05 -pgmname GotCloud align
  gcphonehome.pl -version 1.05 -pgmname GotCloud align

=head1 DESCRIPTION

Use this program as part of the GotCloud applications to check for
a new version of the software.
This also has the side effect of tracking the app in Google Analytics.

=head1 OPTIONS

=over 4

=item B<-freq N>

Informational messages about a new version do not appear every time.
Rather the check for a new version only happens B<freq>% of the time.
Freq defaults to 30%'

=item B<-help>

Generates this output.

=item B<-homeurl url>

Specifies the base url to be fetched.

=item B<-pgmname name>

Use 'name' in any messages generated by this program.
The default is to use the parameter B<name>.

=item B<-quiet>

Surpresses any messages the program might normally generate.

=item B<-verbose>

Will generate additional messages about the running of this program.

=item B<-version ver>

Specifies the version of the software being check.
This surpresses reading a file which contains the version.

=back

=head1 PARAMETERS

=over 4

=item B<name>

Specifies the name of the program to be tracked.

=back

=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.

=head1 AUTHOR

Written by Mary Kate Trost I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut
