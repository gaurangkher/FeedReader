use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/firstpost};

my $page = read_file($url);

use_ok('Plugin::Firstpost');

my $plugin = Plugin::Firstpost->new();

print Dumper $plugin->parse_page($page);

done_testing();
