package Plugin::IndianExpress;

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
        [
            'http://indianexpress.com/print/front-page/feed/',
            'http://indianexpress.com/section/india/feed/',
            'http://indianexpress.com/section/opinion/feed/',
            'http://indianexpress.com/section/opinion/editorials/feed/',
            'http://indianexpress.com/section/technology/feed/',
            'http://indianexpress.com/section/sports/feed/',
            'http://indianexpress.com/section/india/politics/feed/',
        ];
    },
);

sub source_name {
    return q{Indian Express};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};

    my $pd    = $self->get_url($url);
    my $time  = $story->{'pubDate'};
    my $title = $story->{'title'};
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        source => $self->source_name(),
        url    => $url,
        time   => $time,
        title  => $title,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);

    my $content = $self->get_content($page);
    my $author =
      $page->find('div.editor')->first->find('a')->map('text')->join(", ");
    $author = "$author";
    my $tags =
      $page->find('meta[name="keywords"]')->first->tree->[2]->{content};

    my $category =
      $page->find('meta[itemprop="articleSection"]')->first->tree->[2]
      ->{content};

    my $description =
      $page->find('meta[name="description"]')->first->tree->[2]->{content};

    my $image_url = try {
        $page->find('div.story-image')->first->find('img')->first->tree->[2]
          ->{src}
    };

    return {
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
        category    => $category,
    };
}

sub get_content {
    my ($self, $page) = @_;

    my $content =
      $page->find('div.main-body-content')->first->find('p')->map('text')
      ->join("\n\n");
    $content = "$content";

    my $next = try {
        $page->find('.continue')->first->find('a')->first->tree->[2]->{href}
    };
    while ( defined $next ) {

        my $pg   = $self->get_url($next);
        my $page = Mojo::DOM->new($pg);
        $next = try {
            $page->find('.continue')->first->find('a')->first->tree->[2]->{href}
        };

        my $test =
          $page->find('div.main-body-content')->first->find('p')->map('text')
          ->join("\n\n");
        $test    = "$test";
        $content = $content . $test;

    }
    return $content;
}
1;
