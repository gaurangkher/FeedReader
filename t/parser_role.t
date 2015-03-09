use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Test::More;
use Test::Moose;

{
    package Test;

    use Moose;
    with 'ParserRole';

    
    1;
}
