use 5.010;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use Mojo::DOM;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8); 
use MongoDB;

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'test' );
my $collection = $database->get_collection( 'vaarta' );

my $xml = get("http://www.thehindu.com/news/?service=rss");
my $rp = new XML::RSS::Parser::Lite;
$rp->parse($xml);

print $rp->get('title') . " " . $rp->get('url') . " " . $rp->get('description') . "\n";

for (my $i = 0; $i < $rp->count(); $i++) {
    my $it = $rp->get($i);
    
    print "Title: " . $it->get('title') . "\n" . "URL:" . $it->get('url') . "\n" . "Desc:" . $it->get('description') . "\n\n";
    my $url = $it->get('url');
    my $pd = get($url);
    my $page = Mojo::DOM->new($pd);
    my $hp = HTML::HeadParser->new();   
    $hp->parse($pd);
    print Dumper $hp->header('X-Meta-description');
    exit;
    my $content = $page->find('p.body')->map('text')->join("\n");
    my $content = "$content";
    my $author = $page->at('.author')->content;
    my $title =  $page->at('h1.detail-title')->text;
    $collection->insert({
        source => q{The Hindu},
        title  => $title,
        title_id => md5_hex(encode_utf8($title)),
        author => $author,
        content => $content,
    });
}
