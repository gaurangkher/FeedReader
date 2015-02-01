use 5.010;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use Mojo::DOM;
use Data::Dumper;

my $xml = get("http://www.livemint.com/rss/homepage");
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
    say $page->find('div.p')->map('text')->join("\n");
    #exit;    
}
