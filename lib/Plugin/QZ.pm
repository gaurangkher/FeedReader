package Plugin::QZ;

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
            'http://qz.com/india/feed/',
        ];
    },
);

sub source_name {
    return q{Quartz};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    my $author = $story->{dc}->{creator};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $title = $story->{'title'};
    my $date  = $story->{'pubDate'};
    $date =~ s/,//g;
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        title  => $title,
        author => $author,
        source => $self->source_name(),
        url    => $url,
        time   => $date,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $tags = $page->find('meta[name="news_keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $category = 'india';

    my $cont = $page->find('div.item-body')->first;
    my $content = "";
    for my $e ($cont->find('p')->each) {
        $content = $content . "\n\n" . $e->all_text(0);
    }

    return {
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
