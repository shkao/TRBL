package KEGG_sk;
use strict;
use warnings;
use FindBin qw( $Bin );
use LWP::UserAgent;

# Parse KO info
my $ko_file = "$Bin/data/KO.keg";
open my $ko_fh, '<', $ko_file or die("Can't find $ko_file!\n");
chomp( my @ko_raw = <$ko_fh> );
close $ko_fh;

my %koID_2_info;
my %mapID_2_koIDs;
my $mapID = "";
for ( my $i = 0 ; $i < $#ko_raw ; $i++ ) {
    my $line = $ko_raw[$i];
    if ( $line =~ /^C/ ) {
        $mapID = $1 if ( $line =~ /^C\W+(\d+) / );
    }
    elsif ( $line =~ /^D/ ) {
        my ( $koID, $gene_products, $info, $ec ) = ( "", "", "", "" );
        $koID          = $1 if ( $line =~ /^D\W+(K\d+)\W+/ );
        $koID          = sanitize($koID);
        $gene_products = $1 if ( $line =~ /^D\W+K\d+\W+(.+?);/ );
        $gene_products = sanitize($gene_products);
        $info = $1 if ( $line =~ /^D.+;(.+)\[/ || $line =~ /^D.+;(.+)$/ );
        $info = sanitize($info);
        $ec   = $1 if ( $line =~ /\[(EC\:.+)\]$/ );
        $ec   = sanitize($ec);

        push @{ $mapID_2_koIDs{$mapID} }, $koID;
        $koID_2_info{$koID} = {
            gene_products => $gene_products,
            info          => $info,
            ec            => $ec
        };
    }
}

# Parse pathway info
my $kegg_html = "$Bin/data/pathway.html";
open( my $map_fh, '<:encoding(UTF-8)', $kegg_html )
  or die "Could not open file '$kegg_html' $!";

my @kegg_raw;
while ( my $line = <$map_fh> ) {
    chomp $line;
    push( @kegg_raw, $line );
}

my %mapID_2_info;
my @mapIDs;
my $map_category;
for ( my $i = 0 ; $i <= $#kegg_raw ; $i++ ) {
    my ( $mapID, $map_desc );

    if ( $kegg_raw[$i] =~ /^<b>/ && $kegg_raw[$i] =~ /<\/b>$/ ) {
        $map_category = $1 if ( $kegg_raw[$i] =~ /\<b\>(.+)\<\/b\>/ );
    }
    elsif ( $kegg_raw[$i] =~ /kegg-bin\/show_pathway/ ) {
        $mapID = $1 if ( $kegg_raw[$i] =~ /\<dt\>(\d+)\<\/dt\>/ );
        $map_desc = $1
          if ( $kegg_raw[$i] =~ /show_description\=show\"\>(.+)\<\/a\>/
            || $kegg_raw[$i] =~ /map\d+\"\>(.+)\<\/a\>/ );

        $mapID_2_info{$mapID} = {
            map_category => $map_category,
            map_desc     => $map_desc
        };

        push( @mapIDs, $mapID );
    }
}

sub sanitize {
    my ($str) = @_;
    $str =~ s/^\s+|\s+$//g;

    return ($str);
}

sub get_koID_info {
    my ($koID) = @_;
    my ( $gene_products, $info, $ec ) = ( "", "", "" );

    if ( defined( $koID_2_info{$koID} ) ) {
        ( $gene_products, $info, $ec ) = (
            $koID_2_info{$koID}{"gene_products"},
            $koID_2_info{$koID}{"info"},
            $koID_2_info{$koID}{"ec"}
        );
    }
    else {
        my $url =
'http://www.kegg.jp/dbget-bin/www_bfind_sub?mode=bfind&max_hit=1000&dbkey=orthology&keywords='
          . $koID;
        my $ua       = LWP::UserAgent->new;
        my $response = $ua->get($url);
        sleep("1");

        if ( $response->is_success ) {
            my $html = $response->content;
            $gene_products = $1
              if ( $html =~ /\<div style\=\"margin\-left\:2em\"\> (.+?);/ );
            $gene_products = sanitize($gene_products);
            $info          = $1
              if ( $html =~
                /\<div style\=\"margin\-left\:2em\"\> .+?;(.+?)[\<\[]/ );
            $info = sanitize($info);
            $ec   = $1 if ( $html =~ /\[(EC:.+)\]/ );
            $ec   = sanitize($ec);
        }
    }

    return $gene_products, $info, $ec;
}

sub get_all_mapIDs {
    return @mapIDs;
}

sub get_koIDs {
    my ($mapID) = @_;
    my @koIDs;
    if ( defined( $mapID_2_koIDs{$mapID} ) ) {
        @koIDs = @{ $mapID_2_koIDs{$mapID} };
    }

    return @koIDs;
}

sub get_mapID_info {
    my ($mapID) = @_;
    my ( $map_category, $map_desc ) = ( "", "" );

    if ( defined( $mapID_2_info{$mapID} ) ) {
        ( $map_category, $map_desc ) = (
            $mapID_2_info{$mapID}{"map_category"},
            $mapID_2_info{$mapID}{"map_desc"}
        );
    }

    return $map_category, $map_desc;
}

1;
