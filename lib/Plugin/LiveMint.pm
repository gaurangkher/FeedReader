package Plugin::LiveMint;

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
    return q{LiveMint};
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

    my $page = Mojo::DOM->new($pd);
    my $content = $page->find('div.p')->map('text')->join("\n");
    $content = "$content";
    my $auths = $page->at('.sty_author')->find('a')->map('text');
    my $author = $auths->first;
    my $image_url = $page->at('.sty_main_pic_sml1')->find('img')->first;
    $image_url = q{http://www.livemint.com} . $image_url->attr('src');
    
    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $tags = $hp->header('X-Meta-keywords'); 
    my $description = $hp->header('X-Meta-description'); 
    my $time = $hp->header('X-Meta-eomportal-lastUpdate');
    my ($day, @args) = split q{ }, $time;
    $time = join q{ }, @args;
    
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
