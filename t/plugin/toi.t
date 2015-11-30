use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/toi};

my $page = read_file($url);

use_ok('Plugin::TOI');

my $plugin = Plugin::TOI->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

print Dumper $story;
is_deeply(
    $story,
    {
        'image_url' => 'http://timesofindia.indiatimes.com/photo/48569051.cms',
        'description' => 'Should unilateral, triple talaq be banned? An overwhelming number of Muslim women in the country think so.',
        'category' => 'News Home',
        'author' => 'Himanshi Dhawan',
        'tags' => 'oral talaq,Noorjehan Safia Niaz,NCW,Muslim women,BMMA,Bharatiya Muslim Mahila Andolan'
    },
    q{got tags, descrription, author, image_url, category}
);

done_testing();
