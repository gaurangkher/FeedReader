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

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        tags => 'Crime, Dimapur, India, Nagaland, NewsTracker, Tarun Gogoi, VAW, ',
        time => '2015-03-07T19:26:18+05:30',
        'description' => 'In a shocking twist to the Nagaland lynching case, Assam Chief Minister Tarun Gogoi on Saturday said that \'unconfirmed medical reports\' claim the complainant in the case was not raped.',
        'author' => 'FP Staff',
   
        'image_url' => 'http://s2.firstpost.in/wp-content/uploads/2015/03/Tarun-Gogoi-PTI-July26.jpg'
    },
    q{got tags, time, descrription, author, image_url}
);

done_testing();
