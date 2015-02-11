package ParserRole;

use Moose::Role;
use Carp;
use LWP::Simple;
use XML::RSS::Parser::Lite;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);

requires 'parse';
requires 'source_name';

has feeds => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
);

has rss_parser => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub { return new XML::RSS::Parser::Lite;},
);

sub get_id {
    my ($self, $title) = @_;

    my $string = $self->source_name() . encode_utf8($title);
    return md5_hex($string);
}

sub extract {
    my ($self) = @_;

    my @content;
    for my $feed ($self->feeds) {
        my $xml = get($feed);
        if (!defined $xml) {
            croak qq{ did not get response for feed: $feed};
        }
        my $parsed_feed = $self->rss_parser->parse($xml);
        for (my $i = 0; $i < $parsed_feed->count(); $i++) {
            push @content, $parsed_feed->get($i);
        }
    }
    return \@content;
}

1;
