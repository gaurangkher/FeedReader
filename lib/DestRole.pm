package DestRole;

use Carp;
use Data::Dumper;
use Moose::Role;

requires 'persist';

around 'persist' => sub {
    my ($orig, $self, $parsed_data) = @_;

    for my $data (@{ $parsed_data }) {
        my $result = $self->$orig($data);
    }  
    return 1;
};

1;
