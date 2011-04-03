
package Autozoil::Spell;

use strict;

sub new {
    my ($class, $sink) = @_;

    my $self = {
        'sink' => $sink
    };

    return bless $self, $class;
}

sub process {
    my ($self, $filename) = @_;

    $self->{'line_number'} = 1;

    open my $spellh, qq{hunspell -t -a "$filename" |};

    while (my $line=<$spellh>) {
        chomp $line;

        if ($line eq '') {
            ++$self->{'line_number'};
        } elsif ($line =~ /^[*@]/) {
            ;
        } elsif ($line =~ /^\&/) {
            $self->process_spell_mistake_line($line);
        } else {
            print "SDSD??: $line\n";
        }
    }
}

sub process_spell_mistake_line {
    my ($self, $line) = @_;

    if (my ($word, $col, $comment) = ($line =~ /^\& (\S+) \d+ (\d+): (.*)$/)) {
        my $sink = $self->{'sink'};

        $sink->add_mistake({
            'line_number' => $self->{'line_number'},
            'frag' => $word,
            'beg' => $col,
            'end' => $col + length($word),
            'comment' => $comment,
            'type' => 'spell',
        });
    } else {
        die "wrong spelling mistake line: $line";
    }
}


1;
