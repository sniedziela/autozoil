
package Autozoil::Chktex;

use strict;

my %UNWANTED_WARNINGS = map { $_ => 1 } split/\n/,<< 'END_OF_UW';
1
13
END_OF_UW

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
    my $empty_line = 0;
    my $current_mistake;
    my $current_line;

    while (my $line=<$chktexh>) {
        chomp $line;

        if ($state eq 'WARNING') {
            $empty_line = 0;

            if (my ($warning_number, $line_number, $comment) = ($line =~ /^Warning (\d+) in .*? line (\d+): (.*)$/)) {
                $current_mistake = {
                    'line_number' => $line_number,
                    'comment' => $comment,
                    'type' => 'latex',
                    'label' => $warning_number,
                }
            }
            else {
                unexpected_line($line, $state);
            }

            $state = 'LINE';
        }
        elsif ($state eq 'LINE') {
            $state = 'POSITION';

            $current_line = $line;

            if ($line eq q{}) {
                $empty_line = 1;
            }
        }
        elsif ($state eq 'POSITION') {
            if (my ($pre_spaces, $warning_region) = ($line =~ /^( *)(\^+)$/)) {
                my $beg = length($pre_spaces);
                my $len = length($warning_region);

                $current_mistake->{'beg'} = $beg;
                $current_mistake->{'end'} = $beg + $len;

                $self->handle_mistake($current_mistake, $current_line);
            }
            elsif ($empty_line && $line eq q{}) {
                $self->handle_mistake($current_mistake, $current_line);
            }
            else {
                unexpected_line($line, $state);
            }

            $state = 'WARNING';
        }
    }
}

sub handle_mistake {
    my ($self,  $mistake, $current_line) = @_;

    my $sink = $self->{'sink'};

    if (!$self->is_unwanted_warning($mistake, $current_line)) {
        $sink->add_mistake($mistake);
    }
}

sub is_unwanted_warning {
    my ($self, $mistake, $current_line) = @_;
    
    return
        $UNWANTED_WARNINGS{$mistake->{'label'}} 
        || $mistake->{'label'} == 8 && $current_line =~ / -- /
        || $mistake->{'label'} == 26 && $current_line =~ / ,,/
}

sub unexpected_line {
   my ($line, $state) = @_; 

   die "unexpected line in chktex output: $line [state: $state]";
}

1;
