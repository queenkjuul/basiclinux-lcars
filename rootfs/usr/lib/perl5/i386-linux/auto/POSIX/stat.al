# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 748 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/stat.al)"
sub stat {
    usage "stat(filename)" if @_ != 1;
    CORE::stat($_[0]);
}

# end of POSIX::stat
1;
