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

my $story = $plugin->parse_page($page);

delete $story->{content};
is_deeply(
    $story,
    {
        'title'    => 'India’s daughters and sons',
        'category' => 'Free For All',
        'author'   => 'Radhika Santhanam',
        'description' =>
'The state’s agitation over the film is alarming, for it doesn’t react so vehemently, so quickly, to the problem itself but is doing so to its portrayal.',
        'image_url' =>
'http://www.thehindu.com/multimedia/dynamic/02332/TH06_Quotes_Col_TH_2332575e.jpg',
        'time' => 'March 7, 2015 19:52 IST',
        'tags' =>
'Leslee Udwin, India\'s Daughter, BBC documentary, Mukesh Singh, Delhi gang-rape case,India, Delhi, crime, sexual assault & rape',

    },
    q{got title, category, author, description, time, tags, image_url}
);
done_testing();
