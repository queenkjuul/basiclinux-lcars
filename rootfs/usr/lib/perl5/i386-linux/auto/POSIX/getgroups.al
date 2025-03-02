# NOTE: Derived from ../../lib/POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 856 "../../lib/POSIX.pm (autosplit into ../../lib/auto/POSIX/getgroups.al)"
sub getgroups {
    usage "getgroups()" if @_ != 0;
    my %seen;
    grep(!$seen{$_}++, split(' ', $) ));
}

# end of POSIX::getgroups
1;
