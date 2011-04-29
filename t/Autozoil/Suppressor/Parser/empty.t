#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 1;
use Test::Deep;

use Autozoil::Suppressor::Parser;

my @suppressions = Autozoil::Suppressor::Parser::parse(
   'Autozoil/Suppressor/Parser/empty.tex');

cmp_deeply(
    [ @suppressions ],
    [ ]);

