
package Autozoil::LogAnalyser;

# checking various typographic conventions

use utf8;
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

    my $log_filename = $self->get_log_filename($filename);

    my $sink = $self->{'sink'};

    if (! -r $log_filename) {
        print STDERR "no log file '$log_filename' found\n";
        return;
    }

    print STDERR "analysing '$log_filename\n";

    open my $logh,'<',$log_filename;

    while (my $line=<$logh>) {
        if (my ($too_wide, $line_number) = 
                ($line =~ m{ Overfull \s \\hbox \s \((\d*.\d+)pt \s too \s wide\)
                             \s in \s paragraph \s at \s lines \s (\d+)--\d+ }x)) {
            $sink->add_mistake({
                'type' => 'latex',
                'label' => 'OVERFULL',
                'comment' => qq{overfull hbox ($too_wide too wide)},
                'line_number' => $line_number ,
            });
        }
    }

}

sub get_log_filename {
    my ($self, $filename) = @_;

    if ($filename !~ s{ \. [^\.]* $}{.log}x) {
        $filename .= '.log';
    }

    return $filename;
}

1;


