package DestRole;

use Carp;
use Data::Dumper;
use Moose::Role;
use Log::Log4perl qw(:easy);

requires 'persist';

1;
