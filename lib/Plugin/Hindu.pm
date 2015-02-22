package Plugin::Hindu;

use Moose;
use Mojo::DOM;

with 'ParserRole'

sub source_name {
    return q{The Hindu};
}

sub parse {
    my ($self, $stories) = @_;

    my @parsed_;

    for my $story (@{ $stories }) {    
        
        my $url = $it->get('url');
        my $pd = get($url);
        my $page = Mojo::DOM->new($pd);
        my $content = $page->find('p.body')->map('text')->join("\n\n");
        my $content = "$content";
        my $author = $page->at('.author')->content;
        my $title =  $page->at('h1.detail-title')->text;
        push @parsed_data, {
            source  => $self->source_name(),
            title   => $title,
            id      => $self->get_id($title),
            author  => $author,
            content => $content,
            url     => $url,
        };
    }

    return \@parsed_data;
}

1;
