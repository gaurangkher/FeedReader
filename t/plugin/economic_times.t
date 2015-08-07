use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/et};

my $page = read_file($url);

use_ok('Plugin::EconomicTimes');

my $plugin = Plugin::EconomicTimes->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'category' => 'News',
        'author' => 'Nishanth Vasudevan, ET Bureau',
        'tags' => 'Tata Elxsi,stocks,Sensex,Retail investors,real estate,nifty,mutual funds,invest,Eicher Motors,Dalal Street,BSE,Britannia,Ashok Leyland',
        'image_url' => 'http://economictimes.indiatimes.com/thumb/msid-48367348,width-600,resizemode-4/growth3_bccl.jpg'
    }, 
    q{got category, author, tags, image_url}
);

done_testing();
