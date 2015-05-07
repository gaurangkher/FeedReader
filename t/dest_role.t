use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Test::More;
use Test::Moose;

my @test_data = ('A', 'B');

my @persisted_data;
{
    package Test;

    use Moose;

    with 'DestRole';

    sub persist {
        my ($self, $data) = @_;

        push @persisted_data, $data;
    }    
    1;
}

my $dest = Test->new();

does_ok($dest, 'DestRole', 'Does DestRole');


map { $dest->persist($_) } @test_data;

is_deeply(\@persisted_data, \@test_data, 'persisted test data');

done_testing;
