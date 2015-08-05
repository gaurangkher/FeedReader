package Plugin::Time;

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
            'http://feeds2.feedburner.com/time/world', 
            'http://feeds2.feedburner.com/timeblogs/globalspin',
        ];
    },
);

sub source_name {
    return q{Time};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};

    my $pd = $self->get_url($url);
    next if ( !defined $pd );
    my $args = $self->parse_page($pd);
    my @check = map { lc($_) =~ /india/ } split q{,}, $args->{tags};
    next if ( scalar @check == 0 );
    my $obj = Story->new(
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
    for my $e ($page->find('p')->each) {
        my $string = $e->to_string();
        next if $string =~ /script type=\"text\/javascript\"/;
        next if $string =~ /Your browser is out of date/;
        $content = $content . "\n\n" . $e->all_text(0);
    }

    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};

    my $author_dom = $page->find('span.byline')->first->content;
    my $aut        = Mojo::DOM->new($author_dom);

    my $author = $aut->find('a')->first->content;

    my $category = $page->at('.section-tag')->content;
    my $time  = $page->find('.publish-date')->first->tree->[2]->{datetime};
    my $try   = $page->find('meta[property="og:title"]')->first;
    my $title = $try->tree->[2]->{content};
    my $image_url =
      $page->find('meta[property="og:image"]')->first->tree->[2]->{content};

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
