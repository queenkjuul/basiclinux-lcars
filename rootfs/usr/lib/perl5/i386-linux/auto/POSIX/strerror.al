# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 686 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/strerror.al)"
sub strerror {
    usage "strerror(errno)" if @_ != 1;
    local $! = $_[0];
    $! . "";
}

# end of POSIX::strerror
1;
