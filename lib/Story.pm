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
    isa      => 'Maybe[Str]', 
); 

has description => (
    is       => 'ro', 
    isa      => 'Maybe[Str]', 
); 

has url => (
    is       => 'ro', 
    isa      => 'Maybe[Str]', 
); 

has image_url => (
    is       => 'ro', 
    isa      => 'Maybe[Str]', 
); 

sub get_id {
    my ($self) = @_;

    my $string = $self->source . encode_utf8($self->title);
    return md5_hex($string);
}


sub to_href {
    my ($self) = @_;

    return {
        source      => $self->source,
        title       => $self->title,
        story_id    => $self->get_id(),
        author      => $self->author,
        content     => $self->content,
        time        => $self->time,
        url         => $self->url,
        description => $self->description,
        image_url   => $self->image_url,
        tags        => $self->tags,
    };
}

1;
