use v5.14;
use Moose;
use Carp;
use DBI;
use DBD::Pg;
use LWP::Simple;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use DateTime;

Log::Log4perl->easy_init({ log_level => 'INFO' });

my $dt = DateTime->now->subtract(days => 2);
my $date = $dt->ymd;
my $dbh = DBI->connect(
    "dbi:Pg:dbname='vartaa';host='207.181.217.150';port=5432;",
    "admin", "admin" 
);

my $sth = $dbh->prepare("select id from source");
$sth->execute;
my @sources;
while (my @arr = $sth->fetchrow_array()) {
    push @sources, $arr[0];
}

for my $source (@sources) {
    INFO qq{Ranking for source $source};    
    my $sth1 = $dbh->prepare(
        "select id from article where date > '$date' and category_id not in (3,4,5,6,62,115,117) and source_id = $source order by date desc"
    );
    $sth1->execute;
    my $rank = 1;
    while (my @arr = $sth1->fetchrow_array()) {
        my ($id) = @arr;
        
        my $sth_new = $dbh->prepare("select id from ranking where id = '$id' "); 
        $sth_new->execute;
        my ($exist) = $sth_new->fetchrow_array();

        if ($exist) {
            my $sth_u = $dbh->prepare("UPDATE ranking set page_rank = $rank where id = '$id'");
            $sth_u->execute;
            INFO q{UPDATE};
        }
        else {
            my $sth_i = $dbh->prepare("INSERT INTO ranking(id, auto, admin, page_rank) VALUES ('$id', 0, 1000, $rank)");
            $sth_i->execute;
            INFO q{INSERT};
        }
        INFO qq{$id, $rank};

        $rank++;
    }
}

