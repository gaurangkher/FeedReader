use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Test::More;

{
    package Test;

    use Moose;
    with 'ParserRole';

    sub parse {
        my ($self, $args) = @_;
        return $args;
    }    
    1;
}

new_ok('Test');

done_testing();
