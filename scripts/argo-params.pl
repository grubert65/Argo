#!/usr/bin/env perl 
use strict;
use warnings;
use Data::Printer;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

use Argo;

my $c = Argo->new(port => 8080);
p $c->workflow_params("ycsb-chaos-jt8ll");
p $c->workflow_params("ycsb-chaos-jt8lldsada");



