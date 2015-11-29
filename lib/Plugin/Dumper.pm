package Plugin::Dumper;

use Data::Dumper;
use Moose;

with 'DestRole';

has 'stories' => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { return {}; },
);

sub persist {
    my ($self, $data) = @_;

    my $id = $data->to_href()->{story_id};
    if ( !exists $self->stories->{$id}) {
        print Dumper $data->to_href()->{title};
        $self->stories->{$id} = 1;
    }
    else {
        print "Persisted\n";
    }
}

1;
