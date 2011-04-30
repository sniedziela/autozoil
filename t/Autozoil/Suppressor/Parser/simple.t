#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 1;
use Test::Deep;

use Autozoil::Suppressor::Parser;

my @suppressions = Autozoil::Suppressor::Parser::parse(
   'Autozoil/Suppressor/Parser/simple.tex');

cmp_deeply(
    [ @suppressions ],
    [
     {
         'label' => 'spell-Mażec',
         'line_from' => 6,
         'line_to' => 6,
         'expected' => 1
     },
     {
         'label' => 'spell-Kfiecień',
         'line_from' => 6,
         'line_to' => 6,
         'expected' => 1
     },
     {
         'label'  => 'spell-*',
         'line_from' => 10,
         'line_to' => 14,
         'expected' => 3,
     },
     {
         'label'  => 'grammar-ODNOSNIE',
         'line_from' => 10,
         'line_to' => 14,
         'expected' => 1,
     },
     {
         'label'  => '???',
         'line_from' => '?',
         'line_to' => 18,
     },
     {
         'label'  => 'spell-*',
         'line_from' => 20,
         'line_to' => '?',
         'expected' => 3,
     },
     {
         'label' => 'spell-problemuw',
         'line_from' => 22,
         'line_to' => 22,
         'expected' => 1
     },
     {
         'label' => 'spell-zpacjami',
         'line_from' => 22,
         'line_to' => 22,
         'expected' => 1
     },
     {
         'label' => 'spell-zpacji',
         'line_from' => 24,
         'line_to' => 24,
         'expected' => 1
     },
    ]);

