#!/usr/bin/perl

use strict;

use utf8;

use Test::More tests => 2;
use Test::Deep;

use Autozoil::Languagetool;
use Autozoil::Sink::Store;

my $store_sink = Autozoil::Sink::Store->new();
my $checker = Autozoil::Languagetool->new($store_sink, 'pl');

$checker->process('ok.tex');

ok($store_sink->is_ok());

cmp_deeply(
    [ $store_sink->get_all_mistakes() ],
    [ ]);

