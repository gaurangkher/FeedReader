use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/qz};

my $page = read_file($url);

use_ok('Plugin::QZ');

my $plugin = Plugin::QZ->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

print Dumper $story;
is_deeply(
    $story,
    {
        'tags' => 'billiondollar industry, boring job, Business, capabilities, childrens education, company incentives, customer, decision, edutech, education',
        'image_url' => 'https://qzprod.files.wordpress.com/2015/12/startup-fail.jpg?quality=80&strip=all&w=1600',
        'description' => 'I thought I would make millions of dollars through my startup, but I failed miserably. I had read amazing stories of startups like Flipkart and Zomato, but nobody told me that 90% of new companies fail within two years of taking their initial steps. I failed in my first year. I sometimes feel cheated, but...',
        'category' => 'india'
    },
    q{got tags, descrription, image_url, category}
);

done_testing();
