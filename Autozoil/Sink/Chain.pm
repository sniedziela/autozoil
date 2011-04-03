package Autozoil::Sink::Chain;

use strict;

sub new {
    my ($class) = @_;

    my $self = {
        'sinks' => []
    } ;

    return bless $self, $class;
}

sub add_sink {
    my ($self, $sink) = @_;

    push @{$self->{'sinks'}}, $sink;
}

sub add_mistake {
    my ($self, $mistake) = @_;

    for my $sink (@{$self->{'sinks'}}) {
        $sink->add_mistake($mistake);
    }
}

1;
