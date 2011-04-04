package Autozoil::Sink::LineAdder;

use strict;

sub new {
    my ($class, $filename) = @_;

    my $self = {
        'lines' => [read_lines($filename)],
        'filename' => $filename,
    } ;

    return bless $self, $class;
}

sub read_lines {
    my ($filename) = @_;

    open my $fh,'<',$filename;

    my @lines;

    while (my $line=<$fh>) {
        chomp $line;
        push @lines, $line;
    }

    return @lines;
}

sub add_mistake {
    my ($self, $mistake) = @_;

    my $line_no = $mistake->{'line_number'};

    if (defined $line_no) {
        $mistake->{'original_line'} = $self->{'lines'}->[$line_no-1];
    }

    $mistake->{'filename'} = $self->{'filename'};
}

1;



