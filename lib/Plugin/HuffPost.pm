package Plugin::HuffPost;

use Data::Dumper;
use Moose;
use List::Flatten;
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
            'http://www.huffingtonpost.in/feeds/index.xml'
        ];
    },
);

sub source_name {
    return q{HuffingtonPost};
}

sub parse {
    my ( $self, $story ) = @_;

    my $url = $story->{'link'};

    INFO qq{$url};
    my $pd    = $self->get_url($url);
    my $args  = $self->parse_page($pd);
    my $obj   = Story->new(
        time      => $story->{'pubDate'},
        title     => $story->{'title'},
        source    => $self->source_name(),
        url       => $url,
        %{$args}
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);
	
	my $data = $page->find('script[type="application/ld+json"]')->first;
	my $json =  JSON->new->utf8->decode($data->all_text);
	my $author = $json->{author}->{name};
    my $description = $json->{description};
	my $category = $json->{articleSection};
	my $tags = join q{, }, @{$json->{keywords}};

    my $image_url = $page->find('meta[property="og:image"]')->first;
    $image_url = $image_url->tree->[2]->{content};

    my $cont1 = '';
    my $content = $page->find('div[class^="entry__body"]')->first;
    for my $ct ($content->find('p')->each) {
        next if $ct->to_string() =~ /script type=\"text\/javascript\"/;
        my $c = $ct->all_text();
        my ($cont, @arr) = split q{\@media only screen}, $c;
        if ($cont) {
	        $cont1 = $cont1 . "\n\n" . $cont;
	    }
    }
    return {
        content     => $cont1,
        description => $description,
        tags        => $tags,
        category    => $category,
        image_url   => $image_url,
        author      => $author,
    };
}

1;
