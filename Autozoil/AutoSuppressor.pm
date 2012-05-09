package Autozoil::AutoSuppressor;

use strict;

use Data::Dumper;

sub new {
    my ($class, $filename) = @_;

    open my $fh, '<', $filename;
    binmode($fh, ':utf8');

    my $line_number = 1;
    my $skipping = 0;

    my %unwanted_lines;

    while (my $line = <$fh>) {
        if ($line =~ m{^ \s* \\begin\{lstlisting\} }x) {
            $skipping = 1;
        }

        if ($skipping) {
            $unwanted_lines{$line_number} = 1;
        }

        if ($line =~ m{^ \s* \\end\{lstlisting\} }x) {
            $skipping = 0;
        }

        ++$line_number;
    }

    my $self = {
        'unwanted_lines' => \%unwanted_lines,
        'filename' => $filename,
    } ;

    return bless $self, $class;
}

sub add_mistake {
    my ($self, $mistake) = @_;

    if (is_number($mistake->{'line_number'})
        && exists $self->{'unwanted_lines'}->{$mistake->{'line_number'}}) {
        $mistake->{'unwanted'} = 1;
    }
}

sub is_number {
    my ($s) = @_;

    return $s =~ m{ ^ \d+ $ }x;
}

1;
