use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/huffpost};

my $page = read_file($url);

use_ok('Plugin::HuffPost');

my $plugin = Plugin::HuffPost->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

print Dumper $story;
is_deeply(
    $story,
    {
        'category' => 'news',
        'description' => 'Everything you need to know about the new disclosure.',
        'tags' => 'Donald Trump,Drugs,healthcare,Chemistry,anxiety disorders,men\'s sexual health,propecia',
        'image_url' => 'http://o.aolcdn.com/dims5/amp:bd02ac5e735710b320d646a78f3718d0b51a20f1/t:1200,630/?url=http%3A%2F%2Fimg.huffingtonpost.com%2Fasset%2F1200_630%2F589372d81900003400e09a67.jpeg%3Fcache%3DpW73QD0f0G'
    },
    q{got tags, description, category, image_url}
);

done_testing();
