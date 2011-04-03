#!/usr/bin/perl

use strict;

require './Autozoil/Spell.pm';
require './Autozoil/Sink/Simple.pm';
require './Autozoil/Sink/Chain.pm';
require './Autozoil/Sink/Store.pm';

my $filename = $ARGV[0];

my $simple_sink = Autozoil::Sink::Simple->new();
my $store_sink = Autozoil::Sink::Store->new();
my $chain_sink = Autozoil::Sink::Chain->new();
$chain_sink->add_sink($simple_sink);
$chain_sink->add_sink($store_sink);

my $checker = Autozoil::Spell->new($chain_sink);

$checker->process($filename);

if ($store_sink->is_ok()) {
    exit 0;
} else {
    exit 1;
}

