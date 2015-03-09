use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/hindu};

my $page = read_file($url);

use_ok('Plugin::Hindu');

my $plugin = Plugin::Hindu->new();

print Dumper $plugin->parse_page($page);

done_testing();
