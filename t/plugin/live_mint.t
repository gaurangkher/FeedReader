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

print Dumper $plugin->parse_page($page);

done_testing();
