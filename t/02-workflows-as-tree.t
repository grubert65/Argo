use strict;
use warnings;

use Test::More;
use YAML::Syck qw( LoadFile );
use Data::Printer;

use_ok('Argo');

# my $workflows = LoadFile( './data/workflows.yaml' ) or die "Error reading workflows\n";

ok(my $o = Argo->new(port => 8080), 'new' );
ok(my $tree = $o->workflows_as_tree(), 'workflows_as_tree' );

p $tree;

done_testing();


