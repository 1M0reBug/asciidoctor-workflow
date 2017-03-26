#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use utf8;

use Unicode::Normalize;


sub say {
	my $value = shift;
	print "$value\n";
}

sub print_help {
    my $eof = <<EOF;
USAGE
    newSection.pl <section1> ... <sectionN>
EOF
    print $eof;
}

my $file = 'count';
my $count = 1;
if(-f $file) {
	open (FILE, '<', $file);
	$count = <FILE>;
	close FILE;
}

if(!$ARGV[0] || $ARGV[0] eq "help") {
    print_help();
    exit;
}

foreach my $title (@ARGV) {

	$count = '0'.$count if($count < 10);

	my $newTitle = NFKD(lc($title));
    $newTitle =~ s/\p{NonspacingMark}//g;

	for($newTitle) {
		s/[\\\/\<\>\:\"\?\*]//g;
		s/\pM+//g;
		s/[\s']+/_/g;
	}

	say "new Title : $newTitle";

	my $dir = "../rapport/$count-$newTitle";

	say "dir is $dir";

	mkdir $dir;
	mkdir "$dir/sections";
	mkdir "$dir/images";
	open (T, '>' ,"$dir/01-$newTitle.adoc");
	print T "[[$newTitle]]\n=== $title\n";
	close T;

	open (F, '>>', "../rapport.adoc");
    $dir =~ s/^\.\.\///;
	print F "\n\ninclude::$dir/01-$newTitle.adoc[]";
	close F;

	$count =~ s/^0+//;
	$count ++;
}




open (LASTFILE, '>', $file);

print LASTFILE "$count";
close LASTFILE;
