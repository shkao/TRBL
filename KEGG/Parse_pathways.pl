#!/usr/bin/perl

use strict;
use warnings;

my $kegg_html = 'pathway.html';
open( my $fh, '<:encoding(UTF-8)', $kegg_html )
  or die "Could not open file '$kegg_html' $!";

my @kegg_data;
while ( my $row = <$fh> ) {
    chomp $row;
    push( @kegg_data, $row );
}

my $map_category;
for ( my $i = 0 ; $i <= $#kegg_data ; $i++ ) {
    my ( $map_id, $map_desc );

    if ( $kegg_data[$i] =~ /^<b>/ && $kegg_data[$i] =~ /<\/b>$/ ) {
        $map_category = $1 if ( $kegg_data[$i] =~ /\<b\>(.+)\<\/b\>/ );
    }
    elsif ( $kegg_data[$i] =~ /kegg-bin\/show_pathway/ ) {
        $map_id = $1 if ( $kegg_data[$i] =~ /\<dt\>(\d+)\<\/dt\>/ );
        $map_desc = $1
          if ( $kegg_data[$i] =~ /show_description\=show\"\>(.+)\<\/a\>/
            || $kegg_data[$i] =~ /map\d+\"\>(.+)\<\/a\>/ );

        print "$map_category\t$map_id\t$map_desc\n";
    }
}
