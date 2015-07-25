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
            'http://www.huffingtonpost.in/feeds/verticals/india/index.xml'
        ];
    },
);

sub source_name {
    return q{HuffingtonPost};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    my $img = $story->{'enclosure'}->{'url'}
        ? $story->{'enclosure'}->{'url'}
        : undef;

    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        time      => $story->{'pubDate'},
        title     => $story->{'title'},
        author    => $story->{'author'},
        image_url => $img,
        source    => $self->source_name(),
        url       => $url,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $category = $page->find('meta[name="category"]')->first;
    $category = $category->tree->[2]->{content};

    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $content = $page->find('div#mainentrycontent')->first;
    $content = $content->find('p')->map('text')->join("\n\n")->to_string;

    return {
        content     => $content,
        description => $description,
        tags        => $tags,
        category    => $category,
    };
}

1;
