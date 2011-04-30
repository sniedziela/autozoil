package Autozoil::Sink::Store;

use strict;

sub new {
    my ($class) = @_;

    my $self = {
        'mistakes' => []
    } ;

    return bless $self, $class;
}

sub add_mistake {
    my ($self, $mistake) = @_;

    return if $mistake->{'suppressed'};

    push @{$self->{'mistakes'}}, $mistake;
}

sub get_all_mistakes {
    my ($self) = @_;

    return @{$self->{'mistakes'}};
}

sub get_number_of_problems {
    my ($self) = @_;

    return $#{$self->{'mistakes'}} + 1;
}

sub is_ok {
    my ($self) = @_;

    return $#{$self->{'mistakes'}} == -1;
}

1;
