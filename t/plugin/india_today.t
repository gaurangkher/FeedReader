use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/india_today};

my $page = read_file($url);

use_ok('Plugin::IndiaToday');

my $plugin = Plugin::IndiaToday->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};
is_deeply(
    $story,
    {
          'description' => 'In what could provide more fodder to the Opposition to target Prime Minister Narendra Modi and the NDA government at the Centre, former Research and Analysis Wing (R&AW) chief AS Dulat has revealed that former Prime Minister Atal Bihari Vajpayee, following the loss in 2004 general elections, had expressed his discontent over the handling of situation during 2002 Gujarat riots.',
          'tags' => 'AS Dulat,Atal Bihari Vajpayee,Gujarat riots,Karan Thapar,To The Point,India-Pakistan Agra Summit,IC-814 hijacking,Mufti Mohammad Sayeed',
          'category' => 'India',
          'image_url' => 'http://media2.intoday.in/indiatoday/images/stories/dulat--video_305-2_070215093826.jpg',
          'author' => 'IndiaToday.in'
    },
    q{got tags, description, author, image_url, category}
);

done_testing();
