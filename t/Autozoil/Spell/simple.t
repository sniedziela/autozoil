#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::Spell;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::Spell->new($store_sink, 'pl_PL');

$checker->process('Autozoil/Spell/simple.tex');

ok(!$store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [
     {
         'type' => 'spell',
         'comment' => ignore(),
         'line_number' => 6,
         'label' => 'Grzegżółka',
         'beg' => 1,
         'end' => ignore(),
         'frag' => 'Grzegżółka',
     },
   ]);

