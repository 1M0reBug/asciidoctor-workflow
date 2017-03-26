#!/usr/bin/perl

use warnings;
use strict;
use autodie;

sub print_help {
    my $help = <<EOF;
USAGE
    shiftSections.pl <startSectionNb>-<endSectionNb> [+-]<shift>

    You must specify a range of sections to shift.
    if startSectionNb is not defined, it equals 1.
    To shift 1 section you can write:
    ```
    \$ ./shiftSections.pl 4-4 +1
    ```
    As effect the section N°4 will be moved to section 5.

    ```
    \$ ./shiftSections.pl -3 +1
    ```
    here sections from 1 to 3 will be offseted by 1. 
EOF
    print $help;
}

my $folderGlob = shift @ARGV;

if(!$folderGlob || $folderGlob eq "help") {
    print_help();
    exit;
}

my $shift = shift @ARGV;

my $file = '../rapport.adoc';

my @foldersGlob = split('-', $folderGlob);

$foldersGlob[0] = 1 if (!$foldersGlob[0] || $foldersGlob[0] == 0);

die("last element must be smaller than first") if($foldersGlob[1] < $foldersGlob[0]);

die("You must specify a shift range with '+/-[0123456789]'") unless ($shift =~ /^[+-]?\d+$/);
$shift =~ s/^\+//;

if($shift > 0) {
	for(my $i = $foldersGlob[1]; $i >= $foldersGlob[0]; $i--) {
		myMainFunction($i, $shift);
	}
} else {
	for(my $i = $foldersGlob[0]; $i <= $foldersGlob[1]; $i++) {
		myMainFunction($i, $shift);
	}
}



sub myMainFunction {
	my $i = shift @_;
	my $shift = shift @_;

	my $idx = ($i < 10) ? '0'.$i : $i;

	my $n_idx = $i + $shift;
	$n_idx = ($n_idx < 10) ? '0'.$n_idx : $n_idx;

	print "old index is : $idx\nnew index is : $n_idx\n";

	foreach my $folder (glob("../rapport/$idx-*")) {

		my $qr = qr/${idx}-/;
		my $newFileName = $folder =~ s/$qr/${n_idx}-/r;

		print "new folder name is : $newFileName\n";

		die ("please remove already existing $newFileName") if(-d $newFileName);
		rename ($folder,$newFileName);

		my @oldLines;
        $folder =~ s/^\.\.\///;
        $newFileName =~ s/^\.\.\///;
		open (FILE, '<', $file);


		while(<FILE>) {
			if ($_ =~ /$folder/) {
				$_ =~ s/$folder/$newFileName/;
			}
			push(@oldLines, $_);
		}

		close(FILE);

		open (T, '>', $file);
		print T @oldLines;
		close(T);

	}

}
