package Plugin::Time;

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
        'http://feeds2.feedburner.com/time/world',
    ] },
);

sub source_name {
    return q{Time};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_data;

    for my $story (@{ $stories }) {    
        
        my $url = $story->get('url');
        my $pd  = $self->get_url($url);
        next if (!defined $pd);
        my $args = $self->parse_page($pd); 
        my @check =  map { lc($_) =~ /india/} split q{,}, $args->{tags};
        next if (scalar @check == 0);
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
    my $content = $page->find('p')->map('text')->join("\n\n");
    $content = "$content";
    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    my $description = $page->find('meta[name="description"]')->first;
    $description = $description->tree->[2]->{content};
 
    my $author_dom = $page->find('span.byline')->first->content;
    my $aut = Mojo::DOM->new($author_dom);
    
    my $author = $aut->find('a')->first->content; 

    my $time = $page->find('.publish-date')->first->tree->[2]->{datetime};
    my $try = $page->find('meta[property="og:title"]')->first;
    my $title = $try->tree->[2]->{content};
    my $image_url = $page->find('meta[property="og:image"]')->first->tree->[2]->{content};
    
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
