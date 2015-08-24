package Plugin::WSJ;

use Data::Dumper;
use Moose;
use List::Flatten;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;
use Log::Log4perl qw(:easy);
use Try::Tiny;

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [
            'http://www.wsj.com/xml/rss/3_7656.xml', 
            'http://www.wsj.com/xml/rss/3_8147.xml',
            'http://www.wsj.com/xml/rss/3_7013.xml',
            'http://www.wsj.com/xml/rss/3_9033.xml',
            'http://www.wsj.com/xml/rss/3_7085.xml',
        ];
    },
);

sub source_name {
    return q{Wall Street Journal};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    my $is_free = lc($story->{'category'}) eq 'free'
        ? 1 : 0;

    my $title = $story->{'title'};
    next if $title eq q{WSJ.com: India Journal};
    my $desc  = $story->{'description'};
    next if ($title !~ /india/i || $desc !~ /india/i);
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd, $is_free);
    my $obj   = Story->new(
        title       => $title,
        time        => $story->{'pubDate'},
        description => $desc,
        source      => $self->source_name(),
        url         => $url,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd, $is_free ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $author = $page->find('meta[name="author"]')->first;
    $author = $author->tree->[2]->{content};
    my $category = $page->find('meta[name="article.section"]')->first;
    $category = $category->tree->[2]->{content};

    my $tags =  try {
        $page->find('meta[name="news_keywords"]')->first;  
    };
    if (!$tags) {
        $tags = '';
    }
    else {
        $tags = $tags->tree->[2]->{content};
    }    
    my $content = '';
    if ($is_free) {
        my $cont = $page->find('.article-wrap')->first;
        for my $e ($cont->find('p')->each) {
            $content = $content . "\n\n" . $e->all_text(0);
        } 
    }
    else {
        my $cont = $page->find('.wsj-snippet-body')->first;
        for my $e ($cont->find('p')->each) {
            $content = $content . "\n\n" . $e->all_text(0);
        }
    }

    return {
        author      => $author,
        content     => $content,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
