#!/usr/bin/env perl 
use strict;
use warnings;
use Data::Printer;

use Argo;

my $c = Argo->new(port => 8080);
p $c->workflows_as_tree();

