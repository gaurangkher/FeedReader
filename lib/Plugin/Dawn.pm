package Plugin::Dawn;

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
            'http://feeds.feedburner.com/dawn-news'
        ];
    },
);

sub source_name {
    return q{Dawn};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'guid'};
    INFO qq{$url};
    my $description = $story->{'description'};
    my $title = $story->{'title'};
    if ($title =~ /india/i || $description =~ /india/i ) {
    
        my $pd    = $self->get_url($url);
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
    else {
        die q{no related story};
    }
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $image_url = $page->find('meta[property="og:image"]')->last;
    $image_url = $image_url->tree->[2]->{content};

    my $author = $page->find('meta[name="author"]')->first;
    $author = $author->tree->[2]->{content};

    my $description = $page->find('meta[property="og:description"]')->first;
    $description = $description->tree->[2]->{content};

    my $category = $page->find('meta[property="article:section"]')->first;
    $category = $category->tree->[2]->{content};

    my $content = $page->find('div.story__body')->first;
    $content = $content->all_text(0);
  
    my $tags = q{pakistan, india};

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
