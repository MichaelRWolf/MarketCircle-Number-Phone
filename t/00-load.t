#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'MarketCircle::Number::Phone' ) || print "Bail out!\n";
}

diag( "Testing MarketCircle::Number::Phone $MarketCircle::Number::Phone::VERSION, Perl $], $^X" );
