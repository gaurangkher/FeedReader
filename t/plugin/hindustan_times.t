use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use Test::MockObject::Extends;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/ht};

my $page = read_file($url);

use_ok('Plugin::HindustanTimes');

my $plugin = Plugin::HindustanTimes->new();

my $mock = Test::MockObject::Extends->new($plugin);
$mock->mock( 'get_url', sub { return $page; } );

my $result =
  $plugin->parse( { link => 'test', title => 'title', feed => 'hello-hi' } );

is ref($result), q{Story}, 'got story obj';

my $no_content_href = $result->to_href();
my $content         = delete $no_content_href->{content};

is_deeply(
    $no_content_href,
    {
        'source'   => 'Hindustan Times',
        'time'     => '11 October 2013 06:27:01 PM',
        'story_id' => '0d29a4d63fca6eea903804b78e09aaf8',
        'tags' =>
'Nagaland chief minister TR Zeliang, home minister Y Patton, social media, Dimapur, lynch mob, mob lynches rape accused, ',
        'image_url' =>
'http://www.hindustantimes.com//images/2015/3/c352e7c3-bcea-47b6-8d66-ee62c374cfedwallpaper1.jpg',
        'description' =>
'Nagaland chief minister TR Zeliang and home minister Y Patton have blamed social media users for incitement leading to the lynching of a rape accused on March 5.',
        'url'      => 'test',
        'title'    => 'title',
        'category' => 'hi',
        'author'   => 'HT Correspondent,, Guwahati',
        'category' => 'india news',
    },
    q{got all non content href}
);

done_testing();
