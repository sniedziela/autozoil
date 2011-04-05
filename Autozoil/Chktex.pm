
package Autozoil::Chktex;

use strict;

sub new {
    my ($class, $sink) = @_;

    my $self = {
        'sink' => $sink,
    };

    return bless $self, $class;
}

sub process {
    my ($self, $filename) = @_;

    open my $chktexh, qq{chktex "$filename" |};

    my $sink = $self->{'sink'};
    my $state = 'WARNING';
    my $current_mistake;

    while (my $line=<$chktexh>) {
        chomp $line;

        if ($state eq 'WARNING') {
            if (my ($line_number, $comment) = ($line =~ /^Warning \d+ in .*? line (\d+): (.*)$/)) {
                $current_mistake = {
                    'line_number' => $line_number,
                    'comment' => $comment,
                    'type' => 'latex'
                }
            }
            else {
                unexpected_line($line, $state);
            }

            $state = 'LINE';
        }
        elsif ($state eq 'LINE') {
            $state = 'POSITION';
        }
        elsif ($state eq 'POSITION') {
            if (my ($pre_spaces, $warning_region) = ($line =~ /^( *)(\^+)$/)) {
                my $beg = length($pre_spaces);
                my $len = length($warning_region);

                $current_mistake->{'beg'} = $beg;
                $current_mistake->{'end'} = $beg + $len;

                $sink->add_mistake($current_mistake);
            }
            else {
                unexpected_line($line, $state);
            }

            $state = 'WARNING';
        }
    }
}

sub unexpected_line {
   my ($line, $state) = @_; 

   die "unexpected line in chktex output: $line [state: $state]";   
}

1;
