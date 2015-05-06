package Plugin::Firstpost;

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
    default  => sub { [
        'http://www.firstpost.com/india/feed',
    ] },
);

sub source_name {
    return q{Firstpost};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_data;

    for my $story (@{ $stories }) {    
        
        my $url   = $story->get('url');
        INFO qq{$url};
        my $pd    = $self->get_url($url);
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

    my $page = Mojo::DOM->new($pd);
    my $time = $page->find('meta[property="og:updated_time"]')->first;
   
    $time = $time->tree->[2]->{content};
    
    my $content = $page->find('div.fullCont1')->first;
    $content = $content->find('p')->map('text')->join("\n");
    $content = $content->to_string;
    my $author = $page->find('span.by')->first;
    $author = $author->find('a')->map('text')->first;
    
    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $tags = $hp->header('X-Meta-news_keywords'); 
    my $description = $hp->header('X-Meta-description'); 
    
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
