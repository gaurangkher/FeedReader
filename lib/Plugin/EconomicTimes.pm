package Plugin::EconomicTimes;

use Data::Dumper;
use Moose;
use List::Flatten;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;
use String::Util qw(trim);
use Log::Log4perl qw(:easy);

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [ 
            'http://economictimes.indiatimes.com/rssfeedsdefault.cms'
        ];
    },
);

sub source_name {
    return q{Economic Times};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        title       => $story->{title},
        time        => $story->{'pubDate'},
        source      => $self->source_name(),
        url         => $url,
        description => $story->{description},
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $author = $page->find('div.byline')->first->all_text(0);
    $author =~ s/By|\|.*//g;
 	$author = trim($author);

    my $tags = $page->find('meta[name="keywords"]')->first;    
    $tags = $tags->tree->[2]->{content};

    my $content = $page->find('.Normal')->first->all_text(0);

    my $category = $page->find('h2')->first->all_text(0);

    return {
        author      => $author,
        content     => $content,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
