#!/usr/bin/perl -w

my %data;

my $table;
while( <ARGV> ) {
    if( /create table `(\w+)`/i ) {
	$table = $1;
	push @{$data{tables}},$table;
        $data{defn}{$table} = '<table>';
	next;
    }
    if( $table and /^\s+`(\w+)`\s+(.+),/ ) {
	my($field,$type) = ($1,$2);
	$type =~ s/(\bNOT\b|\bNULL\b|\bDEFAULT.*)//g;
	$type =~ s/\s+$//;
	#push @{$data{defn}{$table}} , '<tr><td>' . $field . '</td></td>' .  $type . '</td></tr>';
	$data{defn}{$table} .= '<tr><td>' . $field . '</td></td>' .  $type . '</td></tr>';
    }
    if( /^\)/ ) {
	$data{defn}{$table} .= '</table>';
        $table = '';
    }
}

use JSON;

print JSON->new->pretty->encode( \%data );

