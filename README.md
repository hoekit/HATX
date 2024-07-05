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
      # [ ['journal', '1.2', 3100]
      #   ['projmgmt', '0.2', 350] ]
    ;

# METHODS

## hatx( $objref )

DESCRIPTION

    Clone the given $objref to create a 'hatx' object instance. The
    'hatx' object has an internal structure which is:

        One of: hashref | arrayref | undef

    This internal structure shall be called 'haref' in the rest of this
    document.

ARGUMENTS

    $objref - Reference to either a hash or an array

RETURNS

    An instance of the HATX object.

## to\_obj()

DESCRIPTION

    Converts the internal haref and returns it.

ARGUMENTS

    None.

RETURNS

    One of: hashref | arrayref | undef

## map( $fn, \[,@args\] )

DESCRIPTION

    Apply the given function, $fn, to each element of the internal
    haref, replacing the entire haref.

ARGUMENTS

    $fn - A user-provided function with a suitable signature.

      If internal haref is a hashref, $fn should have signature:

        $fn->($hkey_s, $hval_s [,@args]) returning ($hkey_t, $hval_t)

        WHERE
          $hkey_s   Key of source hashref pair
          $hval_s   Value of source hashref pair
          @args     Optional user variables
          $hkey_t   Key of target hashref pair
          $hval_t   Value of target hashref pair

      If the internal haref is an arrayref, $fn should have the signature:

        $fn->($val_s [,@args]) returning ($val_t)

        WHERE
          $val_s    An element of the source arrayref
          @args     Optional user variables
          $val_t    An element of the target arrayref

    @args - Optional arguments that are passed to $fn

RETURNS

    The hatx object with the target haref.

## grep( $fn \[,@args\] )

DESCRIPTION

    Retain only elements of the haref where $fn returns true.

ARGUMENTS

    $fn - A user-provided function with a suitable signature.

      If internal haref is a hashref, $fn should have signature:

        $fn->($hkey_s, $hval_s [,@args]) returning ($hkey_t, $hval_t)

        WHERE
          $hkey_s   Key of source hashref pair
          $hval_s   Value of source hashref pair
          @args     Optional user variables
          $hkey_t   Key of target hashref pair
          $hval_t   Value of target hashref pair

      If the internal haref is an arrayref, $fn should have the signature:

        $fn->($val_s [,@args]) returning ($val_t)

        WHERE
          $val_s    An element of the source arrayref
          @args     Optional user variables
          $val_t    An element of the target arrayref

    @args - Optional arguments that are passed to $fn

RETURNS

    The hatx object with elements containing only 'grepped' elements.

## sort( $fn )

DESCRIPTION

    Sorts contents of arrayref. Hashrefs are unmodified.

ARGUMENTS

    $fn - A function reference with prototype ($$) i.e. taking two
    arguments. See https://perldoc.perl.org/functions/sort.

    Examples of $fn:

      sub ($$) { $_[1] cmp $_[0] }    # Sort descending alphabetically
      sub ($$) { $_[0] <=> $_[1] }    # Sort ascending numerically
      sub ($$) { $_[1] <=> $_[0] }    # Sort descending numerically

RETURNS

    The sorted hatx object.

## to\_href( $fn \[,@args\] )

DESCRIPTION

    Convert internal arrayref to hashref using the given function, $fn,
    fn and optionally additional arguments, @args, as needed.

ARGUMENTS

    $fn - A user-provided function reference with signature:

      $fn->($val [,@args]) returning ($hkey, $hval)

      WHERE
        $val    An element of the source arrayref
        @args   Optional user variables
        $hkey   Key of target hashref pair
        $hval   Value of target hashref pair

    @args - Optional arguments that are passed to $fn

RETURNS

    The hatx object where the internal structure is a hashref.

## to\_aref( $fn \[,@args\] )

DESCRIPTION

    Convert internal hashref to arrayref using the given function, $fn
    and optionally additional arguments, @args, as needed.

ARGUMENTS

    $fn - A user-provided function reference with signature:

      $fn->($hkey, $hval [,@args]) returning ($val)

      WHERE
        $hkey   Key of source hashref pair
        $hval   Value of source hashref pair
        @args   Optional user variables
        $val    An element of the target arrayref

    @args - Optional arguments that are passed to $fn

RETURNS

    The hatx object where the internal structure is a hashref.

## apply( $fn \[,@args\] )

DESCRIPTION

    Apply the given function, $fn to each item in the haref. The haref
    is unchanged. Typically used to find aggregate values e.g. max/min or
    totals which are then stored into @args.

ARGUMENTS

    $fn - A user-provided function with a suitable signature.

      If internal haref is a hashref, $fn should have signature:

        $fn->($hkey_s, $hval_s [,@args]) with no return values

        WHERE
          $hkey_s   Key of source hashref pair
          $hval_s   Value of source hashref pair
          @args     Optional user variables

      If the internal haref is an arrayref, $fn should have the signature:

        $fn->($val_s [,@args]) with no return values

        WHERE
          $val_s    An element of the source arrayref
          @args     Optional user variables

    @args - Optional arguments that are passed to $fn

RETURNS

    The same hatx object.

# AUTHOR

Hoe Kit CHEW <hoekit@gmail.com>

# COPYRIGHT

Copyright 2024- Hoe Kit CHEW

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
