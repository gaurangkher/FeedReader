package FeedRunner;

use Carp;
use Try::Tiny;
use LWP::Simple;
use Class::Load ':all';
use XML::RSS::Parser::Lite;
use Moose;
use Data::Dumper;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init({ log_level => 'INFO' });

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

    INFO q{Start extract};
    my $stories = $self->parser->extract();

    INFO q{Got all feeds XML parsed};
    for my $story (@{ $stories}) {

        try {
            my $parsed_data = $self->parser->parse($story); 
            $self->dumper->persist($parsed_data);
        }
        catch {
            my $url = $story->{link}
                ? $story->{link}
                : $self->source . q{ : } . $story->{title};
            INFO qq{Failed : $url : $_};
        };

    }
    INFO q{Done persisting all stories};
}

1;
