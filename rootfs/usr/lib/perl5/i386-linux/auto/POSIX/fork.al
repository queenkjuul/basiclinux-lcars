# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 822 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/fork.al)"
sub fork {
    usage "fork()" if @_ != 0;
    CORE::fork;
}

# end of POSIX::fork
1;
