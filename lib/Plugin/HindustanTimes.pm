package Plugin::HindustanTimes;

use Data::Dumper;
use Moose;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;
use Story;
use Story;

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub { [
        'http://www.thehindu.com/?service=rss',
    ] },
);

sub source_name {
    return q{Hindustan Times};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_data;

    for my $story (@{ $stories }) {    
        
        my $url   = $story->get('url');
        my $pd    = get($url);
        my $title = $story->get('title');
        my $args  = $self->parse_page($pd); 
        my $story = Story->new(
            title   => $title,
            source  => $self->source_name(),
            url     => $url,
            %{ $args },
        );

        push @parsed_data, $story;
    }

    return \@parsed_data;
}

sub parse_page {
    my ($self, $pd) = @_;

    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $description = $hp->header('X-Meta-Description');
    my $tags = $hp->header('X-Meta-keywords');
    my $time = $hp->header('Last-Modified'); 
    print Dumper $hp;
    my ($day, @arr) = split q{ }, $time;
    $time = join q{ }, @arr;
    
    my $page = Mojo::DOM->new($pd);

    my $stream =  $page->find('p')->map('text')->join("\n");
    my $content = "$stream";
    my $pg_content = $page->at('.page_update')->content;

    my $find = $page->at('div.news_photo')->content;
    my $temp = Mojo::DOM->new($find);
    my $image_url = $temp->at('img')->tree->[2]->{src};
    
    my $dm1 =  Mojo::DOM->new($pg_content);
    my $coll = $dm1->find('b')->map('text');
    my $prob_authors =  $coll->first;
    my @aut = split q{,}, $prob_authors;
    my $author =  $aut[0];

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
