use 5.010;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use Mojo::DOM;
use Data::Dumper;
use MongoDB;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8); 

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'test' );
my $collection = $database->get_collection( 'vaarta' );

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
    my $content = $page->find('div.p')->map('text')->join("\n");
    $content = "$content";
    my $auths = $page->at('.sty_author')->find('a')->map('text');
    my $author = $auths->first;
    $collection->insert({
        source => q{LiveMint},
        title  => $it->get('title'),
        title_id => md5_hex(encode_utf8($it->get('title'))),
        author => $author,
        content => $content,
    });

   
}
