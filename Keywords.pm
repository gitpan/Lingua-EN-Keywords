package Lingua::EN::Keywords;

require 5.005_62;
use strict;
#use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(
	keywords
);
our $VERSION = '1.3';

my %dict;
my $use_dict = 0;
local *IN;
if (-e "/usr/share/dict/words" and open IN,"/usr/share/dict/words") {
    $use_dict =1;
    local $/="\n"; # Defensive.
    while(<IN>) {
        chomp; $dict{$_}++;
    }
}

my %isstop;
$isstop{$_}++ for qw(
a about above accordance according across actual added after against ahead all
almost alone along also am among amongst an and and-or and/or anon another any
are as at award away be because become becomes been before behind being below
best better between beyond both but by can certain claim come comes
coming completely comprises concerning consider considered considering
consisting corresponding could de department der described desired despite
discussion do does doesnt doing down dr du due during each either embodiment
especially et few fig figs first for forward four fourth from further generally
get give given giving good had has have having he her herein hers him his honor
how however i if im in inside instead into invention is it items its just let
lets little look looks made make makes making man many me means meet meets more
most much must my near nearly next no not now of off on one only onto or other
our out outside over overall own particularly per possibly preferably preferred
present provide provided provides pt put really regarding relatively reprinted
respectively said same second seen several she should shown since so so-called
some spp studies study such suitable take taken takes taking than that the
their them then there thereby therefore therefrom thereof thereto these they
third this those three through throughout thus to together too toward towards
two under undergoing up upon upward us use various versus very via vol vols vs
was way ways we were what whats when where whereby wherein which while whither
who whom whos whose why will with within without woman would yes yet you your
);

sub destop_sentence {
    my $sentence = shift;
    $sentence =~ s/[^a-zA-Z]+/ /g;
    grep { #!/'/ and 
           length > 2 and 
           !exists $isstop{lc($_)} 
         } split /\s+/, $sentence;
}

sub keywords {
    my %keywords;
    my $text = shift;
    $text =~ s/\n/ /g;
    # $keywords{lc $_}++ for destop_sentence(summarize($text));
    $text =~ s/[\.!\?]//g;
    for (destop_sentence($text)) {
        $keywords{lc $_}++ ;

        # Titlecaps words are big.
        if ($_ eq ucfirst lc $_) {
            $keywords{lc $_}++ ;
            $keywords{lc $_}++ if $use_dict and !exists $dict{$_}
            and !exists $dict{lc $_}; # And bigger if they're not in dict.
        }

        # Allcaps words are big.
        $keywords{lc $_}++ if /^[A-Z]+$/;

    }
    (sort {$keywords{$b} <=> $keywords{$a}} keys %keywords)[0..4];
}

# To test:
#undef $/;
#my $in = <STDIN>;
#print ((join " ", ((),keywords($in))),"\n");
1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Lingua::EN::Keywords - Automatically extracts keywords from text

=head1 SYNOPSIS

  use Lingua::EN::Keywords;

  my @keywords = keywords($text);

=head1 DESCRIPTION

This is a very simple algorithm which removes stopwords from a
summarized version of a text (generated with Lingua::EN::Summarize)
and then counts up what it considers to be the most important
"keywords". The C<keywords> subroutine returns a list of five keywords
in order of relevance.

This is pretty dumb. Don't expect any clever document categorization
algorithms here, because you won't find them. But it does a reasonable
job.

=head2 EXPORT

C<keywords> subroutine.

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

=head1 SEE ALSO

perl(1).

=cut
