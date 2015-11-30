package ParserRole;

use Moose::Role;
use Carp;
use Data::Dumper;
use LWP::Simple qw($ua get);
use Log::Log4perl qw(:easy);
use XML::RSS;
use Action::Retry qw(retry);

requires 'parse';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub { [] },
);

has xml_rss => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub { return XML::RSS->new(); },
);

sub extract {
    my ($self) = @_;

    my @content;
    for my $feed ( @{ $self->feeds }) {
        INFO qq{Converting to xml :  $feed};
        my $xml = $self->get_url($feed);
      
        $self->xml_rss->parse($xml);
        for my $item ( @{ $self->xml_rss->{'items'} } ) {
            $item->{feed} = $feed;
            push @content, $item;
        }
    }
    return \@content;
}

sub get_url {
    my ($self, $url) = @_;

    $ua->agent('My agent/1.0');
    my $content = retry { get($url) } strategy => q{Fibonacci};

    if (!defined $content) {
        print Dumper $url;
    }
    return $content;    
}
1;
