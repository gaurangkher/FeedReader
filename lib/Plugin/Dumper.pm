package Plugin::Dumper;

use Moose;

with 'DestRole';

sub persist {
    my ($self, $data) = @_;

    for my $story (@{$data}) {
        print Dumper $story;
    }
    return;
}

1;
