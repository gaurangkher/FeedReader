use 5.010;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use Mojo::DOM;
use Data::Dumper;

my $xml = get("http://feeds.hindustantimes.com/HT-HomePage-TopStories");
my $rp = new XML::RSS::Parser::Lite;
$rp->parse($xml);

print $rp->get('title') . " " . $rp->get('url') . " " . $rp->get('description') . "\n";

for (my $i = 0; $i < $rp->count(); $i++) {
    my $it = $rp->get($i);
    print "Title: " . $it->get('title') . "\n" . "URL:" . $it->get('url') . "\n" . "Desc:" . $it->get('description') . "\n\n";

    my $url = $it->get('url');
    #print "$url\n";
    my $pd = get($url);
    my $page = Mojo::DOM->new($pd);
    my $stream =  $page->find('p')->map('text')->join("\n");
    print "$stream\n";
}
