package Plugin::HuffPost;

use Data::Dumper;
use Moose;
use List::Flatten;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;
use Log::Log4perl qw(:easy);

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [ 
            'http://www.huffingtonpost.in/feeds/index.xml'
        ];
    },
);

sub source_name {
    return q{HuffingtonPost};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};

    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        time      => $story->{'pubDate'},
        title     => $story->{'title'},
        source    => $self->source_name(),
        url       => $url,
        %{$args}
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $author = $page->find('span.author-card__details__name')->first;
    $author = $author->all_text();

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $category = $page->find('meta[property="article:section"]')->first;
    $category = $category->tree->[2]->{content};

    my $tags = $page->find('meta[property="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $cont1 = ''; 
    for my $content ($page->find('.content-list-component')->each) {
        for my $ct ($content->find('p')->each) {
            my $c = $ct->all_text();
            my ($cont, @arr) = split q{\@media only screen}, $c;
            $cont1 = $cont1 . "\n\n" . $cont;
        }
    }
    return {
        content     => $cont1,
        description => $description,
        tags        => $tags,
        category    => $category,
        image_url   => $image_url,
        author      => $author,
    };
}

1;
