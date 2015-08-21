package Plugin::Bbc;

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
            'http://feeds.bbci.co.uk/news/world/asia/india/rss.xml'
        ];
    },
);

sub source_name {
    return q{BBC};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'guid'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
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

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $author = $page->find('meta[property="og:article:author"]')->first;
    $author = $author->tree->[2]->{content};

    my $description = $page->find('meta[property="og:description"]')->first;
    $description = $description->tree->[2]->{content};

    my $category = $page->find('meta[property="og:article:section"]')->first;
    $category = $category->tree->[2]->{content};

    my $content = $page->find('.story-body__inner')->first;
    $content->at('.bbccom_slot')->remove; 
    $content->find('p')->each(sub {$_->append_content("#*##") });
    $content = $content->all_text();
    $content =~ s/\#\*\#\#/\n\n/g;
    
    my $tags = q{india};

    return {
        title       => $title,
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
