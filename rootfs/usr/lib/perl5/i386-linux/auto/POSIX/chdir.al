# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 788 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/chdir.al)"
sub chdir {
    usage "chdir(directory)" if @_ != 1;
    CORE::chdir($_[0]);
}

# end of POSIX::chdir
1;
