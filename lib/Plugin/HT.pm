package Plugin::Hindu;

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
    return q{The Hindu};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_data;

    for my $story (@{ $stories }) {    
        
        my $url = $story->get('url');
        my $pd  = get($url);
        my $args = $self->parse_page($pd); 
        my $story = Story->new(
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
    my $content = $page->find('p.body')->map('text')->join("\n\n");
    
    $content = "$content";
    my $author = $page->at('.author')->content;
    my $title =  $page->at('h1.detail-title')->text;
    my $image_url = $page->at('img.main-image')->tree->[2]->{src};
   
    my $time = $page->at('div.artPubUpdate')->text;
    $time =~ s/Updated: //g;
    
    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $tags = $hp->header('X-Meta-keywords');
    my $description = $hp->header('X-Meta-description');
    
    return {
        title       => $title,
        time        => $time,
        author      => $author,
        content     => $content,
        description => $description,
        image_url   => $image_url,
        tags        => $tags,
    };
}
1;
