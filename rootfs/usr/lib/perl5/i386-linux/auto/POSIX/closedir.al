# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 269 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/closedir.al)"
sub closedir {
    usage "closedir(dirhandle)" if @_ != 1;
    CORE::closedir($_[0]);
}

# end of POSIX::closedir
1;
