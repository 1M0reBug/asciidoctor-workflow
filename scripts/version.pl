#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use utf8;

sub say {
    print shift . "\n";
}

sub print_help {
    my $help = <<EOF;
USAGE
    version.pl <major|minor> [file].adoc

increment the version number in rapport.adoc by default but could be
any file precised by file.

`version major` increment the major version. 0.1 becomes 1.0
`version minor` increments the mino version. 0.1 become 0.2.
EOF

print $help;
}

sub update_version {
    my ($initial_version, $increment) = @_;
    my ($major_number, $minor_number) = 
        $initial_version =~ /(\d+)\.(\d+)/;
    
    if (my ($major, $minor) = $increment =~ /(\d+)\.(\d+)/) {
        $major_number = $major;
        $minor_number = $minor;
    } if ($increment eq 'major') {
        $major_number++;
        $minor_number = 0;
    } elsif ($increment eq 'minor') {
        $minor_number++;
    }

    return "$major_number.$minor_number";
}

my $version = $ARGV[0] // 'minor';

my $file = '../' . ($ARGV[1] // 'rapport.adoc');
my @increment;
unless (@increment = $version =~ /^(\d+\.\d+|major|minor)$/) {
    die 'Use major, minor or @ followed by version number!';
}

if (-f $file) {
    my @oldLines;
    open(FILE, '<', $file);

    while (<FILE>) {
        my @catched_version;
        if (@catched_version = $_ =~ /^\:version\:\s*(\d+\.\d+)/) {
            my $new_version = update_version($catched_version[0], $increment[0]);
            say "From version ". ${catched_version[0]} . " to ${new_version}";
            $_ = ":version: $new_version\n";
        }
        push(@oldLines, $_);
    }

    close(FILE);

    open (T, '>', $file);
    print T @oldLines;
    close(T);
}
