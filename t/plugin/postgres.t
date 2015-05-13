use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::MockObject; 
use DBI;
use File::Temp qw/ tempfile tempdir /;
use Data::Dumper;
use Plugin::Postgres;
use File::Slurp;

my ($fh, $filename) = tempfile("", UNLINK => 1);

my $dbh = DBI->connect("dbi:SQLite:dbname=$filename","","");

my $fn = "$FindBin::Bin/../misc/table.txt";
print "$fn\n";
$dbh->prepare(read_file("$FindBin::Bin/../misc/table.txt"));
$dbh->execute();

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


$plugin->persist($mock);

my $result;
my $sth;
for my $table ('article', 'source', 'metatags','content','author') {

    $sth = $dbh->prepare(q{select * from article});
    $sth->execute;
    while( my @arr = $sth->fetchrow_array() ) {
        push @{ $result->{$table} }, [ @arr ];
    }

}
print Dumper $result;

done_testing;
