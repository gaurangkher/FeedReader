use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/bbc};

my $page = read_file($url);

use_ok('Plugin::Bbc');

my $plugin = Plugin::Bbc->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        tags => 'india',
        'description' => q{India's business leaders pledge 4,500tn rupees (over $70bn) to the "digital India" initiative.},
        'author' => 'BBC News',
        'image_url' => 'http://ichef.bbci.co.uk/news/1024/cpsprodpb/124C5/production/_83994947_83994943.jpg',
        'category' => 'India',
        'title' => 'Digital India: Business leaders pledge $70bn - BBC News',
    },
    q{got tags, time, descrription, author, image_url, category}
);

done_testing();
