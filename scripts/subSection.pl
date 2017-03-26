#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Unicode::Normalize;
use utf8;

sub say {
	my $value = shift;
	print "$value\n";
}

sub print_help {
    my $help = <<EOF;
USAGE
    subSection.pl <folderName> <sectionName> <nexSectionName>
    subSection.pl <metaFolderName> ...

    As metaFolderName your can use the name of the folder in ../rapport withou number.
    For example:
    ```
        rapport/
        | - 01-section/
        |   | - 01-section.adoc
        |   | - sections/

        \$ ./subSection.pl section "Sub section 1" "Sub section 2"

        rapport/
        | - 01-section/
        |   | - 01-section.adoc
        |   | - sections/
        |   |   | - 01-sub_section_1.adoc
        |   |   | - 02-sub_section_2.adoc
    ```

    it automatically detects the offset to give to numerotation
    ```
    rapport/
    | - 01-section/
    |   | - 01-section.adoc
    |   | - sections/
    |   |   | - 02-sub_section_2.adoc

    \$ ./subSection.pl section "Sub section 5"

    rapport/
    | - 01-section/
    |   | - 01-section.adoc
    |   | - sections/
    |   |   | - 02-sub_section_2.adoc
    |   |   | - 03-sub_section_5.adoc
    ```
EOF
    print $help;
}

my $folder = shift @ARGV;

if (!$folder || $folder eq 'help') {
    print_help();
    exit;
}

unless ($folder =~ /\d{2}/){
    $folder = (glob("../rapport/*$folder"))[0]  ;
} else {
    $folder = "../rapport/$folder";
}

my $mainFile = $folder =~ s/^.*-//r;
my $mainAdocFile = "01-".$mainFile.".adoc";

my $idx = 1;

my @adocFiles = glob("$folder/sections/*.adoc");
my $adocFile = pop(@adocFiles);

if($adocFile) {
    for ($adocFile) {
        s\.+/\\;
        s/-.+$//;
        s/^0//;
    }
    $idx = $adocFile + 1;
}



foreach my $title (@ARGV) {
	my $newTitle = NFKD(lc($title));

	for($newTitle) {
		s/[\\\/\<\>\:\"\?\*]//g;
        s/\p{NonspacingMark}//gxms;
		s/\pM+//g;
		s/[\s']+/_/g;
	}

	say "new Title : $newTitle";

	my $dir = "$folder/sections";

	my $strIdx = ($idx<10) ? "0".$idx : $idx;
	my $ffile = "$dir/$strIdx-$newTitle.adoc";

	say "dir is $dir";
	open (T, '>', $ffile);
	print T "[[${mainFile}_$newTitle]]\n=== $title\n";
	close T;

	open (F, '>>', "$folder/$mainAdocFile");
	print F "\n\ninclude::sections/$strIdx-$newTitle.adoc[]";
	close F;

	$idx ++;
}
