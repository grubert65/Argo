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
use Try::Tiny;

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

An HashRef

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

=head2 workflow

=head3 INPUT

    $name : the workflow name

=head3 OUTPUT

=head3 DESCRIPTION

Returns the medatata for the passed workflow name

=cut

#=============================================================
sub workflow {
    my ( $self, $name ) = @_;
    
    return undef unless $name;
    $self->rest_client->query("apis/argoproj.io/v1alpha1/namespaces/default/workflows/$name");
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

A workflow has 1 or more nodes.
A root node can be of type "Pod" or "Steps".
There is only a node of type "Steps" per workflow.
A node can have children.
A node can be of type:
- Pod : leaf node, output, can have children
- Steps: root node, children, no output
- StepGroup: group of child steps, no output

=cut

#=============================================================
sub workflows_as_tree {
    my $self = shift;

    $self->{treeList} = {};
    $self->{workflows} = $self->workflows();

    foreach my $workflow ( @{$self->{workflows}->{items}} ) {
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
        $item->{name} = $item->{id};
        if ( exists $workflow->{metadata}->{annotations} && 
             exists $workflow->{metadata}->{annotations}->{title} ) {
             $item->{name} = "[$item->{id}]: ".$workflow->{metadata}->{annotations}->{title};
         }
        $item->{type} = 'workflow';
        $self->{treeList}->{$item->{id}} = $item;

        $self->{nodes} = $workflow->{status}->{nodes};
        foreach my $key ( keys %{$self->{nodes}} ) {
            next if (( $self->{nodes}->{$key}->{type} eq 'StepGroup' ) || 
                     ( $self->{nodes}->{$key}->{type} eq 'Steps' ));
            my $node = {};
            foreach ( qw( 
                children
                finishedAt
                startedAt
                phase
                type
                id
                )) {
                $node->{$_} = $self->{nodes}->{$key}->{$_};
            }
            $node->{parent} = $item->{id};
            $node->{name} = $node->{id};

            # the node can have children...
            unless( exists $self->{treeList}->{$node->{id}} ) {
                $self->{treeList}->{$node->{id}} = $node;
            }
            $self->add_children( $node );
        }
    }
    $self->clean_tree();
    return [ values %{$self->{treeList}} ];
}

sub clean_tree {
    my $self = shift;

    foreach ( keys %{$self->{treeList}} ) {
        delete $self->{treeList}->{$_}->{children};
    }
}

sub add_children {
    my ( $self, $node ) = @_;

    return unless ( $node->{children} && scalar @{$node->{children}} ); 
    foreach my $child_id ( @{$node->{children}} ) {
        next unless ( exists $self->{nodes}->{$child_id} );
        my $child = {};
        foreach ( qw( 
            children
            finishedAt
            startedAt
            phase
            type
            id
            )) {
            $child->{$_} = $self->{nodes}->{$child_id}->{$_};
        }
        $child->{parent} = $node->{id};
        $child->{name} = $child->{id};
        $self->{treeList}->{$child_id} = $child;
        $self->add_children( $child );
    }
}

#=============================================================

=head2 workflow_params

=head3 INPUT

    $name: the workflow unique name

=head3 OUTPUT

An ArrayRef

=head3 DESCRIPTION

Tries to fetch the workflow argument parameters if any.

=cut

#=============================================================
sub workflow_params {
    my ($self, $name) = @_;

    return [] unless $name;

    try {
        my $workflow = $self->workflow( $name );
        my $params = $workflow->{spec}->{arguments}->{parameters} // [];

        # and for something completely different...a Schwartzian transform!!
        my @sorted = grep { $_->{name} !~ /password/ }
                    map  { $_->[1]                  }
                    sort { $a->[0] cmp $b->[0]      }
                    map  { [ $_->{name}, $_ ]       } @$params;
    
        return \@sorted;
    } catch {
        $self->log->error("[ERROR]: Error getting params for workflow $name: $_");
        return [];
    };
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

    try {
        $self->rest_client->q_params({
                container => 'main'
        });

        return $self->rest_client->do();
    } catch {
        $self->log->error("[ERROR]: coudn't get log for workflow $name");
        return "";
    };
}

1; 
 

