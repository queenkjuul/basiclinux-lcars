# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 897 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/rmdir.al)"
sub rmdir {
    usage "rmdir(directoryname)" if @_ != 1;
    CORE::rmdir($_[0]);
}

# end of POSIX::rmdir
1;
