#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::Chktex;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::Chktex->new($store_sink);

$checker->process('Autozoil/Chktex/simple.tex');

ok(!$store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [
     {
         'type' => 'latex',
         'comment' => 'Wrong length of dash may have been used.',
         'line_number' => 8,
         'beg' => 17,
         'end' => 18,
     },
     {
         'type' => 'latex',
         'comment' => q{No match found for `('.},
         'line_number' => 6,
         'beg' => 8,
         'end' => 9,
     },
     {
         'type' => 'latex',
         'comment' => q{Number of `(' doesn't match the number of `)'!},
         'line_number' => 9,
     },
    ]);

