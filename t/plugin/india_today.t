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
print Dumper $story;
is_deeply(
    $story,
    {
          'image_url' => 'http://media2.intoday.in/indiatoday/images/stories/amit-shah-jan18-1_305_010716074944.jpg',
          'category' => 'Archive',
          'tags' => 'Amit Shah,BJP President Amit Shah,Narendra Modi,Assembly election 2016',
          'author' => 'Uday Mahurkar',
          'description' => 'Like most Shakespearean heroes, BJP president Amit Shah, whose tenure is up for renewal this month, has a vaulting ambition. But in Shakespearean tragedies, the protagonist'
    },
    q{got tags, description, author, image_url, category}
);

done_testing();
