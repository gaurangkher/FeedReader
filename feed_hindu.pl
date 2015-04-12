use 5.010;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use Try::Tiny;
use Mojo::DOM;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8); 
use MongoDB;
use MongoDB::GridFS;
use HTML::HeadParser;
use IO::String;

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'test' );
my $collection = $database->get_collection( 'vaarta' );

my $xml = get("http://www.thehindu.com/news/?service=rss");
my $rp = new XML::RSS::Parser::Lite;
$rp->parse($xml);

print $rp->get('title') . " " . $rp->get('url') . " " . $rp->get('description') . "\n";

for (my $i = 0; $i < $rp->count(); $i++) {
    my $it = $rp->get($i);
    
    print "URL:" . $it->get('url') . "\n";
    my $url = $it->get('url');
    my $pd = get($url);
    my $page = Mojo::DOM->new($pd);
    my $content = $page->find('p.body')->map('text')->join("\n\n");
    $content = "$content";
    my $title =  $page->at('h1.detail-title')->text;
    my $image_url = try {$page->at('img.main-image')->tree->[2]->{src} } || undef;
   
    my $time = $page->at('div.artPubUpdate')->text;
    $time =~ s/Updated: //g;
    
    my $hp = HTML::HeadParser->new();
    $hp->parse($pd);
    my $author = $hp->header('X-Meta-author');
    my $tags = $hp->header('X-Meta-keywords');
    my $description = $hp->header('X-Meta-description');
 
    $collection->insert({
        source => q{The Hindu},
        title  => $title,
        title_id => md5_hex(encode_utf8($title)),
        author => $author,
        content => $content,
        image_url  => $image_url,
        description => $description,
        tags => $tags,
        time => $time,
    });

    if ($image_url) {
        my $img = get($image_url);
        my $story_id = md5_hex(encode_utf8($title));
        my $io = IO::String->new($img);
        $database->get_gridfs->insert($io, { filename => $story_id });
    }

}

        
