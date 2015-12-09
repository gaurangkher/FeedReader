package Plugin::Economist;

use Data::Dumper;
use Moose;
use Try::Tiny;
use Mojo::DOM;
use LWP::Simple;
use HTML::Entities qw(decode_entities);
use Story;
use Log::Log4perl qw(:easy);

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [ 
            'http://www.economist.com/sections/asia/rss.xml',
            'http://www.economist.com/sections/business-finance/rss.xml',
            'http://www.economist.com/sections/economics/rss.xml',
            'http://www.economist.com/blogs/economist-explains/index.xml',
            'http://www.economist.com/sections/science-technology/rss.xml',
            'http://www.economist.com/sections/international/rss.xml',
            'http://www.economist.com/topics/computer-technology/index.xml',
            'http://www.economist.com/topics/economics/index.xml',
            'http://www.economist.com/feeds/print-sections/103/special-reports.xml',
            'http://www.economist.com/sections/culture/rss.xml',
        ];
    },
);

sub source_name {
    return q{Economist};
}

sub parse {
    my ( $self, $story ) = @_;

    my @check = lc($story->{description}) =~ /india/;
    next if ( scalar @check == 0 );

    my $title  = decode_entities($story->{title});
    my $time   = $story->{pubDate};
    my $author = decode_entities($story->{author});
    my $category = decode_entities($story->{category}->[-1]);
    my $url = $story->{'link'};
    INFO qq{$url};

    my $pd = $self->get_url($url);
    next if ( !defined $pd );
    my $args = $self->parse_page($pd);

    my $obj = Story->new(
        title  => $title,
        author => $author,
        time   => $time,
        source => $self->source_name(),
        url    => $url,
        category => $category,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $tags = $page->find('meta[name="news_keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $image_url = $page->find('meta[name="sailthru.image.full"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $cont = $page->find('div.main-content')->first;
    my $content = "";
    for my $e ($cont->find('p')->each) {
        my $string = $e->to_string();
        $content = $content . "\n\n" . $e->all_text(0);
    }

    return {
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
    };
}
1;
