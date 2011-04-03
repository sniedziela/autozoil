package Autozoil::Sink::Simple;

use strict;

sub new {
    my ($class) = @_;

    my $self = { } ;

    return bless $self, $class;
}


sub add_mistake {
    my ($self, $mistake) = @_;

    print join("\t",
               $mistake->{'line_number'},
               $mistake->{'frag'},
               $mistake->{'comment'},
               $mistake->{'original_line'}),"\n";
}

1;
