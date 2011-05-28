#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::Typo;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::Typo->new($store_sink, 'pl');

$checker->process('Autozoil/Typo/simple.tex');

ok(!$store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [ 
      {       
          'type' => 'typo',
          'comment' => '~ should be used after a short word',
          'line_number' => 6,
          'beg' => 7,
          'end' => 7,
          'label' => 'SHORT_WORD',
          'frag' => 'o lepszym',
      },
      {       
          'type' => 'typo',
          'comment' => '~ should be used after a short word',
          'line_number' => 8,
          'beg' => 1,
          'end' => 1,
          'label' => 'SHORT_WORD',
          'frag' => 'I Marek',
      },
      {       
          'type' => 'typo',
          'comment' => '~ should be used after a short word',
          'line_number' => 8,
          'beg' => 10,
          'end' => 11,
          'label' => 'SHORT_WORD',
          'frag' => 'i  Anna',
      },
      {       
          'type' => 'typo',
          'comment' => '~ should be used after a short word',
          'line_number' => 8,
          'beg' => 19,
          'end' => 19,
          'label' => 'SHORT_WORD',
          'frag' => 'i',
      },
      {       
          'type' => 'typo',
          'comment' => '~ should be used',
          'line_number' => 11,
          'beg' => 7,
          'end' => 7,
          'label' => 'VAR_WORD',
          'frag' => 'Zmienna $x$',
      },
      {       
          'type' => 'typo',
          'comment' => '~ should be used',
          'line_number' => 14,
          'beg' => 22,
          'end' => 22,
          'label' => 'VAR_WORD',
          'frag' => 'szerokości $w$',
      },
      {       
          'type' => 'typo',
          'comment' => 'formula should end with a punctuation',
          'line_number' => 18,
          'beg' => 11,
          'end' => 11,
          'label' => 'FORMULA_WITHOUT_PUNCTUATION',
          'frag' => '2 \]',
      },
      {       
          'type' => 'typo',
          'comment' => 'comma should be used as the decimal separator',
          'line_number' => 24,
          'beg' => 26,
          'end' => 26,
          'label' => 'DECIMAL_SEPARATOR',
          'frag' => '2.56',
      },
    ]);

