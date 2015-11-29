package Plugin::Reuters;

use Data::Dumper;
use Moose;
use List::Flatten;
use Mojo::DOM;
use LWP::Simple;
use JSON;
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
            'http://feeds.reuters.com/reuters/INtopNews',
            'http://feeds.reuters.com/reuters/INbusinessNews',
            'http://feeds.reuters.com/reuters/INentertainmentNews',
            'http://feeds.reuters.com/reuters/worldOfSport',
        ];
    },
);

sub source_name {
    return q{Reuters};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    my $title = $story->{'title'};
    INFO qq{$url};
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

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $desc = $page->find('meta[name="description"]')->first;
    $desc    = $desc->tree->[2]->{content};

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $author = $page->find('meta[name="sailthru.author"]')->first;
    $author = $author->tree->[2]->{content};

    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $data = $page->find('script[type="application/ld+json"]')->first;
    my $json =  JSON->new->utf8->decode($data->all_text);    
    my $category = $json->{articleSection};

    my $content = $page->find('#articleText')->first;
    $content->find('span')->each(sub {$_->append_content("#*##") });
    $content = $content->all_text();
    $content =~ s/\#\*\#\#/\n\n/g;
    
    return {
        author      => $author,
        content     => $content,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
        description => $desc,
    };
}

1;
