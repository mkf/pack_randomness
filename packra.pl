#!/usr/bin/env perl
use strict;
use warnings;
use 5.026;

use integer;

use open IO => ':raw';
use open ':std';
$/ = \1;
$| = 1;

my @ranges;
my $cache = undef;
while(1) {
	my $argument = shift;
	unless (defined($argument)) {
		die "We have trailing ${cache} ('@{[chr $cache]}' character) without a pair!"
			if defined($cache);
		last;
	}
	die "More than one character" unless length($argument)==1;
	unless (defined($cache)) {
		$cache = ord $argument;
	} else {
		push @ranges, { FROM => $cache, TO => ord $argument };
		$cache = undef;
	}
}
foreach ( @ranges ) {
	print $_->{FROM}, " → ", $_->{TO}, "\n";
}

my @boundaries;
foreach my $arange ( @ranges ) {
	my $from = $arange->{FROM};
	my $to = $arange->{TO} + 1;
	die "Bad range is negatively directed — from ${from}('@{[chr $from]}') to ${to}('@{[chr $to]}')!"
		unless $from <= $to;
	unless(@boundaries) {
		push @boundaries, $from, $to;
		next;
	}
	my @left;
	my @right;
	while(@boundaries) {
		unless (scalar(@left)%2) { #jestesmy na zewnatrz
			if ($boundaries[0] < $from) {
				# print "Zaczynamy nowy przed ${from} zaczynający się od ${boundaries[0]}\n";
				push @left, $boundaries[0];
				shift @boundaries;
				# print "a kończący się ${boundaries[0]}\n";
			} elsif ($boundaries[0] > $from) {
				# print "Zaczynamy nowy od ${from} zaczynając przed zaczynającym się od ${boundaries[0]}\n";
				push @left, $from;
			} else {
				# print "Zaczynamy nowy od ${from} gdzie zaczyna się już jeden\n";
				push @left, $from;
				shift @boundaries;
			}
		} else { #jestesmy wewnatrz
			if ($boundaries[0] < $from) {
				# print "Kończymy nowy przed ${from} kończący się na ${boundaries[0]}\n";
				push @left, $boundaries[0];
				shift @boundaries;
			} elsif ($boundaries[0] < $to) {
				# print "Kończymy nowy na ${to}, łąpiąc w środek kończący się w ${boundaries[0]}\n";
				push @right, $to;
				shift @boundaries while (@boundaries and ($boundaries[0] < $to));
			} else {
				# print "Kończymy nowy na ${to}, ale ciągle jesteśmy w środku istniejącego aż do ${boundaries[0]}\n";
				last;
			}
		}
	}
	push @right, (shift @boundaries) while(@boundaries);
	push @right, $from, $to if (!@right and ($left[$#left] < $from));
	@boundaries = (@left, @right);
}
print "u", @boundaries, "\n---\n";
my @tempb = @boundaries;
my @firsts;
my @counts;
my $valuing;
my $segments = 0;
while (@tempb) {
	my $from = shift @tempb;
	my $to = shift @tempb;
	my $count = $to - $from;
	# print "from ", $from, " to ", $to, " it's ", $count, ".\n";
	push @firsts, $from;
	push @counts, $count;
	$valuing += $count;
	$segments++;
}
print "Our valuing is ${valuing}.\n";

sub our_chr {
	my $res = shift;
	for my $i (0 .. $segments) {
		my $count = $counts[$i];
		my $reswo = $res - $count;
		if ($reswo > 0) {
			$res = $reswo;
		} else {
			$res += $firsts[$i];
			last;
		}
	}
	return (chr $res);
}

my $storemask = 0;
my $store = 0;
foreach ( <STDIN> ) {
	my $num = ord $_;
	my $nummask = 255;
	ENOUGH:
	$num += $store;
	$nummask += $storemask;
	my $res = $num % $valuing;
	my $resmask = $nummask % $valuing;
	print "\nResmask now $resmask: ";
	$num -= $res;
	$nummask -= $resmask;
	$store = $num / $valuing;
	$storemask = $nummask / $valuing;
	$num = 0;
	$nummask = 0;
	print (our_chr $res);
	goto ENOUGH if ($storemask >= $valuing);
}
