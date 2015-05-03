package Plugin::IndianExpress;

use Data::Dumper;
use Moose;
use Try::Tiny;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use Story;

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub { [
        'http://indianexpress.com/print/front-page/feed/',
    ] },
);

sub source_name {
    return q{The Economist};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_data;

    for my $story (@{ $stories }) {    
        
        my $url = $story->get('url');
        print Dumper $url;
        my $pd  = $self->get_url($url);
        my $time = $story->get('pubDate');
        my $title = $story->get('title');
        my $args = $self->parse_page($pd); 
        my $story = Story->new(
            source  => $self->source_name(),
            url     => $url,
            time    => $time,
            title   => $title,
            %{ $args },
        );

        push @parsed_data, $story;
    }

    return \@parsed_data;
}

sub parse_page {
    my ($self, $pd) = @_;

    my $page = Mojo::DOM->new($pd);
    
    my $content = $page->find('div.main-body-content')->first->find('p')->map('text')->join(" ");
    $content = "$content";
    
    my $author = $page->find('div.editor')->first->find('a')->map('text')->join(", ");
    $author = "$author";
    my $tags = $page->find('meta[name="keywords"]')->first->tree->[2]->{content};
    my $description = $page->find('meta[name="description"]')->first->tree->[2]->{content};
   
    my $image_url = try {$page->find('div.story-image')->first->find('img')->first->tree->[2]->{src} };
 
    return {
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
    };
}
1;