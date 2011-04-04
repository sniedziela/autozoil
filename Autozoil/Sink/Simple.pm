package Autozoil::Sink::Simple;

use strict;

sub new {
    my ($class) = @_;

    my $self = { } ;

    return bless $self, $class;
}


sub add_mistake {
    my ($self, $mistake) = @_;

    print join(" *** ",
               clean_filename($mistake->{'filename'}) . ' ' . $mistake->{'line_number'},
               $mistake->{'frag'},
               $mistake->{'original_line'},
               $mistake->{'comment'}),"\n";
}

sub clean_filename {
    my ($filename) = @_;

    $filename =~ s{^(.*)/}{};

    return $filename;
}

1;
