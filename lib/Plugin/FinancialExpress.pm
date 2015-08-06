package Plugin::FinancialExpress;

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
            'http://www.financialexpress.com/feed/'
        ];
    },
);

sub source_name {
    return q{Financial Express};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        title       => $story->{title},
        category    => $story->{'category'}->[0],
        description => $story->{description},
        time        => $story->{'pubDate'},
        source      => $self->source_name(),
        url         => $url,
        author      => $story->{'dc'}->{creator},
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $content = '';
    for my $e ($page->find('div.main-story')->first->find('p')->each) {
        $content = $content . "\n\n" . $e->all_text(0);
    }

    return {
        content     => $content,
        image_url   => $image_url,
        tags        => $tags,
    };
}

1;
