package Plugin::Dumper;

use Data::Dumper;
use Moose;

with 'DestRole';

sub persist {
    my ($self, $data) = @_;

    print Dumper $data->to_href();
}

1;
