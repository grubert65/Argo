use strict;
use warnings;

use Test::More;
use YAML::Syck qw( LoadFile );
use Data::Printer;
use Log::Log4perl qw( :easy );
Log::Log4perl->easy_init($DEBUG);

use_ok('Argo');

ok(my $o = Argo->new(port => 8080), 'new' );
is($o->workflow_log('foo'), "", 'workflows_log' );

done_testing();


