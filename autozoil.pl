#!/usr/bin/perl

use strict;

BEGIN {
    push @INC, `pwd`;
}

use Autozoil::Spell;
use Autozoil::Sink::Simple;
use Autozoil::Sink::Chain;
use Autozoil::Sink::Store;
use Autozoil::Sink::LineAdder;

my $filename = $ARGV[0];

my $simple_sink = Autozoil::Sink::Simple->new();
my $store_sink = Autozoil::Sink::Store->new();
my $chain_sink = Autozoil::Sink::Chain->new();
my $line_adder = Autozoil::Sink::LineAdder->new($filename);
$chain_sink->add_sink($line_adder);
$chain_sink->add_sink($simple_sink);
$chain_sink->add_sink($store_sink);

my $checker = Autozoil::Spell->new($chain_sink);

$checker->process($filename);

if ($store_sink->is_ok()) {
    print "AUTOZOIL FOUND NO PROBLEMS, CONGRATS!\n";
    exit 0;
} else {
    print "AUTOZOIL FOUND SOME PROBLEMS\n";
    exit 1;
}

