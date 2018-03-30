#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/lib";
use KEGG_SK;

my @mapIDs = KEGG_sk::get_all_mapIDs;

my $headers = join( "\t",
    "Map ID",
    " Map category",
    "Map description",
    "KO",
    "Product",
    "Product description",
    "EC numbers" );
print "$headers\n";

foreach my $mapID (@mapIDs) {
    my ( $map_category, $map_desc ) = ( "", "" );
    ( $map_category, $map_desc ) = KEGG_sk::get_mapID_info($mapID);
    my @koIDs = KEGG_sk::get_koIDs($mapID);

    foreach my $koID (@koIDs) {
        my ( $gene_products, $info, $ec ) = ( "", "", "" );
        ( $gene_products, $info, $ec ) = KEGG_sk::get_koID_info($koID);

        my $output = join( "\t",
            $mapID, $map_category, $map_desc, $koID, $gene_products, $info,
            $ec );
        print "$output\n";
    }
}
