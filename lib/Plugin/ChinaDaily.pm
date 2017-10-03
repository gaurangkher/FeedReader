package Plugin::ChinaDaily;

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
            'http://www.chinadaily.com.cn/rss/world_rss.xml',
            'http://www.chinadaily.com.cn/rss/bizchina_rss.xml',
            'http://www.chinadaily.com.cn/rss/opinion_rss.xml',
#            'http://www.chinadaily.com.cn/rss/hk_rss.xml',
#            'http://www.chinadaily.com.cn/rss/lifestyle_rss.xml',
            'http://www.chinadaily.com.cn/rss/entertainment_rss.xml', 
        ];
    },
);

sub source_name {
    return q{China Daily};
}

sub parse {
    my ( $self, $story ) = @_;

    my $title    = $story->{'title'};
    my $url      = $story->{'link'};
    my $desc     = $story->{'description'};
    my $category = $story->{'category'};
    my $time     = $story->{'pubdate'};
    my $author   = $story->{AuthorName};
    $author =~ s/ and /,/g;    
    INFO qq{$url};

    my $content = $story->{content};
    my $pd1 = Mojo::DOM->new($content);
    $pd1->find('p')->each(sub {$_->append_content("#*##") });
    $content = $pd1->all_text();
    $content =~ s/\#\*\#\#/\n\n/g;

    my $image_url = '';
    try {
        $image_url = $pd1->find('img')->first;
        $image_url = $image_url->tree->[2]->{src}; 
    };
    my @check_content = lc($content) =~ /india/;
    my @check_desc = lc($desc) =~ /india/;
    next if ( scalar @check_content == 0 || scalar @check_desc == 0 );


    my $pd = $self->get_url($url);
    next if ( !defined $pd );
    my $args = $self->parse_page($pd);

    my $obj = Story->new(
        title       => $title,
        author      => $author,
        description => $desc,
        category    => $category,
        time        => $time,
        source      => $self->source_name(),
        url         => $url,
        content     => $content,
        image_url   => $image_url,
        %{$args},
    );

    return $obj;
}

sub parse_page {
    my ( $self, $pd ) = @_;

    my $page = Mojo::DOM->new($pd);
    
    my $tags = $page->find('meta[name="keywords"]')->first;
    $tags = $tags->tree->[2]->{content};

    return {
        tags => $tags,       
    };
}
1;
