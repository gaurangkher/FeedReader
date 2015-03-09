package ParserRole;

use Moose::Role;
use Carp;
use LWP::Simple;
use XML::RSS::Parser::Lite;
requires 'parse';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    default  => sub { [] },
);

has rss_parser => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub { return new XML::RSS::Parser::Lite;},
);

sub extract {
    my ($self) = @_;

    my @content;
    for my $feed ( @{ $self->feeds }) {
        my $xml = get($feed);
        if (!defined $xml) {
            croak qq{ did not get response for feed: $feed};
        }
        my $parsed_feed = $self->rss_parser->parse($xml);
        for (my $i = 0; $i < $self->rss_parser->count(); $i++) {
            push @content, $self->rss_parser->get($i);
        }
    }
    return \@content;
}

1;
