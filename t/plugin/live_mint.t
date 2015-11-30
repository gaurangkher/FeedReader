use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/livemint};

my $page = read_file($url);

use_ok('Plugin::LiveMint');

my $plugin = Plugin::LiveMint->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'category' => 'Politics',
        'description' => 'Move is being seen by analysts as a strategic step for the country on the global stage',
        'tags' => 'solar alliance, renewable energy, Paris, summit, climate, Africa, business opportunity',
        'time' => 'Nov 30 07:40:26 IST 2015'
    },
    q{got category, description, tags, time}
);


done_testing();
