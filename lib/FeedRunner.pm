package FeedParser;

use Carp;
use LWP::Simple;
use Class::Load ':all';
use XML::RSS::Parser::Lite;
use Moose::Role;
use MongoDB;

with 'MooseX::Runnable';
with 'MooseX::Getopt';

has source => (
    is => 'ro', 
    isa => 'Str', 
    required => 1;
); 

has parser => (
    is         => 'ro',
    does       => 'Parser',
    lazy_build => 1, 
);

has collection => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        return MongoDB::MongoClient->new(
            host => 'localhost', 
            port => 27017
        )->get_database('test')->get_collection('vaarta');
    },
);

sub _build_parser {
    my ($self) =@_;

    load_class(q{Parser::} . $self->source);

    return $self->source->new();
}

sub load {
    my ($self, $parsed_data) = @_;

    for my $data (@{$parsed_data}) {
        $collection->insert({
            source   => $data->{source},
            title    => $data->{title},
            story_id => $data->{story_id},
            author   => $data->{author},
            content  => $data->{content},
            time     => $data->{time},
            tags     => $data->{tags},
        });
    }
}

sub run {
    my ($self, %args) = @_;

    my $data = $self->parser->extract();
    my $parsed_data = $self->parser->parse($data);
    $self->load($parsed_data);
}

1;
