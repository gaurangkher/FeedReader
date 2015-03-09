package Story;

use Moose;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);

has source => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has title => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has content => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has author => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has time => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has description => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has url => (
    is       => 'ro', 
    isa      => 'Str', 
    required => 1,
); 

has image => (
    is       => 'ro', 
    isa      => 'FileHandle', 
    required => 1,
); 

sub get_id {
    my ($self) = @_;

    my $string = $self->source . encode_utf8($self->title);
    return md5_hex($string);
}


sub to_href {
    my ($self) = @_;

    return {
        source   => $self->source,
        title    => $self->title,
        story_id => $self->get_id(),
        author   => $self->author,
        content  => $self->content,
        time     => $self->time,
        url      => $self->url,
    };
}

1;
