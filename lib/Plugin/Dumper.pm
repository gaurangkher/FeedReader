package Plugin::Dumper;

use Moose;

with 'DestRole';

sub persist {
    my ($self, $data) = @_;

    return $data->to_href();
}

1;
