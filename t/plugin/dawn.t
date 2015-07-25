use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/dawn};

my $page = read_file($url);

use_ok('Plugin::Dawn');

my $plugin = Plugin::Dawn->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'tags' => 'pakistan, india',
        'description' => q{There is still a lack of political will from both sides in addressing the issue of violations, say peace activists.},
        'author' => 'From the Newspaper',
        'image_url' => 'http://i.dawn.com/thumbnail/2015/07/55b2d65e46e39.jpg?r=521664048',
        'category' => 'pakistan',
    },
    q{got tags, time, descrription, author, image_url, category}
);

done_testing();
