#!/usr/bin/perl

use strict;

BEGIN {
    push @INC, `pwd`;
}

binmode(STDOUT,':utf8');

use Autozoil::Spell;
use Autozoil::Chktex;
use Autozoil::Languagetool;
use Autozoil::Suppressor;
use Autozoil::Sink::Simple;
use Autozoil::Sink::Chain;
use Autozoil::Sink::Store;
use Autozoil::Sink::LineAdder;

use Getopt::Long;

my $locale;

GetOptions(
    'locale:s' => \$locale,
    'help' => \&help
) or die "wrong argument, type -h for help\n";

my $filename = $ARGV[0];

if (!defined($locale)) {
    $locale = 'pl_PL';
}

my $simple_sink = Autozoil::Sink::Simple->new();
my $store_sink = Autozoil::Sink::Store->new();
my $chain_sink = Autozoil::Sink::Chain->new();
my $line_adder = Autozoil::Sink::LineAdder->new($filename);
my $suppressor = Autozoil::Suppressor->new($filename);
$chain_sink->add_sink($line_adder);
$chain_sink->add_sink($suppressor);
$chain_sink->add_sink($simple_sink);
$chain_sink->add_sink($store_sink);

my $spell_dictionaries = $locale;
my $iso_dic_name = 'tmp-extra-pl-iso-8859-2';

if ($locale eq 'pl_PL') {
    $spell_dictionaries = "pl_PL,$iso_dic_name";
    prepare_iso_dic();
}

my $lang;

if ($locale =~ /^([^_]+)_/) {
    $lang = $1;
} else {
    die "unexpected locale '$locale'"
}

my @checkers =
    (Autozoil::Spell->new($chain_sink, $spell_dictionaries),
     Autozoil::Chktex->new($chain_sink),
     Autozoil::Languagetool->new($chain_sink, $lang));

print "STARTING AUTOZOIL\n";

for my $checker (@checkers) {
    $checker->process($filename);
}

my $post_chain_sink = Autozoil::Sink::Chain->new();
$post_chain_sink->add_sink($line_adder);
$post_chain_sink->add_sink($simple_sink);
$post_chain_sink->add_sink($store_sink);
$suppressor->postcheck($post_chain_sink);


if ($store_sink->is_ok()) {
    print "AUTOZOIL FOUND NO PROBLEMS, CONGRATS!\n";
    exit 0;
} else {
    print "AUTOZOIL FOUND ". $store_sink->get_number_of_problems()  ." PROBLEMS\n";
    exit 1;
}

sub prepare_iso_dic {
    `iconv -f UTF-8 -t ISO-8859-2 < extra-pl.dic > ${iso_dic_name}.dic`;
}

sub help {
    print STDERR "USAGE: perl autozoil.pl filename.tex --locale pl_PL\n";
    exit 1
}
