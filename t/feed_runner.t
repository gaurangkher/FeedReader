use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;

use_ok('FeedRunner');

my $mock = Test::MockObject->new();
$mock->set_isa('Story');
$mock->mock('to_href' => sub { return { story => 'this'}});

my $persisted;
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
        $persisted = $data->to_href();
        return $data;
    }
    1;
}

my $fr = FeedRunner->new( source => 'Mock', dest => 'Mock' );

$fr->run();

is_deeply($persisted, { story => 'this'}, 'ran successfully');

done_testing();
