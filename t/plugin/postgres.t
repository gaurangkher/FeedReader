use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::MockObject; 
use DBI;
use Data::Dumper;
use Plugin::Postgres;

my $dbh = DBI->connect( 'DBI:Mock:', '', '' );

my $plugin = Plugin::Postgres->new(
    dbh => $dbh,
);

my $mock = Test::MockObject->new();
$mock->mock(to_href => sub {
    return {
        source      => q{Source},  
        title       => q{This is Title},
        story_id    => 1234567890,
        author      => ['This', 'That'],
        content     => "This is content",
        url         => q{http:/url},
        description => q{desc},
        image_url   => q{http:/img},
        tags        => ['tag1', 'tag2'],
        time        => '01/01/2015 01:11::00',
    };
});


$plugin->persist([$mock]);

my @expected;
for my $st (@{ $dbh->{mock_all_history} }) {
    push @expected, {
        statement => $st->statement,
        params    => $st->bound_params,
    }
}

is_deeply(
    [ @expected ],
    [
        {
            statement => 'INSERT INTO article(id, title, description, image_url, story_url, date) VALUES (?,?,?,?,?,?)',
            params => [ 1234567890, 'This is Title', 'desc', 'http:/img', 'http:/url', '01/01/2015 01:11::00' ],
        },
        {
            statement => 'INSERT INTO author(id, name) VALUES (?, ?)',
            params =>  [ 1234567890, 'This' ],
        },
        {
            statement => 'INSERT INTO author(id, name) VALUES (?, ?)',
            params => [ 1234567890, 'That' ],
        },
        {
            statement => 'INSERT INTO metatags(id, tag) VALUES (?, ?)',
            params => [ 1234567890, 'tag1' ],
        },
        {
            statement => 'INSERT INTO metatags(id, tag) VALUES (?, ?)',
            params => [ 1234567890, 'tag2' ],
        },
        {
            statement => 'INSERT INTO content(id, content) VALUES (?, ?)',
            params => [ 1234567890, 'This is content' ],
        },
        {
            statement => 'INSERT INTO source(id, source) VALUES (?, ?)',
            params => [ 1234567890, 'Source' ],
        },
    ],
    q{got all sqls executed}
);

done_testing;