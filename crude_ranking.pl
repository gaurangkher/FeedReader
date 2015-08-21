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

Log::Log4perl->easy_init({ log_level => 'INFO' });

my $dt = DateTime->now->subtract(days => 2);
my $date = $dt->ymd;
my $dbh;
if (exists $ENV{v_env} && $ENV{v_env} eq 'test') {
    $dbh = DBI->connect(
        "dbi:Pg:dbname='vartaatest';host='vartaatest.cu829urpqqax.us-west-2.rds.amazonaws.com';port=5432;",
        "vartaa_test", "Vart1AdotIn" 
   
    );
}
else {
    $dbh = DBI->connect(
        "dbi:Pg:dbname='vartaa';host='207.181.217.150';port=5432;",
        "admin", "admin" 
    );

}

my $sth = $dbh->prepare("select id from source");
$sth->execute;
my @sources;
my @array;
my $i = 1;
while (my @arr = $sth->fetchrow_array()) {
    push @sources, $arr[0];
    push @array, $i;
    $i++;
}

@array = shuffle @array;
my $total = scalar @array;
for my $source (@sources) {
    INFO qq{Ranking for source $source};    
    my $sth1 = $dbh->prepare(
        "select id from article where date >= '$date' and category_id not in (3,4,5,6,62,115,117) and source_id = $source order by date desc"
    );
    my $num = shift @array;
    $sth1->execute;
    my $rank = 1;
    while (my @arr = $sth1->fetchrow_array()) {
        my ($id) = @arr;
        my $new_rank = $rank + $num;
        my $sth_new = $dbh->prepare("select id from ranking where id = '$id' "); 
        $sth_new->execute;
        my ($exist) = $sth_new->fetchrow_array();

        if ($exist) {
            my $sth_u = $dbh->prepare("UPDATE ranking set page_rank = $new_rank where id = '$id'");
            $sth_u->execute;
            INFO q{UPDATE};
        }
        else {
            my $sth_i = $dbh->prepare("INSERT INTO ranking(id, auto, admin, page_rank, likes, dislikes) VALUES ('$id', 0, 1000, $new_rank, 0, 0)");
            $sth_i->execute;
            INFO q{INSERT};
        }
        INFO qq{$id, $new_rank, $num};

        $rank = $rank + 10 + $total;
    }
}

