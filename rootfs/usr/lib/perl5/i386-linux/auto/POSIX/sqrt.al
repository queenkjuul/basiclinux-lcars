# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 352 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/sqrt.al)"
sub sqrt {
    usage "sqrt(x)" if @_ != 1;
    CORE::sqrt($_[0]);
}

# end of POSIX::sqrt
1;
