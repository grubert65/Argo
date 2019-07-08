use strict;
use warnings;

use Test::More;
use YAML::Syck qw( LoadFile );

use_ok('Argo::Node');

ok( my $node = Argo::Node->new({
    finishedAt     => "2019-07-05T17:40:43Z",
    id             => "chaostoolkit-76kqx",
    name           => "chaostoolkit-76kqx",
    phase          => "Failed",
    startedAt      => "2019-07-05T17:32:26Z",
}), 'new');
is( $node->{phase}, 'Failed', 'got right data back' );

my $workflows = LoadFile( './data/workflows.yaml' );

ok( my $root = Argo::Node->new( $workflows->{items}->[8]->{status} ), 'new workflow' );
ok( my $rootStep = $root->lookForSteps(), 'lookForSteps' );
is( $rootStep->{type}, 'Steps', 'got right data back' );
is( $rootStep->{displayName}, 'grafana-creation-j7gbp', 'got right data back' );

done_testing();


