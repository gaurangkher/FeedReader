package Plugin::HindustanTimes;

use Data::Dumper;
use Moose;
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
            'http://feeds.hindustantimes.com/HT-HomePage-TopStories', 
            'http://feeds.hindustantimes.com/HT-Dontmiss',
            'http://feeds.hindustantimes.com/HT-India',
            'http://feeds.hindustantimes.com/HT-World',
            'http://feeds.hindustantimes.com/HT-Sport',
            'http://feeds.hindustantimes.com/HT-Analysis',
            'http://feeds.hindustantimes.com/HT-Entertainment',
        ];
    },
);

sub source_name {
    return q{Hindustan Times};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $title = $story->{'title'};
    my @args  = split q{-}, $story->{feed}; 
    my $category = $args[-1];
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        title  => $title,
        source => $self->source_name(),
        url    => $url,
        category => $category,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $description = $hp->header('X-Meta-Description');
    my $tags        = $hp->header('X-Meta-keywords');
    my $time        = $hp->header('Last-Modified');
    my ( $day, @arr ) = split q{ }, $time;
    $time = join q{ }, @arr;

    my $page = Mojo::DOM->new($pd);

    my $stream     = $page->find('p')->map('text')->join("\n\n");
    my $content    = "$stream";
    my $pg_content = $page->at('.page_update')->content;

    my $find      = $page->at('div.news_photo')->content;
    my $temp      = Mojo::DOM->new($find);
    my $image_url = $temp->at('img')->tree->[2]->{src};

    my $dm1          = Mojo::DOM->new($pg_content);
    my $coll         = $dm1->find('b')->map('text');
    my $author       = $page->at('.page_update')->find('b')->map('text')->first;
    return {
        time        => $time,
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
    };
}
1;
