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
    my ($self, $data) = @_;

    $self->collection->insert($data->to_href());
    
    my $image_url = $data->to_href()->{image_url};

    if ($image_url) {
        my $img = get($image_url);
        my $story_id = $data->get_id();
        $self->img_col($img, { filename => $story_id });
    }
}

1;
