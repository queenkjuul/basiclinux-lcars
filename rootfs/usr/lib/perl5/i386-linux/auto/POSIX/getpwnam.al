# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 357 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/getpwnam.al)"
sub getpwnam {
    usage "getpwnam(name)" if @_ != 1;
    CORE::getpwnam($_[0]);
}

# end of POSIX::getpwnam
1;
