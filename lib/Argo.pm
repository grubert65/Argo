package Argo;
#===============================================================================

=head1 NAME

Argo


=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

    A simple module to interact with Argo workflows. The current implementation
    does not implement a specific workflow object but rather rely on proper parsing
    of the K8s Rest API JSON response. 
    Errors have to be catched by caller.


=head1 SYNOPSIS

    use Argo;

    try {
        my $client = Argo->new(
            port => 8080,       # port k8s proxy is listening to
        );

        # get an arrayref of hashmaps representing all the workflows.
        my $workflows = $client->workflows();

        # get workflows and all child nodes 
        my $workflow_tree = $client->workflows_as_tree();



        # get the output of a workflow as text
        my $output = $client->workflow_output($node)
    
    } catch {
        die "Error interacting with Argo: $_";
    }

    Note: you should proxy connection with kubernetes with something like:

    #>kubectl proxy --port=<port proxy listens to>
    
    prior using this module.

=head1 AUTHOR

Marco Masetti, C<< <marco.masetti at softeco.it> >>


=head1 SUBROUTINES/METHODS

=cut

#===============================================================================
use Moose;
use RestAPI         ();
use Log::Log4perl;

has 'port' => ( is => 'rw', isa => 'Int' );
has 'rest_client' => (
    is => 'ro',
    isa => 'RestAPI',
    lazy => 1,
    default => sub { 
        my $self = shift;
        return RestAPI->new( 
            scheme  => 'http',
            server  => 'localhost',
            port    => $self->port) 
    }
);

has 'log' => (
    is => 'ro',
    isa => 'Log::Log4perl::Logger',
    lazy    => 1,
    default => sub { return Log::Log4perl->get_logger(__PACKAGE__) },
);


#=============================================================

=head2 workflows

=head3 INPUT

=head3 OUTPUT

An arrayref

=head3 DESCRIPTION

Returns the list of workflows found simply decoding the json response
of the /workflows request.

=cut

#=============================================================
sub workflows {
    my $self = shift;

    $self->rest_client->query('apis/argoproj.io/v1alpha1/namespaces/default/workflows');
    return $self->rest_client->do();
}

#=============================================================

=head2 workflows_as_list

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Returns an arrayref of workflows, for each just reporting the following keys:

  name         => $_->{metadata}->{name}
  completed    => $_->{metadata}->{labels}->{workflows.argoproj.io/completed}
  status       => $_->{metadata}->{labels}->{workflows.argoproj.io/phase}
  message      => $_->{status}->{message} || “”
  startedAt    => $_->{status}->{startedAt}
  finishedAt   => $_->{status}->{finishedAt}


=cut

#=============================================================
sub workflows_as_list {
    my $self = shift;

    my @list;

    my $workflows = $self->workflows();
    push @list, {
        name       => $_->{metadata}->{name},
        completed  => $_->{metadata}->{labels}->{"workflows.argoproj.io/completed"},
        status     => $_->{metadata}->{labels}->{"workflows.argoproj.io/phase"},
        message    => $_->{status}->{message} || "",
        startedAt  => $_->{status}->{startedAt},
        finishedAt => $_->{status}->{finishedAt},
    } foreach ( @{$workflows->{items}} );

    return \@list;
}

#=============================================================

=head2 workflows_as_tree

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION


Returns a chained list of workflows. 
Each workflow has at least one node.

A workflow has 1 or more nodes ($w->{status}->{nodes})
A root node can be of type "Pod" or "Steps".
There is only a node of type "Steps" per workflow.
A node can have children.
A node can be of type:
- Pod : leaf node, output, can have children
- Steps: root node, children, no output
- StepGroup: group of child steps, no output

Logic:

- a node has the following data model:
    - id
    - parent_id
    - startedAt 
    - finishedAt
    - phase (status)
    - children => an arrayref of children nodes children, sorted by start time

The method returns a chained list of Argo::Node objects.

Algorithm:

  - for each workflow:
    - $root = get new Argo::Node obj ( $_->{status} )
    - if scalar keys == 1:
        - $root->add_child( $root->{nodes}->{$keys[0]} )
        - next
    }
    $steps = $root->lookForSteps()
    $root->add_child ( $steps );
    }
    - add $root to list of workflows


    add_child( $self, $node ) {
    # if node is a Pod, $self = add it to self
    # if node has children
    #       add_child( $self, $_ ) foreach ( $self->{children} );

=cut

#=============================================================
# sub workflows_as_tree {
#     my $self = shift;
# 
#     my $treeList = [];
#     my $workflows = $self->workflows();
# 
#     foreach my $workflow ( @$workflows ) {
#         my $root = Argo::Node->new( $workflow->{status} );
#         my @keys = keys %{$root->{nodes}};
#         if ( scalar @keys == 1 ) {
#             $root->add_child( $root->{nodes}->{$keys[0]} );
#             push @$treeList, $root;
#             next;
#         }
#         my $steps = $root->lookForSteps();
#         $root->add_child( $steps );
#         push @$treeList, $root;
#     }
#     return $treeList;
# }

sub workflows_as_tree {
    my $self = shift;

    my $treeList = {};
    my $workflows = $self->workflows();

    foreach my $workflow ( @{$workflows->{items}} ) {
        my $item = {};
        foreach ( qw( 
            finishedAt
            startedAt
            phase
            )) {
            $item->{$_} = $workflow->{status}->{$_};
        }
        $item->{parent} = undef;
        $item->{id} = $workflow->{metadata}->{name};
        $item->{type} = 'workflow';
        $treeList->{$item->{id}} = $item;

        my $nodes = $workflow->{status}->{nodes};
        foreach my $key ( keys %$nodes ) {
            my $node = {};
            foreach ( qw( 
                children
                finishedAt
                startedAt
                phase
                type
                id
                )) {
                $node->{$_} = $workflow->{status}->{nodes}->{$key}->{$_};
            }
            $node->{parent} = $item->{id};
            unless( exists $treeList->{$node->{id}} ) {
                $treeList->{$node->{id}} = $node;
            }
        }
    }
    # and now revisit all tree to fix children...
    foreach ( keys %$treeList ) {
        if ( ( $treeList->{$_}->{type} eq 'StepGroup' )||
             ( $treeList->{$_}->{type} eq 'Steps' ) ) {
             delete $treeList->{$_};
         }
    }
    return $treeList;
}

#=============================================================

=head2 workflow_params

=head3 INPUT

    $name: the workflow unique name

=head3 OUTPUT

=head3 DESCRIPTION

Tries to fetch the main workflow container metadata and extract the following 
information:
- image: the container image
- command: the command that has been run on the container
- args: a list of printable args split by the space char, this could be an example:


    ['cp',
    '/keys/id_rsa'
    '~/.ssh/' 
    '\u0026\u0026 
    chmod 
    600 
    ~/.ssh/id_rsa 
    \u0026\u0026 
    /app/ycsb-0.15.0/bin/ycsb.sh 
    load 
    cassandra-cql 
    -P 
    /app/ycsb-0.15.0/workloads/workloada 
    -target 
    100000 
    -threads 
    1 
    -p 
    exporter=com.yahoo.ycsb.measurements.exporter.JSONMeasurementsExporter 
    -p 
    hosts=\"cassandra-disruptive-0,cassandra-disruptive-1,cassandra-disruptive-2,cassandra-disruptive-3,cassandra-disruptive-4,cassandra-disruptive-5,cassandra-disruptive-6,cassandra-disruptive-7,cassandra-disruptive-8,cassandra-disruptive-9,cassandra-disruptive-10,cassandra-disruptive-11\" 
    -p 
    port=9042 
    -p 
    maxexecutiontime=600 
    -p 
    operationcount=100000 
    -p 
    readallfields=true 
    -p 
    recordcount=100000 
    -p 
    requestdistribution=uniform 
    -p 
    cassandra.keyspace=ycsb 
    -p 
    cassandra.username=cassandra 
    -p 
    cassandra.password=cassandra 
    -p 
    cassandra.readconsistencylevel=QUORUM 
    -p 
    cassandra.writeconsistencylevel=QUORUM 
    2\u003e 
    /dev/null"


=cut

#=============================================================
sub workflow_params {
    my ($self, $name) = @_;

    return undef unless $name;
}



#=============================================================

=head2 workflow_log

=head3 INPUT

    $name: the workflow name

=head3 OUTPUT

=head3 DESCRIPTION

Tries to fetch the output log for the passed workflow.

=cut

#=============================================================
sub workflow_log {
    my ( $self, $name ) = @_;

    return undef unless $name;

    $self->log->debug("Get log for workflow $name");

    $self->rest_client->query(
        "api/v1/namespaces/default/pods/$name/log"
    );

    $self->rest_client->q_params({
            container => 'main'
    });

    return $self->rest_client->do();
}

1; 
 

