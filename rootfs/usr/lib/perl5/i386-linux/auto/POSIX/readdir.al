# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 282 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/readdir.al)"
sub readdir {
    usage "readdir(dirhandle)" if @_ != 1;
    CORE::readdir($_[0]);
}

# end of POSIX::readdir
1;
