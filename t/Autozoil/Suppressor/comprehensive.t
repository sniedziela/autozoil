#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 1;
use Test::Deep;

use Autozoil::Spell;
use Autozoil::Chktex;
use Autozoil::Languagetool;
use Autozoil::Sink::Chain;
use Autozoil::Sink::Store;
use Autozoil::Sink::LineAdder;
use Autozoil::Suppressor;

use Data::Dumper;

my $filename = 'Autozoil/Suppressor/comprehensive.tex';

my $store_sink = Autozoil::Sink::Store->new();
my $chain_sink = Autozoil::Sink::Chain->new();
my $line_adder = Autozoil::Sink::LineAdder->new($filename);
my $suppressor = Autozoil::Suppressor->new($filename);
$chain_sink->add_sink($line_adder);
$chain_sink->add_sink($suppressor);
$chain_sink->add_sink($store_sink);

my @checkers =
    (Autozoil::Spell->new($chain_sink, "pl_PL"),
     Autozoil::Chktex->new($chain_sink),
     Autozoil::Languagetool->new($chain_sink, 'pl'));

for my $checker (@checkers) {
    $checker->process($filename);
}

print STDERR Dumper([$store_sink->get_all_mistakes()]),"\n";

ok($store_sink->is_ok());

