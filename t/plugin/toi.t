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
          'category' => 'Home',
          'image_url' => 'http://timesofindia.indiatimes.com/photo/47913104.cms',
          'author' => '',
          'description' => 'Maharashtra chief minister Devendra Fadnavis on Thursday said that he will initiate criminal defamation proceedings over reports that he threatened to offload with his delegation from an Air India flight to US.',
          'tags' => 'maharashtra CM,Fadnavis,Devendra Fadnavis,Civil Aviation Minister,Ashok Gajapathi Raju,Air India delays',
    },
    q{got tags, time, descrription, author, image_url, category}
);

done_testing();
