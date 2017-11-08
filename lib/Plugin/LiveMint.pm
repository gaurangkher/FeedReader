package Plugin::LiveMint;

use Data::Dumper;
use Moose;
use Mojo::DOM;
use LWP::Simple;
use HTML::HeadParser;
use JSON;
use Story;
use Log::Log4perl qw(:easy);

with 'ParserRole';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub {
        [ 
            'http://www.livemint.com/rss/homepage', 
            'http://www.livemint.com/rss/companies',
            'http://www.livemint.com/rss/opinion',
            'http://www.livemint.com/rss/money',
            'http://www.livemint.com/rss/industry',
            'http://www.livemint.com/rss/economy_politics',
        ];
    },
);

sub source_name {
    return q{LiveMint};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};
    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $title = $story->{'title'};
    my $args  = $self->parse_page($pd);
    my $img   = $story->{bigimage} || "";
    if ($img =~ /blanklivemint/) {
        $img = "";
    }
    my $obj   = Story->new(
        title  => $title,
        source => $self->source_name(),
        url    => $url,
        author => $story->{author},        
        image_url => $img,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page    = Mojo::DOM->new($pd);
    my $content = '';
    for my $e ($page->find('div[class="content"]')->first->find('p')->each) {
        my $string = $e->to_string();
        next if $string =~ /script type=\"text\/javascript\"/;
        $content = $content . "\n" . $e->all_text(0);
    }
    
    my $category = $page->find('meta[property="article:section"]')->first;
    $category = $category->tree->[2]->{content};
   
   	my $description = $page->find('meta[name="description"]')->first;
   	$description = $description->tree->[2]->{content};
    my $data = $page->find('script[type="application/ld+json"]')->first;
    my $json =  JSON->new->utf8->decode($data->all_text);
	my $tags = join q{, }, @{$json->{keywords}};
	my $time = $json->{dateCreated};

    return {
        time        => $time,
        content     => $content,
        description => $description,
        tags        => $tags,
        category    => $category,
    };
}
1;
