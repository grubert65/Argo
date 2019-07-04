#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Argo' ) || print "Bail out!\n";
}

diag( "Testing Argo $Argo::VERSION, Perl $], $^X" );
