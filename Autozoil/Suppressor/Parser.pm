package Autozoil::Suppressor::Parser;

use strict;

use String::Util;
use Data::Dumper;

sub parse {
    my ($filename) = @_;

    my @suppressions;

    open my $fh,'<',$filename 
        or die "cannot open file '$filename'";
    binmode($fh,':utf8');

    my $line_number = 1;
    while (my $line=<$fh>) {
        chomp $line;

        my @line_raw_suppressions = parse_line($line);

        merge_suppressions($line_number, \@suppressions, @line_raw_suppressions);

        ++$line_number;
    }

    return @suppressions
}

sub parse_line {
    my ($line) = @_;

    my @raw_suppressions;

    if (my ($type, $spec) = ($line =~ m{ % \s* -- ([|<>]) (.*) $ }x)) {

        my @labels = map { String::Util::crunch($_) } split/\s*,\s*/,$spec;

        if (!@labels) {
            @labels = ('');
        }

        for my $label (@labels) {
            push @raw_suppressions, {
                'label' => $label,
                'type' => $type
            }
        }
    }

    return @raw_suppressions;
}

sub merge_suppressions {
    my ($line_number, $suppressions_ref, @new_raw_suppressions) = @_;

    for my $raw_suppression (@new_raw_suppressions) {
        if ($raw_suppression->{'type'} eq '|') {
            push @{$suppressions_ref}, {
                'label' => $raw_suppression->{'label'},
                'expected' => get_expected($raw_suppression->{'label'}),
                'line_from' => $line_number,
                'line_to' => $line_number,
            }
        }
        elsif ($raw_suppression->{'type'} eq '<') {
            push @{$suppressions_ref}, {
                'label' => $raw_suppression->{'label'},
                'expected' => get_expected($raw_suppression->{'label'}),
                'line_from' => $line_number,
                'line_to' => '?'
            }
        }
        elsif ($raw_suppression->{'type'} eq '>') {
            close_multiline_suppressions($line_number, $suppressions_ref);
        }
        else {
            die "unexpected suppressions type - $raw_suppression->{type}";
        }
    }
}

sub get_expected {
    my ($label) = @_;
    
    if ($label =~ /-\*$/) {
        return 3;
    }

    return 1;
}

sub close_multiline_suppressions {
    my ($line_number, $suppressions_ref) = @_;

    my $closed_line = undef;

    for my $suppression (reverse @{$suppressions_ref}) {
        if ($suppression->{'line_to'} eq '?') {
            if (!defined($closed_line)
                || $suppression->{'line_from'} == $closed_line) {
                $closed_line = $suppression->{'line_from'};
                $suppression->{'line_to'} = $line_number;
            }
        }
    }

    if (!defined($closed_line)) {
        push @{$suppressions_ref}, {
            'label' => '???',
            'line_from' => '?',
            'line_to' => $line_number,
        }
    }
}

1;
