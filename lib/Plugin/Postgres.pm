package Plugin::Postgres;

use v5.14;
use Moose;
use DBI;
use DBD::Pg;
use LWP::Simple;
use Log::Log4perl qw(:easy);
use Data::Dumper;

with 'DestRole';

has dbh => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        return DBI->connect(
            "dbi:Pg:dbname='Vartaa';host='localhost';port=5432;", 
            "admin", "admin"
        );
    },
);

sub persist {
    my ($self, $data) = @_;

    my $hash      = $data->to_href();
    my $source    = $hash->{source};
    my $title     = $hash->{title};
    my $id        = $hash->{story_id};
    my $author    = $hash->{author};
    my $content   = $hash->{content};
    my $url       = $hash->{url};
    my $desc      = $hash->{description};
    my $image_url = $hash->{image_url};
    my $tags      = $hash->{tags};
    my $time      = $hash->{time};

    if( $self->exists_id($id) ) {
        INFO qq{$id already persisted};
        return;
    }
    $self->insert(q{article}, $id, $title, $time, $source, $desc, $image_url, $url );

    for my $a (@{ $author }) {
        $self->insert(q{author}, $id, $a);
    }
    for my $t (@{ $tags }) {
        $self->insert(q{metatags}, $id, $t);
    }
    $self->insert(q{content}, $id, $content);
}

sub insert {
    my ($self, $table, @params) = @_;

    my $sth;
    if ($table eq q{article}) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO article(id, title, date, source, }
            . qq{description, image_url, url) VALUES (?,?,?,?,?,?,?)}
        );
    }
    elsif ($table eq q{author}) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO author(id, name) VALUES (?, ?)}
        );
    }
    elsif ($table eq q{content}) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO content(id, content) VALUES (?, ?)}
        );
    }
    elsif ($table eq q{metatags}) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO metatags(id, tag) VALUES (?, ?)}
        );
    }
    else {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO source(id, source) VALUES (?, ?)}
        );
    }
    $sth->execute(@params);
}

sub exists_id {
    my ($self, $id) = @_;

    my $sth = $self->dbh->prepare("select 1 from article where id = '$id'");
    $sth->execute;
    my @arr = $sth->fetchrow_array();

    if(scalar @arr > 0) {
        return 1;
    }
    return 0;
}

1;
