use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/reuters};

my $page = read_file($url);

use_ok('Plugin::Reuters');

my $plugin = Plugin::Reuters->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
        'category' => 'Finance - Business News',
        'author' => 'Reuters Editorial',
        'image_url' => 'http://s3.reutersmedia.net/resources/r/?m=02&d=20150826&t=2&i=1074789995&w=&fh=545px&fw=&ll=&pl=&sq=&r=LYNXNPEB7P156',
        'tags' => 'USA,INDIA,SOLAR,International Trade,United States,Industrial Machinery / Equipment (Legacy),US Government News,India,Renewable Energy Equipment and Services (TRBC),Asia / Pacific,Solar Power Stations,World Trade Organization,Corporate Events,Subsidies,Economic Events,Regulation,Energy (TRBC)',
        'description' => 'The World Trade Organization (WTO) has ruled against India in a dispute with the United States over its solar power programme, Indian business newspaper Mint reported on Wednesday.Mint quoted an'
    },
    q{got category, author, image_url, tags, description}
);

done_testing();
