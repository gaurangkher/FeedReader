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
    my $content = $page->find('p.body')->map('text')->join("\n\n");
    $content = "$content";
    my $try   = $page->find('meta[property="og:title"]')->first;
    my $title = $try->tree->[2]->{content};
    my $image_url =
      try { $page->at('img.main-image')->tree->[2]->{src} } || undef;

    my $category = $page->find('meta[property="article:section"]')->first;
    $category = $category->tree->[2]->{content};

    my $time = try { $page->at('div.artPubUpdate')->text; };
    $time =~ s/Updated: //g;

    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $author      = $hp->header('X-Meta-author');
    my $tags        = $hp->header('X-Meta-keywords');
    my $description = $hp->header('X-Meta-description');

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
