#!/usr/bin/env perl 
use strict;
use warnings;
use Data::Printer;
use YAML::Syck;

use Argo;

my $c = Argo->new(port => 8080);
my $workflows = $c->workflows();
# print Dump( $workflows );
p $workflows;
