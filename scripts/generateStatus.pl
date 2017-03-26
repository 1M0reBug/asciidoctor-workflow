#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use JSON::PP;

sub say {
	my $value = shift;
	print "$value\n";
}

my $h = {};

$h->{'code'} = "fr";
$h->{'language'} = "Français-FR";
$h->{'maintainers'} = ('jordan');

my $h2 = {};
my $h3 = {};

my $adocRegex = qr{.*\.adoc};
my $imgRegex  = qr{.*?\.(jpe?g|png|bmp|svg)}i;

foreach my $dir (glob "rapport/*") {
	next unless -d $dir;

	my $filedir = $dir =~ s/(^.*?)([^\/]*)$/$2/r;

	$h2->{$filedir} = dirToJson($dir, $adocRegex);
	$h3->{$filedir} = dirToJson($dir, $imgRegex);
}

$h->{'files'}  = $h2;
$h->{'images'} = $h3;
my $json = JSON::PP->new
				   ->pretty
				   ->ascii
				   ->allow_nonref
				   ->escape_slash
				   ->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })
				   ->encode($h);

open (FILE,'>','status.json');
print FILE $json;
close FILE;

sub dirToJson {

	my $currentDir = shift;
	my $rex = shift;
	my $tmpHash = {};
	my $finalHash = {};

	foreach my $dir (glob "$currentDir/*") {

		if(-d $dir) {
			$tmpHash = dirToJson($dir, $rex);
		} elsif (-f $dir && $dir =~ /$rex/) {
			my $file = $dir =~ s/rapport\/.*?\///r;
			$finalHash->{$file} = -s $dir;
		}

		while( my ($key, $value) = each %$tmpHash){
			$finalHash->{$key} = $value;
		}
	}

	return $finalHash;
}
