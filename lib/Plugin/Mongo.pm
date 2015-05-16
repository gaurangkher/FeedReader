package Plugin::Mongo;

use Moose;
use MongoDB;
use MongoDB::GridFS;
use LWP::Simple;

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

has img_col => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        return MongoDB::MongoClient->new(
            host => 'localhost',
            port => 27017
        )->get_database('test')->get_gridfs;
    },
);

sub persist {
    my ( $self, $data ) = @_;

    my $hash = $data->to_href();
    my @result =
      $self->collection->find( { title_id => $hash->{title_id} } )->all;
    if ( scalar @result == 0 ) {
        $self->collection->insert($hash);

        my $image_url = $hash->{image_url};

        if ($image_url) {
            $self->save_image($hash);
        }
        return 1;
    }
    return 0;
}

sub save_image {
    my ( $self, $hash ) = @_;
}

1;
