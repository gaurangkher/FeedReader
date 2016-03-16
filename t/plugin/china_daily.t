use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/china_daily};

my $page = read_file($url);

use_ok('Plugin::ChinaDaily');

my $plugin = Plugin::ChinaDaily->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'tags' => 'Russia,China-Russia'
    },
    q{got tags}
);

done_testing();
