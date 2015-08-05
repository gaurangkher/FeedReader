use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Test::More;
use Test::MockObject;
use File::Slurp;

subtest 'free' => sub {
    my $url = q{/home/gaurang/git/FeedReader/t/share/wsj1};

    my $page = read_file($url);

    use_ok('Plugin::WSJ');

    my $plugin = Plugin::WSJ->new();

    my $story = $plugin->parse_page( $page, 1 );
    my $content = delete $story->{content};

    is_deeply(
        $story,
        {
            'tags'      => '',
            'author'    => 'Nitin Gupta',
            'image_url' => 'http://si.wsj.net/public/resources/images/OB-EL646_niting_D_20090916012227.jpg',
            'category'  => 'Asia',
        },
        q{got tags, time, descrription, author, image_url, category}
    );
};

subtest 'paid' => sub {
    my $url = q{/home/gaurang/git/FeedReader/t/share/wsj2};

    my $page = read_file($url);

    use_ok('Plugin::WSJ');

    my $plugin = Plugin::WSJ->new();

    my $story = $plugin->parse_page( $page, 0 );
    my $content = delete $story->{content};

    is_deeply(
        $story,
        {
            'tags'      => 'crude oil,farzad-b,indian oil,iran sanctions,natural gas,oil field,Indiaâs Ministry of Petroleum and Natural Gas,Indian Oil,530965.BY,IN:EQIOC',
            'author'    => 'Jai Krishna',
            'image_url' => 'http://si.wsj.net/img/WSJ_Logo_black_social.gif',
            'category'  => 'World',
        },
        q{got tags, time, descrription, author, image_url, category}
    );
};

done_testing();
