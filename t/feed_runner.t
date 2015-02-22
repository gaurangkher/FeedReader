use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::MockObject;

use_ok('FeedRunner');

my $mock = Test::MockObject->new();
$mock->set_isa('Story');
$mock->mock('to_href' => sub { return { story => 'this'}});

{
    package Plugin::Mock;

    use Moose;

    with 'ParserRole';
    with 'DestRole'; 

    sub extract {
        my ($self) = @_;

        return [ $mock ];
    }

    sub parse {
        my ($self, $content) = @_;

        return $content;
    }
    
    sub persist {
        my ($self, $data) = @_;
        
        return $data;
    }
    1;
}

my $fr = FeedRunner->new( source => 'Mock', dest => 'Mock' );

$fr->run();


done_testing();
