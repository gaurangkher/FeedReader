use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

my $url = q{/home/gaurang/git/FeedReader/t/share/fe};

my $page = read_file($url);

use_ok('Plugin::FinancialExpress');

my $plugin = Plugin::FinancialExpress->new();

my $story =  $plugin->parse_page($page);
my $content = delete $story->{content};

is_deeply(
    $story,
    {
          'image_url' => 'http://www.financialexpress.com/wp-content/uploads/2015/08/Gopal-Vittal-PTIs.jpg',
          'tags' => 'bharti airtel, airtel 4g services, airtel 4g, airtel 4g launch, reliance jio, reliance jio 4g, 4g service',
    
    },
    q{got image_url, tags}
);

done_testing();
