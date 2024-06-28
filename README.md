# NAME

HATX - A fluent interface for Hash and Array Transformations

# SYNOPSIS

    use HATX qw/hatx/;

    # Multiple versions of journal.html and projmgmt.html
    my $files = [
      'journal-v1.0.tar.gz  1201',
      'journal-v1.1.tar.gz  1999',
      'journal-v1.2.tar.gz  3100',
      'projmgmt-v0.1.tar.gz  250',
      'projmgmt-v0.2.tar.gz  350'
    ];

    # Declare a helper object
    my $max = { journal => '0.0', projmgmt => '0.0' };

    # hatx($obj) clones $obj; no clobbering
    my $h = hatx($files)
      # Internal object becomes equivalent to:
      # [ 'journal-v1.0.tar.gz  1201',
      #   'journal-v1.1.tar.gz  1999',
      #   'journal-v1.2.tar.gz  3100',
      #   'projmgmt-v0.1.tar.gz  250',
      #   'projmgmt-v0.2.tar.gz  350' ]

     # Extract components: file, version, bytes
     ->map(sub {
        $_[0] =~ /(journal|projmgmt)-v(.+).tar.gz\s+(\d+)/;
        return [$1, $2, $3];      # e.g. ['journal', '1.0', 1201]
      })
      # Internal object becomes equivalent to:
      # [ ['journal', '1.0', 1201]
      #   ['journal', '1.1', 1999]
      #   ['journal', '1.2', 3100]
      #   ['projmgmt', '0.1', 250]
      #   ['projmgmt', '0.2', 350] ]

    # Accumulate file count and file sizes
    ->apply(sub {
        my ($v, $res) = @_;
        $res->{count}++;
        $res->{bytes} += $v->[2];
      }, my $stats = { count => 0, bytes => 0 })
      # Internal object unchanged
      # The $stats variable becomes { count => 5, bytes => 6900 }

    # Determine the max version of each file, store into $max
    ->apply(sub {
        my ($v, $res) = @_;
        my ($file, $ver, $size) = @$v;
        if ($ver gt $res->{$file}) { $res->{$file} = $ver }
      }, $max)
      # Internal object unchanged
      # $max variable becomes { journal => '1.2', projmgmt => '0.2' }

    # Keep only the max version
    ->grep(sub {
        my ($v, $res) = @_;
        my ($file, $ver, $size) = @$v;
        return $ver eq $res->{$file};
      }, $max)
      # Internal object reduced to:
      #   ['journal', '1.2', 3100]
      #   ['projmgmt', '0.2', 350] ]
    ;

# METHODS

## map

Apply the given function to each item in the href/aref.

The given function has the following signature:

    fn($k,$v) -> ($k,$v)    # Applied to href
    fn($v)    -> ($v)       # Applied to aref

The internal href/aref IS modified.

## grep

Apply the given function to each item in the href/aref.

The given function has the following signature:

    fn->($k,$v[,@args]) -> BOOLEAN     # Applied to hashref
    fn->($v[,@args])    -> BOOLEAN     # Applied to arrayref

    WHERE
      fn     A function reference that returns a boolean value
      $k,$v  The key-value pair of a hash
      $v     An item of an array
      @args  An optional list of user variables

Items where the fn returns a True value are kept.

## to\_href

Convert internal aref to href using the given function.

    $fn->($val) -> ($key, $val)
    $fn is a FUNCTIONREF that takes a single value and returns two values

## apply

Apply the given function to each item in the href/aref. Arguments can be
provided to store results of the function application e.g. finding the
max value.

The internal href/aref is not modified.

    fn($k,$v,@args) -> ()
    fn($v,@args)    -> ()

# AUTHOR

Hoe Kit CHEW <hoekit@gmail.com>

# COPYRIGHT

Copyright 2024- Hoe Kit CHEW

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
