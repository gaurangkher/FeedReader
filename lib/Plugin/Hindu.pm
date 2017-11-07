package Plugin::Hindu;

use Data::Dumper;
use Moose;
use Try::Tiny;
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
        [ 'http://www.thehindu.com/?service=rss', ];
    },
);

sub source_name {
    return q{The Hindu};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};
    my $pd = $self->get_url($url);
    next if ( !defined $pd );
    my $args = $self->parse_page($pd);
    my $obj  = Story->new(
        source => $self->source_name(),
        url    => $url,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page    = Mojo::DOM->new($pd);
    my $content = "";
    for my $e ($page->find('p.body')->each) {
        my $string = $e->to_string();
        next if $string =~ /script type=\"text\/javascript\"/;
        $content = $content . "\n" . $e->all_text(0);
    }
    my $try   = $page->find('meta[property="og:title"]')->first;
    my $title = $try->tree->[2]->{content};
    my $image_url =
      try { $page->find('meta[property="og:image"]')->first->tree->[2]->{content} } || undef;

    my $category =
    	try { $page->find('meta[property="article:section"]')->first->tree->[2]->{content} } || 'Home';

    my $time = $page->find('meta[name="publish-date"]')->first->tree->[2]->{content};

    my $author      = $page->find('meta[property="article:author"]')->first->tree->[2]->{content};
    my $tags        = $page->find('meta[name="news_keywords"]')->first->tree->[2]->{content};
    my $description = $page->find('meta[name="description"]')->first->tree->[2]->{content};

    return {
        title       => $title,
        time        => $time,
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

1;
