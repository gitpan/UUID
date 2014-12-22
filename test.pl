use Test;
BEGIN { plan tests => 6 }
use UUID;


UUID::generate( $var );
ok length $var, 16;

UUID::unparse( $var, $out );
$rc = UUID::parse( $out, $var2 );
ok $rc, 0;
ok $var, $var2;

$var = 'Peter is a moose';
$rc = UUID::parse( $var, $var2 );
ok $rc, -1;
ok $var, 'Peter is a moose';

$rc = UUID::uuid();
ok length($rc), 36;

exit 0;
