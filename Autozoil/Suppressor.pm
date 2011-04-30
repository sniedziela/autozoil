package Autozoil::Suppressor;

use strict;

use Autozoil::Suppressor::Parser;

use Data::Dumper;

sub new {
    my ($class, $filename) = @_;

    my @suppressions = Autozoil::Suppressor::Parser::parse($filename);

    my $label_index = create_label_index(@suppressions);
    
    my $self = {
        'label_index' => $label_index,
        'filename' => $filename,
        'suppressions' => [@suppressions]
    } ;

    return bless $self, $class;
}

sub add_mistake {
    my ($self, $mistake) = @_;

    my @label_index_keys = $self->get_label_index_keys($mistake);

    my $label_index = $self->{'label_index'};

    for my $label_index_key (@label_index_keys) {
        for my $suppression (@{$label_index->{$label_index_key}}) {
            if ($self->try_suppress($mistake, $suppression)) {
                return;
            }
        }
    }
}

sub try_suppress {
    my ($self, $mistake, $suppression) = @_;

    if (is_number($mistake->{'line_number'})
        && is_number($suppression->{'line_from'})
        && is_number($suppression->{'line_to'})
        && $mistake->{'line_number'} >= $suppression->{'line_from'}
        && $mistake->{'line_number'} <= $suppression->{'line_to'}) {

        $mistake->{'suppressed'} = 1;
        return 1;
    }

    return 0;
}

sub is_number {
    my ($s) = @_;

    return $s =~ m{ ^ \d+ $ }x;
}

sub get_label_index_keys {
    my ($self, $mistake) = @_;

    my $label = $mistake->{'label'};
    my $type = $mistake->{'type'};

    return ("${type}-*", "${type}-${label}");
}

sub create_label_index {
    my (@suppressions) = @_;

    my %label_index;

    for my $suppression (@suppressions) {
        push @{$label_index{$suppression->{'label'}}}, $suppression;
    }

    return \%label_index;
}

1;
