package DestRole;

use Carp;
use Data::Dumper;
use Moose::Role;
use Log::Log4perl qw(:easy);

requires 'persist';

around 'persist' => sub {
    my ($orig, $self, $parsed_data) = @_;

    for my $data (@{ $parsed_data }) {
        my $result = $self->$orig($data);
    }  

    INFO q{Done persisting};
    return 1;
};

1;
