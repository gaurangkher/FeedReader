use v5.14;
use Moose;
use Carp;
use DBI;
use DBD::Pg;
use List::Util qw(shuffle);
use LWP::Simple;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use DateTime;
use Search::Elasticsearch;
 
Log::Log4perl->easy_init({ log_level => 'INFO' });

my $dbh = DBI->connect(
    "dbi:Pg:dbname='vartaa';host='207.181.217.150';port=5432;",
    "admin", "admin" 
);

my $e = Search::Elasticsearch->new(
    nodes => [
        '207.181.217.150:9200',
        '207.181.217.150:9200'
    ]
);

my $count = 1;
my $sth = $dbh->prepare("select id, source_id, date, author_ids, title, description from article");
$sth->execute;
while (my @arr = $sth->fetchrow_array()) {
    my ($id, $source_id, $date, $author_ids, $title, $description) = @arr;
    if (!$author_ids) {
        $author_ids = '0';
    }
    my @aut_ids = split q{,}, $author_ids;
    print "$count, $id\n";
    my $sth1;
    $sth1 = $dbh->prepare("select tags from metatags where id = '$id'");
    $sth1->execute();
    my ($t) = $sth1->fetchrow_array();
    my @tags = split q{,}, $t;

    $sth1 = $dbh->prepare("select name from source where id = '$source_id'");
    $sth1->execute();
    my ($source) = $sth1->fetchrow_array();

    my @authors;
    for my $a_id (@aut_ids) {
        $sth1 = $dbh->prepare("select name from author where id = $a_id");
        $sth1->execute();
        my ($a) = $sth1->fetchrow_array();
        push @authors, $a;
    }

    $e->index(
        index => 'vartaa',
        type  => 'article',
        id    => 1,
        body  => {
            title       => $title,
            date        => $date,
            authors     => \@authors,
            source      => $source,
            tags        => \@tags,
            description => $description,
            article_id  => $id,
        }
    );
    $count++;
}


