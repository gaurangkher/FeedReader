package Plugin::Mongo;

use Moose;

with 'DestRole';

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

sub persist {
    my ($self, $data) = @_;

    return $self->collection->insert($data->to_href());
}

1;
