package Plugin::TOI;

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
            #'http://timesofindia.indiatimes.com/rssfeedstopstories.cms',
            #'http://timesofindia.indiatimes.com/rssfeeds/1898055.cms',
            'http://timesofindia.indiatimes.com/rssfeeds/-2128936835.cms',
            #'http://timesofindia.indiatimes.com/rssfeeds/4719148.cms',
            #'http://timesofindia.indiatimes.com/rssfeeds/5880659.cms',
            #'http://timesofindia.indiatimes.com/rssfeeds/-2128669051.cms',
        ];
    },
);

sub source_name {
    return q{TimesOfIndia};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'guid'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $title = $story->{'title'};
    my $date  = $story->{'pubDate'};
    $date =~ s/,//g;
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        title  => $title,
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

    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};


    # After this
    my $author = $page->find('a.auth_detail')->first->all_text();

    my $category = $page->find('meta[itemprop="articleSection"]')->first;
    $category = $category->tree->[2]->{'name'};

    my $content = $page->find('div.Normal')->first;
    $content->find('br')->each(sub {$_->replace("<p>#*##</p>") });
    $content = $content->all_text();
    $content =~ s/\#\*\#\#/\n\n/g;

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
