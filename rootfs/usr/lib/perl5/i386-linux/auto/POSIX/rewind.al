# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 528 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/rewind.al)"
sub rewind {
    usage "rewind(filehandle)" if @_ != 1;
    CORE::seek($_[0],0,0);
}

# end of POSIX::rewind
1;
