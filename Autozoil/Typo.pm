
package Autozoil::Typo;

# checking various typographic conventions

use utf8;
use strict;

my %SHORT_WORDS = (
    'pl' => ['a','i','o','u','w','z'],
    'en' => ['a'],
);

my %VAR_WORDS = (
    'pl' => ['zmienna','zmiennej','zmienną','zmienne','zmiennych','zmiennymi','zmiennym',
             'szerokości', 'wysokości', 'długości', 'głębokości'],
    'en' => ['variable'],
);

my %VERSION_WORDS = (
    'pl' => ['wersja','wersji','wersję','wersją','wersje','wersjami','wersjach','wersjom',
             'v.', 'ver.', 'Web'],
    'en' => ['version','v.','ver.','Web'],
);

my $WORD_REGEXP = '[A-Za-zĄĆĘŁŃÓŚŹŻąćęłńóśźż]+';
my $PRE_PUNCTUATION = qr{(?:^|[\s\(,~])};

sub new {
    my ($class, $sink, $language) = @_;

    my $self = {
        'sink' => $sink,
        'language' => $language,
    };

    return bless $self, $class;
}

sub process {
    my ($self, $filename) = @_;

    my $original_all_text = $self->get_all_text($filename);
    my $filtred_all_text = $self->filtre_text($original_all_text);

    $self->check_short_words($filtred_all_text);
    $self->check_var_words($filtred_all_text);
    $self->check_captions($filtred_all_text);
    $self->check_formula_punctuations($filtred_all_text);
    $self->check_decimal_separators($filtred_all_text);
}

sub check_short_words {
    my ($self, $text) = @_;

    my $language = $self->{'language'};

    my $short_word_regex = join('|', @{$SHORT_WORDS{$language}});

    $self->check_with_regex(
        qr{ $PRE_PUNCTUATION ($short_word_regex) ([\s]+) ($WORD_REGEXP) }xmsi,
        'SHORT_WORD',
        '~ should be used after a short word',
        $text);
}

sub check_var_words {
    my ($self, $text) = @_;

    my $language = $self->{'language'};

    my $var_word_regex = join('|', @{$VAR_WORDS{$language}});

    $self->check_with_regex(
        qr{ $PRE_PUNCTUATION ($var_word_regex) ([\s]+) (\$[a-zA-Z]\$) }xmsi,
        'VAR_WORD',
        '~ should be used',
        $text);
}

sub check_captions {
    my ($self, $text) = @_;

    my $language = $self->{'language'};

    if ($language eq 'pl') {
        $self->check_with_regex(
            qr{ (\\caption{ [^{}]+) (\.) (\s*}) }xms,
            'CAPTION_NO_PERIOD',
            q{table and figure captions should not end with '.'},
            $text);
    }
}

sub check_formula_punctuations {
    my ($self, $text) = @_;

    $self->check_with_regex(
        qr{ ([^\.,;\s\n]) () (\s\n*\\\]) }xms,
        'FORMULA_WITHOUT_PUNCTUATION',
        q{formula should end with a punctuation},
        $text);
}

sub check_decimal_separators {
    my ($self, $text) = @_;

    my $text_without_versions = $self->filtre_version($text);

    my $language = $self->{'language'};

    if ($language eq 'pl') {
        $self->check_with_regex(
            qr{ $PRE_PUNCTUATION (\d+) (\.) (\d+) }xms,
            'DECIMAL_SEPARATOR',
            q{comma should be used as the decimal separator},
            $text_without_versions);
    }
}

sub check_with_regex {
    my ($self, $regex, $label, $comment, $text) = @_;

    my $sink = $self->{'sink'};

    while ($text =~ m/$regex/g) {
        my ($pre,$in,$post) = ($1,$2,$3);
        my $offset = $-[2];

        my ($line_number, $column_number) = $self->get_line(substr($text, 0, $offset));

        my $column_number_end =
            ( length($in)
              ? $column_number + length($in) - 1
              : $column_number);

        my $frag =
            ( $in =~ /\n/
              ? $pre
              : $pre.$in.$post );

        $sink->add_mistake({
            'type' => 'typo',
            'label' => $label,
            'comment' => $comment,
            'frag' => $frag,
            'line_number' => $line_number,
            'beg' => $column_number,
            'end' => $column_number_end,
        });
    }
}


sub get_line {
    my ($self, $text) = @_;


    if (my ($last_line) = ($text =~ /\n([^\n]+)\Z/)) {

        my $nb_lines = ($text =~ y/\n/\n/);
        return ($nb_lines+1, length($last_line));
    } else {
        return (1, length($text));
    }


}

sub get_all_text {
    my ($self, $filename) = @_;

    open my $fileh,'<',$filename;
    binmode($fileh,':utf8');

    my $all_text;

    while (my $line=<$fileh>) {
        $all_text .= $line;
    }

    return $all_text;
}

sub filtre_version {
    my ($self, $text) = @_;

    $text =~ s{ (\d+ ( \. \d+ ){2,} | \\(code|hspace){ [^{}]+ }
                 | \d*\.\d+(,-?\d*\.\d+)+ | \d+,-?\d*\.\d+ | \d*\.-?\d+,\d+ )  }{ ' ' x length($1) }egx;

    my $language = $self->{'language'};

    my $ver_words_regex = join('|', @{$VERSION_WORDS{$language}});
    $text =~ s{ (($ver_words_regex | [A-Z]{2,} | width) (~|[\s\n]+) \d+ \. \d+) }{ ' ' x length($1) }egx;

    return $text;
}

sub filtre_text {
    my ($self, $text) = @_;

    $text =~ s/(\A|[^\\])(%[^\n]*)/ $1 . (' ' x length($2))/emsg;

    return $text;
}

1;


