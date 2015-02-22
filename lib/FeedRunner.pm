package FeedRunner;

use Carp;
use LWP::Simple;
use Class::Load ':all';
use XML::RSS::Parser::Lite;
use Moose;
use MongoDB;

with 'MooseX::Runnable';
with 'MooseX::Getopt';

has source => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has dest => (
    is       => 'ro', 
    isa      => 'Str', 
    default  => sub { return q{Mongo}},
); 

has parser => (
    is         => 'ro',
    does       => 'ParserRole',
    lazy_build => 1, 
);

has dumper => (
    is         => 'ro',
    does       => 'DestRole',
    lazy_build => 1, 
);

sub _build_parser {
    my ($self) =@_;

    my $source = q{Plugin::} . $self->source;
    load_class($source);

    return $source->new();
}

sub _build_dumper {
    my ($self) =@_;

    my $dest = q{Plugin::} . $self->dest;
    load_class($dest);

    return $dest->new();
}

sub run {
    my ($self, %args) = @_;

    my $data = $self->parser->extract();
    my $parsed_data = $self->parser->parse($data);
    $self->dumper->persist($parsed_data);
}

1;
