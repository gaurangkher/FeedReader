use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/huffpost};

my $page = read_file($url);

use_ok('Plugin::HuffPost');

my $plugin = Plugin::HuffPost->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'tags' => 'monsoon, session, day, 4:, apologise, to, sushma, swaraj, or, face, lawsuit,, bjp, tells, rahul, gandhi, india',
        'description' => q{NEW DELHI -- A day after Rahul Gandhi described External Affairs Minister Sushma Swaraj as a "criminal" for her involvement in the Lalit Modi scandal, the central government hit back by thre},
        'category' => 'India',
        'image_url' => 'http://i.huffpost.com/gen/3224202/images/o-RAHUL-GANDHI-facebook.jpg',
    },
    q{got tags, description, category, image_url}
);

done_testing();
