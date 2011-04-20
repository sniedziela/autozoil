
package Autozoil::Spell;

use strict;

my %latex_false_positives = map { $_ => 1 } split/\n/,<< 'END_OF_LFP';
htb
H
hH
ht
END_OF_LFP

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

    $self->{'line_number'} = 0;

    my $language = $self->{'language'};
    open my $spellh, qq{echo '!' | cat - "$filename" | perl -pne 's/\\\\(eng|ulurl|nolinkurl|reftext|mypicture){[^{}]*}/ /' | sed 's/^/^/' | hunspell -d $language -t -a |};

    while (my $line=<$spellh>) {
        chomp $line;

        if ($line eq '') {
            ++$self->{'line_number'};
        } elsif ($line =~ /^[*@]/) {
            ;
        } elsif ($line =~ /^[&#]/) {
            $self->process_spell_mistake_line($line);
        } else {
            print "SDSD??: $line\n";
        }
    }
}

sub process_spell_mistake_line {
    my ($self, $line) = @_;

    my $sink = $self->{'sink'};

    if (my ($word, $col, $comment) = ($line =~ /^\& (\S+) \d+ (\d+): (.*)$/)) {
        if (!is_false_positive($word)) {
            $sink->add_mistake({
                'line_number' => $self->{'line_number'},
                'frag' => $word,
                'beg' => $col,
                'end' => $col + length($word),
                'comment' => $comment,
                'type' => 'spell',
                'label' => $word,
            });
        }
    } elsif (my ($word, $col) = ($line =~ /^\# (\S+) (\d+)$/)) {
        if (!is_false_positive($word)) {
            $sink->add_mistake({
                'line_number' => $self->{'line_number'},
                'frag' => $word,
                'beg' => $col,
                'end' => $col + length($word),
                'type' => 'spell',
                'label' => $word,
            });
        }
    } else {
        die "wrong spelling mistake line: $line";
    }
}

sub is_false_positive {
    my ($frag) = @_;

    return exists $latex_false_positives{$frag};
}

1;
