package HATX;

use strict; use warnings; use utf8; use 5.10.0;
use Exporter 'import';
use Carp;
use Clone qw/clone/;

our $VERSION = '0.0.1';
our @EXPORT_OK = qw/hatx/;

# Create from existing object without clobbering
sub from_obj {
    my ($o, $obj) = @_;

    $o->{H} = clone($obj) if ref($obj) eq 'HASH';
    $o->{A} = clone($obj) if ref($obj) eq 'ARRAY';
}

# Default constructor
sub new {
    my $class = shift;
    my $self = {H => undef, A => undef };
    bless $self, $class;

    my $obj = shift;
    $self->from_obj($obj) if defined $obj;

    return $self;
}

# Helper to quickly create a hatx object
sub hatx {
    return HATX->new(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

HATX - Hash and Array Transformation

=head1 SYNOPSIS

  use HATX qw/hatx/;

  my $files = [
    '01 journal.html',
    '02 journal(1).html',
    '03 journal(2).html',
    '04 projmgmt.html',
    '05 projmgmt(1).html',
  ];

  # Clones $files object
  hatx($files);

=head1 DESCRIPTION

HATX is

=head1 AUTHOR

Hoe Kit CHEW E<lt>hoekit@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2024- Hoe Kit CHEW

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
