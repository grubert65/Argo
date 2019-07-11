use strict;
use warnings;

use Test::More;
use Data::Printer;

use_ok('Argo');

my $steps = [{
        finishedAt   => "2019-07-07T17:57:25Z",
        id           => "ycsb-chaos-jt8ll-2010765958",
        name         => "ycsb-chaos-jt8ll-2010765958",
        parent       => "ycsb-chaos-jt8ll-932519084",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:53:11Z",
        type         => "StepGroup"
    },{
        finishedAt   => "2019-07-09T17:56:46Z",
        id           => "ycsb-chaos-6tgbn-1902461606",
        name         => "ycsb-chaos-6tgbn-1902461606",
        parent       => "ycsb-chaos-6tgbn-3441546797",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:52:05Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:37:35Z",
        id           => "ycsb-chaos-wp5ng-628652644",
        name         => "ycsb-chaos-wp5ng-628652644",
        parent       => "ycsb-chaos-wp5ng-437566427",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:32:44Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:56:47Z",
        id           => "ycsb-chaos-6tgbn",
        name         => "[ycsb-chaos-6tgbn]: This is an awesome workflow",
        parent       => undef,
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:42:35Z",
        type         => "workflow"
    },{
        finishedAt   => "2019-07-09T17:37:36Z",
        id           => "ycsb-chaos-wp5ng-437566427",
        name         => "ycsb-chaos-wp5ng-437566427",
        parent       => "ycsb-chaos-wp5ng-1162307423",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:32:44Z",
        type         => "StepGroup"
    },{
        finishedAt   => "2019-07-07T17:53:11Z",
        id           => "ycsb-chaos-jt8ll-932519084",
        name         => "ycsb-chaos-jt8ll-932519084",
        parent       => "ycsb-chaos-jt8ll-937248605",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:49:22Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-07T17:49:21Z",
        id           => "ycsb-chaos-jt8ll-3075499422",
        name         => "ycsb-chaos-jt8ll-3075499422",
        parent       => "ycsb-chaos-jt8ll",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:44:02Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:32:44Z",
        id           => "ycsb-chaos-wp5ng-1162307423",
        name         => "ycsb-chaos-wp5ng-1162307423",
        parent       => "ycsb-chaos-wp5ng-1511775328",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:28:37Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-07T17:57:21Z",
        id           => "ycsb-chaos-jt8ll-2313839408",
        name         => "ycsb-chaos-jt8ll-2313839408",
        parent       => "ycsb-chaos-jt8ll-2010765958",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:53:11Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-05T17:45:39Z",
        id           => "chaostoolkit-lkwpx",
        name         => "chaostoolkit-lkwpx",
        parent       => undef,
        phase        => "Succeeded",
        startedAt    => "2019-07-05T17:41:32Z",
        type         => "workflow"
    },{
        finishedAt   => "2019-07-07T17:57:24Z",
        id           => "ycsb-chaos-jt8ll-3663360503",
        name         => "ycsb-chaos-jt8ll-3663360503",
        parent       => "ycsb-chaos-jt8ll-2010765958",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:53:11Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:32:44Z",
        id           => "ycsb-chaos-wp5ng-1511775328",
        name         => "ycsb-chaos-wp5ng-1511775328",
        parent       => "ycsb-chaos-wp5ng-2371154579",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:28:37Z",
        type         => "StepGroup"
    },{
        finishedAt   => "2019-07-09T17:52:05Z",
        id           => "ycsb-chaos-6tgbn-2367632086",
        name         => "ycsb-chaos-6tgbn-2367632086",
        parent       => "ycsb-chaos-6tgbn-518338325",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:47:59Z",
        type         => "StepGroup"
    },{
        finishedAt   => "2019-07-09T17:37:36Z",
        id           => "ycsb-chaos-wp5ng",
        name         => "[ycsb-chaos-wp5ng]: This is an awesome workflow",
        parent       => undef,
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:23:07Z",
        type         => "workflow"
    },{
        finishedAt   => "2019-07-09T17:56:47Z",
        id           => "ycsb-chaos-6tgbn-3441546797",
        name         => "ycsb-chaos-6tgbn-3441546797",
        parent       => "ycsb-chaos-6tgbn-3580329009",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:52:05Z",
        type         => "StepGroup"
    },{
        finishedAt   => "2019-07-09T17:52:05Z",
        id           => "ycsb-chaos-6tgbn-3580329009",
        name         => "ycsb-chaos-6tgbn-3580329009",
        parent       => "ycsb-chaos-6tgbn-2367632086",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:47:59Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:28:37Z",
        id           => "ycsb-chaos-wp5ng-2371154579",
        name         => "ycsb-chaos-wp5ng-2371154579",
        parent       => "ycsb-chaos-wp5ng",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:23:07Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-07T17:57:25Z",
        id           => "ycsb-chaos-jt8ll",
        name         => "ycsb-chaos-jt8ll",
        parent       => undef,
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:44:02Z",
        type         => "workflow"
    },{
        finishedAt   => "2019-07-09T17:37:03Z",
        id           => "ycsb-chaos-wp5ng-1900003609",
        name         => "ycsb-chaos-wp5ng-1900003609",
        parent       => "ycsb-chaos-wp5ng-437566427",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:32:44Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:47:58Z",
        id           => "ycsb-chaos-6tgbn-518338325",
        name         => "ycsb-chaos-6tgbn-518338325",
        parent       => "ycsb-chaos-6tgbn",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:42:35Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-09T17:56:20Z",
        id           => "ycsb-chaos-6tgbn-1193298387",
        name         => "ycsb-chaos-6tgbn-1193298387",
        parent       => "ycsb-chaos-6tgbn-3441546797",
        phase        => "Succeeded",
        startedAt    => "2019-07-09T17:52:05Z",
        type         => "Pod"
    },{
        finishedAt   => "2019-07-07T17:53:11Z",
        id           => "ycsb-chaos-jt8ll-937248605",
        name         => "ycsb-chaos-jt8ll-937248605",
        parent       => "ycsb-chaos-jt8ll-3075499422",
        phase        => "Succeeded",
        startedAt    => "2019-07-07T17:49:22Z",
        type         => "StepGroup"
    }
];

ok(my $o = Argo->new(port => 8080), 'new' );
ok(my $pods = $o->get_pods_of_workflow( $steps, "ycsb-chaos-wp5ng" ), "get_pods_of_workflow");
p $pods;

done_testing();


