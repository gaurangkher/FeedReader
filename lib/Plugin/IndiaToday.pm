package Plugin::IndiaToday;

use Data::Dumper;
use Moose;
use List::Flatten;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;
use Log::Log4perl qw(:easy);
use Encode qw(encode_utf8);

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [ 
            'http://www.firstpost.com/india/feed', 
            'http://www.firstpost.com/politics/feed',
            'http://www.firstpost.com/economy/feed',
            'http://www.firstpost.com/sports/feed',
            'http://www.firstpost.com/business/feed',
            'http://www.firstpost.com/tech/feed',
        ];
    },
);

sub source_name {
    return q{IndiaToday};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'guid'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $title = $story->{'title'};
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        time   => $story->{'pubDate'},
        source => $self->source_name(),
        url    => $url,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);
    my $title = $page->find('title')->first->content;
    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $tags = $page->find('meta[name="news_keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $content = $page->find('div.right-story-container')->first;
    $content = $content->find('p')->map('text')->join("\n\n");
    $content = $content->to_string;

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $category = $page->find('span[itemprop="title"]')->map('text');
    $category =  $category->[1];
    
    my $strap = $page->find('div.strstrap')->first;
    
    my $author = $strap->find('span')->first->find('a')->map('text')->first;

    return {
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
