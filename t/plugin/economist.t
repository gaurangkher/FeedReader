use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/economist};

my $page = read_file($url);

use_ok('Plugin::Economist');

my $plugin = Plugin::Economist->new();

my $story = $plugin->parse_page($page);

my $content = delete $story->{content};

is_deeply(
    $story,
    {
         'description' => 'The rise and fall of a corrupt coal-fuelled economy',
          'tags' => 'Shanxi province, Beijing, Industries, Energy industry, Fossil fuels, Coal mining',
          'image_url' => 'http://cdn.static-economist.com/sites/default/files/images/print-edition/20151128_CNP001_0.jpg'        
    },
    q{got description, image_url, tags}
);

done_testing();
