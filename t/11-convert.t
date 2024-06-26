use strict; use warnings; use utf8; use 5.10.0;
use Test::More;

use lib qw[lib ../lib];
use HATX qw/hatx/;

my ($exp,$got,$msg,$tmp,$h);

{ ## Test to_href() method
$msg = 'hatx($aref)->to_href() works';
$tmp = [65,66,67];
$h = hatx($tmp)->to_href(sub { chr($_[0]), $_[0] })->to_obj();
$got = join(' ',$h->{A},$h->{B},$h->{C});
$exp = '65 66 67';
is($got, $exp, $msg);

}

done_testing;
