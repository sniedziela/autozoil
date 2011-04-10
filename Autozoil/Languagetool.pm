
package Autozoil::Languagetool;

use strict;

use XML::Simple;
use Data::Dumper;

my @unwanted_errors = split/\n/,<< 'END_OF_UNWANTED_ERRORS';
WHITESPACE_RULE
UPPERCASE_SENTENCE_START
COMMA_PARENTHESIS_WHITESPACE
END_OF_UNWANTED_ERRORS

sub new {
    my ($class, $sink, $language) = @_;

    my $self = {
        'sink' => $sink,
        'language' => $language
    };

    return bless $self, $class;
}

sub process {
    my ($self, $filename) = @_;

    my $language = $self->{'language'};
    my $disable_option = join(',', @unwanted_errors);

    my $tmp_file = `mktemp`;
    chomp $tmp_file;
    $tmp_file .= '.txt';
    my $out_tmp_file = `mktemp`;
    chomp $out_tmp_file;
    `detex -l "$filename" > "$tmp_file"`;

    # languagetool output has to processed because of some bug in
    # languagetool
    `languagetool -c utf8 -l "$language" -d "$disable_option" --api "$tmp_file" | perl -ne 'BEGIN{print qq{<?xml version="1.0" encoding="UTF-8"?><matches>}}END{print qq{</matches>}} print if /^<error/' > "$out_tmp_file"`;

    my $ref = XMLin($out_tmp_file, 'ForceArray' => 1);

    if (ref $ref->{'error'}) {
        for my $error (@{$ref->{'error'}}) {
            $self->process_error($error);
        }
    }
}

sub process_error {
    my ($self, $error) = @_;

    my $sink = $self->{'sink'};

    $sink->add_mistake({
        'line_number' => $error->{'fromy'} + 1,
        'frag' => $error->{'context'},
        'beg' => $error->{'fromx'},
        'end' => $error->{'tox'},
        'comment' => $error->{'ruleId'} .': '. $error->{'msg'} . ' ['. $error->{'replacements'} .']',
        'type' => 'grammar'
    });
}

