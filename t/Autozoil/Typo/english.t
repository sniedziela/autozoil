#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::Typo;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::Typo->new($store_sink, 'en');

$checker->process('Autozoil/Typo/english.tex');

ok(!$store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [
      {
          'type' => 'typo',
          'comment' => '~ should be used after a short word',
          'line_number' => 4,
          'beg' => 8,
          'end' => 8,
          'label' => 'SHORT_WORD',
          'frag' => 'a quick',
      },
    ]);

