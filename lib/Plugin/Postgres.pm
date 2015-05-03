package Plugin::Postgres;

use v5.14;
use Moose;
use DBI;
use DBD::Pg;
use LWP::Simple;

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

    $self->insert(q{article}, $id, $title, $desc, $image_url, $url, $time);

    for my $a (@{ $author }) {
        $self->insert(q{author}, $id, $a);
    }
    for my $t (@{ $tags }) {
        $self->insert(q{metatags}, $id, $t);
    }
    $self->insert(q{content}, $id, $content);
    $self->insert(q{source}, $id, $source);
}

sub insert {
    my ($self, $table, @params) = @_;

    my $sth;
    if ($table eq q{article}) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO article(id, title, description, image_url, }
            . qq{story_url, date) VALUES (?,?,?,?,?,?)}
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

1;
