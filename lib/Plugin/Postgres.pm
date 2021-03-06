package Plugin::Postgres;

use v5.14;
use Moose;
use Carp;
use DBI;
use DBD::Pg;
use LWP::Simple;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use Search::Elasticsearch;

with 'DestRole';

has dbh => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
    	my $dbname = $ENV{'DBNAME'};
    	my $host = $ENV{'HOST'};
    	my $uname = $ENV{'USER'};
    	my $pass = $ENV{'PASS'};
        return DBI->connect(
            "dbi:Pg:dbname='$dbname';host='$host';port=5432;",
            "$uname", "$pass" 
        );
    },
);

has es_dbh => (
    is => 'ro',
    isa => 'Object',
    lazy => 1,
    default => sub {
        return Search::Elasticsearch->new(
            nodes => [
                'db-vs.vartaa.in:9200',
                'db-vs.vartaa.in:9200'
            ]
        );
    },
);

sub persist {
    my ( $self, $data ) = @_;

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
    my $category  = $hash->{category};
    if ( $self->exists_id($id) ) {
        INFO qq{$id already persisted};
        return;
    }

    $content =~ s/^\s+//g;
 
    my ($category_id, $section_id)  = $self->category_id($category);
    my ($section) = $self->section($section_id);
    my $source_id  = $self->source_id($source);
    my $author_ids = $self->author_ids($author);

    $self->insert(
        q{article}, $id,         $title, $time,
        $source_id, $author_ids, $desc,  $image_url,
        $url,       $category_id, $section
    );

    $self->insert( q{metatags}, $id, $tags );
    $self->insert( q{content},  $id, $content );
    $self->insert( q{ranking},  $id );
    # Move out to messaging
    my @a_s = split q{,}, $author;
    my @t_s = split q{,}, $tags; 
    my $sth = $self->dbh->prepare("select title, date, description from article where id = '$id'");
    $sth->execute;
    my ($a_t,$a_d, $a_de) = $sth->fetchrow_array();
    
    $self->es_dbh->index(
        index => 'vartaa',
        type  => 'article',
        id    => $id,
        body  => {
            title       => $a_t,
            date        => $a_d,
            photo_url   => $image_url,
            authors     => \@a_s,
            source      => $source,
            tags        => \@t_s,
            description => $a_de,
            url 		=> $url,
        }
    );

   
    return;
}

sub insert {
    my ( $self, $table, @params ) = @_;

    my $sth;
    if ( $table eq q{article} ) {
        $sth = $self->dbh->prepare(
                qq{INSERT INTO article(id, title, date, source_id, author_ids, }
              . qq{description, photo_url, url, category_id, category) VALUES (?,?,?,?,?,?,?,?,?,?)}
        );
    }
    elsif ( $table eq q{content} ) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO content(id, content) VALUES (?, ?)} );
    }
    elsif ( $table eq q{ranking} ) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO ranking(id, auto, admin, page_rank, likes, dislikes)}
          . qq{ VALUES (?, 0, 1000, 1000, 0, 0)} );
    }
    elsif ( $table eq q{metatags} ) {
        $sth = $self->dbh->prepare(
            qq{INSERT INTO metatags(id, tags) VALUES (?, ?)} );
    }
    else {
        croak qq{Wrong option $table};
    }
    $sth->execute(@params);
}

sub exists_id {
    my ( $self, $id ) = @_;

    my $sth = $self->dbh->prepare("select 1 from article where id = '$id' ");
    $sth->execute;
    my @arr = $sth->fetchrow_array();

    if ( scalar @arr > 0 ) {
        return 1;
    }
    return 0;
}

sub source_id {
    my ( $self, $source ) = @_;

    my $sth =
      $self->dbh->prepare("select id from source where name = '$source'");
    $sth->execute;
    my ($id) = $sth->fetchrow_array();

    return $id if ( defined $id );

    $sth = $self->dbh->prepare("select max(id) from source");
    $sth->execute;
    ($id) = $sth->fetchrow_array();
    $sth =
      $self->dbh->prepare( qq{INSERT INTO source(id, name) VALUES (?, ?)} );
    $id++;
    $sth->execute( $id, $source );

    return $id;
}

sub section {
	my ( $self, $id ) = @_;

	my $sth = $self->dbh->prepare("select ltree2text(path) from section where id = $id");
	$sth->execute;
	my ($path) = $sth->fetchrow_array();

	return $path if ( defined $path );

	return 'NoCat';
}

sub category_id {
    my ( $self, $name ) = @_;

    my $sth =
      $self->dbh->prepare("select id, section_id from category where name = '$name'");
    $sth->execute;
    my ($id, $section) = $sth->fetchrow_array();

    return ($id, $section) if ( defined $id );

    $sth = $self->dbh->prepare("select max(id) from category");
    $sth->execute;
    ($id) = $sth->fetchrow_array();
    $sth =
      $self->dbh->prepare( qq{INSERT INTO category(id, name) VALUES (?, ?)} );
    $id++;
    $sth->execute( $id, $name );

    return ($id, 0);
}

sub author_ids {
    my ( $self, $author ) = @_;

    my @authors;
    if ( ref($author) eq q{ARRAY} ) {
        @authors = @{$author};
    }
    else {
        @authors = split q{,}, $author;
    }

    my @ids;
    for my $aut (@authors) {
        my $sth = $self->dbh->prepare(
            "select id,count from author where name = '$aut'" );
        $sth->execute;
        my ( $id, $count ) = $sth->fetchrow_array();
        if ( defined $id ) {
            $count++;
            my $sth = $self->dbh->prepare(
                "update author set count = $count where name = '$aut' " );
            $sth->execute;
            push @ids, $id;
        }
        else {
            my $sth = $self->dbh->prepare("select max(id) from author");
            $sth->execute;
            my ($id) = $sth->fetchrow_array();
            $sth = $self->dbh->prepare(
                qq{INSERT INTO author(id, name, count) VALUES (?, ?, ?)} );
            $id++;
            $sth->execute( $id, $aut, 0 );

            push @ids, $id;
        }
    }

    return join q{,}, @ids;
}

1;
