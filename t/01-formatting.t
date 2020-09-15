#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Number::Phone;	     # https://metacpan.org/pod/Number::Phone
use Number::Phone::Formatter::EPP;

BEGIN {
    # use_ok( 'MarketCircle::Number::Phone' ) || print "Bail out!\n";
}

my @test_cases =
  (
   # user_input        expected           test_name
   ['+1 800 555 1212', '+1 800-555-1212', '+1 800'],
   ['(800)-555-1212', '800-555-1212',     '800'],


   ['206 555 1212',   '206-555-1212',     'NPA-NXX-XXXX'],
   ['2065551212',     '206-555-1212',     'NPANXXXXXX'],
   ['206.555.1212',   '206-555-1212',     'NPA.NXX.XXXX'],
   ['(206) 555-1212', '206-555-1212',     '(NPA) NXX-XXXX'],
   ['206-555-1212',   '206-555-1212',     'NPA-NXX-XXXX'],

   # ['411', '411', 'No area code'],
   
   # https://www.gleapconsult.com/
   # ['+45 3084 8344', '+45 3084 8344',   'DK - Global Leap - Personal formatting'],
   ['+45 3084 8344', '+45 30 84 83 44', 'DK - Global Leap - Standard formatting'],

   # https://www.westpac.com.au/contact-us/?fid=wbcheader:1812:contactus
   ['(+61 2) 9155 7700', '+61 2 9155 7700', 'Westpac Personal Customers - original'],
   ['+61 2 9155 7700'  , '+61 2 9155 7700', 'Westpac Personal Customers - cleaned'],

   # Zoom dial-in number...
   ['+1-855-552-4463', '', 'Zoom dial-in'],
   ['+1-855-552-4463,,7398 92 1407#', '', 'Zoom dial-in onetouch']
  );


plan tests => 0 + @test_cases;
diag( "Testing MarketCircle::Number::Phone $MarketCircle::Number::Phone::VERSION, Perl $], $^X" );

test_stuff();


sub test_stuff {
  TEST_CASE:
    foreach my $test_case_ptr (@test_cases) {
      my ($user_input, $expected, $test_name) = @$test_case_ptr;

      unless (defined($user_input) && defined($expected) && defined($test_name)) {
	diag 'some values are not defined';
	next TEST_CASE;
      }


      my $international_prefix_symbol = '+';
      my $default_country_code = '1'; # 1 => NANP (North American Numbering Plan

      # my $has_international_prefix_symbol = $user_input =~ /^[+]/;
      my $has_international_prefix_symbol = $user_input =~ /^\D*[$international_prefix_symbol]/;

      my $phone_number = $has_international_prefix_symbol ?
	Number::Phone->new($user_input)                   :
	Number::Phone->new($international_prefix_symbol . $default_country_code . $user_input);
      
      # next TEST_CASE unless defined $phone_number;

      my $formatter =  $has_international_prefix_symbol ?
	'NationallyPreferredIntl'                       :
        'National';
      my $got = $phone_number->format_using($formatter);

      my $ok = cmp_ok($got, 'eq', $expected, "$test_name (formatter => $formatter)");

      if (! $ok || $ENV{TEST_VERBOSE}) {
	my $dd = Data::Dumper->new( [{
				      user_input                      => $user_input,
				      type                            => [ $phone_number->type() ],
				      country_code                    => $phone_number->country_code(),
				      Raw                             => $phone_number->format_using('Raw'),
				      'E.123'                         => $phone_number->format(),
				      EPP                             => $phone_number->format_using('EPP'),
				      NationallyPreferredIntl         => $phone_number->format_using('NationallyPreferredIntl'),
				      National                        => $phone_number->format_using('National'),
				      areaname                       => ($phone_number->areaname() || undef),
				      has_international_prefix_symbol => $has_international_prefix_symbol
				     }],
				    [qw(phone_number)]
				  );
	diag($dd->Dump());
      }
    }
  }


