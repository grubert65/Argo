use strict;
use warnings;

use Test::More;
use YAML::Syck qw( LoadFile );

use_ok('Argo');

ok(my $o = Argo->new(port => 8080), 'new' );
ok(my $params = $o->workflow_params("ycsb-chaos-jt8ll"), 'workflow_params' );
is($params->[1]->{name}, 'cassandra-readconsistencylevel', 'got right data back' );

ok($params = $o->workflow_params("chaostoolkit-lkwpx"), 'workflow_params' );
is_deeply($params, [], 'got right data back' );

done_testing();


