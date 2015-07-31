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
           'http://indiatoday.feedsportal.com/c/33614/f/589699/index.rss?http://indiatoday.intoday.in/rss/homepage-topstories.jsp', 
           'http://indiatoday.feedsportal.com/c/33614/f/647964/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=150',
           'http://indiatoday.feedsportal.com/c/33614/f/589701/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=30',
           'http://indiatoday.feedsportal.com/c/33614/f/589704/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=34',
           'http://indiatoday.feedsportal.com/c/33614/f/589705/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=61',
           'http://indiatoday.feedsportal.com/c/33614/f/589711/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=25',
           'http://indiatoday.feedsportal.com/c/33614/f/589706/index.rss?http://indiatoday.intoday.in/rss/article.jsp?sid=84',  
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
        title  => $title,
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

    my $content = "";
    for my $e ($page->find('div.right-story-container')->first->find('p')->each) {
        $content = $content . "\n\n" . $e->all_text(0);
    }

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
