#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::LogAnalyser;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::LogAnalyser->new($store_sink);

`cd Autozoil/LogAnalyser ; pdflatex simple.tex`;
$checker->process('Autozoil/LogAnalyser/simple.tex');

ok(!$store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [ 
      {       
          'type' => 'latex',
          'comment' => re('overfull hbox'),
          'line_number' => 7,
          'label' => 'OVERFULL',
      },
    ]);

