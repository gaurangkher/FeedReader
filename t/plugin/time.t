use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/time};

my $page = read_file($url);

use_ok('Plugin::Time');

my $plugin = Plugin::Time->new();

my $story = $plugin->parse_page($page);

my $content = delete $story->{content};

print Dumper $story;
is_deeply(
    $story,
    {
        'image_url' => 'https://timedotcom.files.wordpress.com/2015/04/471473894.jpg?quality=65&strip=color&w=594',
        'time' => '2015-04-29 02:04:13',
        'tags' => 'nepal, earthquake, kathmandu, devastation, villages, rescue, relief, india, china, sindupalchowk, nepal earthquake',
        'author' => 'Rishi Iyengar',
        'category' => 'World',
        'title' => 'Nepal Earthquake Death Toll Tops 5,000',
        'description' => 'Periodic landslides and relentless rain continue to hamper relief efforts, however.'
    
    },
    q{got image_url, time, tags, author, category, title, desc}
);


done_testing();
