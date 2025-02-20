#
# This file is auto-generated. ***ANY*** changes here will be lost
#

package Errno;
use vars qw(@EXPORT_OK %EXPORT_TAGS @ISA $VERSION %errno $AUTOLOAD);
use Exporter ();
use Config;
use strict;

$Config{'myarchname'} eq "i686-linux" or
	die "Errno architecture (i686-linux) does not match executable architecture ($Config{'myarchname'})";

$VERSION = "1.111";
@ISA = qw(Exporter);

@EXPORT_OK = qw(ENOANO EFAULT ENOSYS ELIBACC ELIBBAD ENETDOWN
	EAFNOSUPPORT ENOEXEC EMSGSIZE EALREADY ENOENT ECHILD EDEADLK EL2HLT
	EL2NSYNC ENOTBLK EISCONN ENOLINK EIDRM EEXIST ERANGE EBADRQC EBADMSG
	ECONNABORTED ECHRNG EMULTIHOP EUSERS EDESTADDRREQ EOVERFLOW EREMCHG
	EXDEV EISNAM EBFONT ESTALE ELOOP EISDIR ELIBSCN ENAVAIL ENODEV ENOCSI
	ESHUTDOWN ECONNREFUSED ENOTTY ESOCKTNOSUPPORT ENOMEDIUM EADDRINUSE
	ENOTEMPTY ESPIPE EUNATCH E2BIG ENOMSG ENONET ENOPROTOOPT EREMOTEIO
	EREMOTE ENETUNREACH ENOTNAM EPIPE EDOTDOT ENOTUNIQ ENOTDIR ECONNRESET
	ESRMNT ENODATA EFBIG EIO EUCLEAN EADDRNOTAVAIL EINVAL EROFS EBADSLT
	EADV ELIBEXEC EILSEQ EACCES ENOTCONN EAGAIN ENAMETOOLONG ENOSPC
	EMEDIUMTYPE EHOSTUNREACH ESTRPIPE EBADE EMFILE EBADF ENOBUFS ETXTBSY
	ENFILE ETIME EPFNOSUPPORT EBADFD ENOSTR EWOULDBLOCK ENOLCK EL3RST
	EBADR EMLINK ENOMEM EINTR ELIBMAX ENXIO ENOPKG EDOM ELNRNG ENOTSOCK
	ENOSR EBUSY ERESTART EL3HLT ENETRESET EXFULL ETIMEDOUT ECOMM
	EINPROGRESS EDQUOT EPROTONOSUPPORT ESRCH EPERM EPROTO EPROTOTYPE
	EHOSTDOWN EDEADLOCK ETOOMANYREFS EOPNOTSUPP);

%EXPORT_TAGS = (
    POSIX => [qw(
	E2BIG EACCES EADDRINUSE EADDRNOTAVAIL EAFNOSUPPORT EAGAIN EALREADY
	EBADF EBUSY ECHILD ECONNABORTED ECONNREFUSED ECONNRESET EDEADLK
	EDESTADDRREQ EDOM EDQUOT EEXIST EFAULT EFBIG EHOSTDOWN EHOSTUNREACH
	EINPROGRESS EINTR EINVAL EIO EISCONN EISDIR ELOOP EMFILE EMLINK
	EMSGSIZE ENAMETOOLONG ENETDOWN ENETRESET ENETUNREACH ENFILE ENOBUFS
	ENODEV ENOENT ENOEXEC ENOLCK ENOMEM ENOPROTOOPT ENOSPC ENOSYS ENOTBLK
	ENOTCONN ENOTDIR ENOTEMPTY ENOTSOCK ENOTTY ENXIO EOPNOTSUPP EPERM
	EPFNOSUPPORT EPIPE EPROTONOSUPPORT EPROTOTYPE ERANGE EREMOTE ERESTART
	EROFS ESHUTDOWN ESOCKTNOSUPPORT ESPIPE ESRCH ESTALE ETIMEDOUT
	ETOOMANYREFS ETXTBSY EUSERS EWOULDBLOCK EXDEV
    )]
);

sub EPERM () { 1 }
sub ENOENT () { 2 }
sub ESRCH () { 3 }
sub EINTR () { 4 }
sub EIO () { 5 }
sub ENXIO () { 6 }
sub E2BIG () { 7 }
sub ENOEXEC () { 8 }
sub EBADF () { 9 }
sub ECHILD () { 10 }
sub EAGAIN () { 11 }
sub EWOULDBLOCK () { 11 }
sub ENOMEM () { 12 }
sub EACCES () { 13 }
sub EFAULT () { 14 }
sub ENOTBLK () { 15 }
sub EBUSY () { 16 }
sub EEXIST () { 17 }
sub EXDEV () { 18 }
sub ENODEV () { 19 }
sub ENOTDIR () { 20 }
sub EISDIR () { 21 }
sub EINVAL () { 22 }
sub ENFILE () { 23 }
sub EMFILE () { 24 }
sub ENOTTY () { 25 }
sub ETXTBSY () { 26 }
sub EFBIG () { 27 }
sub ENOSPC () { 28 }
sub ESPIPE () { 29 }
sub EROFS () { 30 }
sub EMLINK () { 31 }
sub EPIPE () { 32 }
sub EDOM () { 33 }
sub ERANGE () { 34 }
sub EDEADLK () { 35 }
sub EDEADLOCK () { 35 }
sub ENAMETOOLONG () { 36 }
sub ENOLCK () { 37 }
sub ENOSYS () { 38 }
sub ENOTEMPTY () { 39 }
sub ELOOP () { 40 }
sub ENOMSG () { 42 }
sub EIDRM () { 43 }
sub ECHRNG () { 44 }
sub EL2NSYNC () { 45 }
sub EL3HLT () { 46 }
sub EL3RST () { 47 }
sub ELNRNG () { 48 }
sub EUNATCH () { 49 }
sub ENOCSI () { 50 }
sub EL2HLT () { 51 }
sub EBADE () { 52 }
sub EBADR () { 53 }
sub EXFULL () { 54 }
sub ENOANO () { 55 }
sub EBADRQC () { 56 }
sub EBADSLT () { 57 }
sub EBFONT () { 59 }
sub ENOSTR () { 60 }
sub ENODATA () { 61 }
sub ETIME () { 62 }
sub ENOSR () { 63 }
sub ENONET () { 64 }
sub ENOPKG () { 65 }
sub EREMOTE () { 66 }
sub ENOLINK () { 67 }
sub EADV () { 68 }
sub ESRMNT () { 69 }
sub ECOMM () { 70 }
sub EPROTO () { 71 }
sub EMULTIHOP () { 72 }
sub EDOTDOT () { 73 }
sub EBADMSG () { 74 }
sub EOVERFLOW () { 75 }
sub ENOTUNIQ () { 76 }
sub EBADFD () { 77 }
sub EREMCHG () { 78 }
sub ELIBACC () { 79 }
sub ELIBBAD () { 80 }
sub ELIBSCN () { 81 }
sub ELIBMAX () { 82 }
sub ELIBEXEC () { 83 }
sub EILSEQ () { 84 }
sub ERESTART () { 85 }
sub ESTRPIPE () { 86 }
sub EUSERS () { 87 }
sub ENOTSOCK () { 88 }
sub EDESTADDRREQ () { 89 }
sub EMSGSIZE () { 90 }
sub EPROTOTYPE () { 91 }
sub ENOPROTOOPT () { 92 }
sub EPROTONOSUPPORT () { 93 }
sub ESOCKTNOSUPPORT () { 94 }
sub EOPNOTSUPP () { 95 }
sub EPFNOSUPPORT () { 96 }
sub EAFNOSUPPORT () { 97 }
sub EADDRINUSE () { 98 }
sub EADDRNOTAVAIL () { 99 }
sub ENETDOWN () { 100 }
sub ENETUNREACH () { 101 }
sub ENETRESET () { 102 }
sub ECONNABORTED () { 103 }
sub ECONNRESET () { 104 }
sub ENOBUFS () { 105 }
sub EISCONN () { 106 }
sub ENOTCONN () { 107 }
sub ESHUTDOWN () { 108 }
sub ETOOMANYREFS () { 109 }
sub ETIMEDOUT () { 110 }
sub ECONNREFUSED () { 111 }
sub EHOSTDOWN () { 112 }
sub EHOSTUNREACH () { 113 }
sub EALREADY () { 114 }
sub EINPROGRESS () { 115 }
sub ESTALE () { 116 }
sub EUCLEAN () { 117 }
sub ENOTNAM () { 118 }
sub ENAVAIL () { 119 }
sub EISNAM () { 120 }
sub EREMOTEIO () { 121 }
sub EDQUOT () { 122 }
sub ENOMEDIUM () { 123 }
sub EMEDIUMTYPE () { 124 }

sub TIEHASH { bless [] }

sub FETCH {
    my ($self, $errname) = @_;
    my $proto = prototype("Errno::$errname");
    if (defined($proto) && $proto eq "") {
	no strict 'refs';
        return $! == &$errname;
    }
    require Carp;
    Carp::confess("No errno $errname");
} 

sub STORE {
    require Carp;
    Carp::confess("ERRNO hash is read only!");
}

*CLEAR = \&STORE;
*DELETE = \&STORE;

sub NEXTKEY {
    my($k,$v);
    while(($k,$v) = each %Errno::) {
	my $proto = prototype("Errno::$k");
	last if (defined($proto) && $proto eq "");
	
    }
    $k
}

sub FIRSTKEY {
    my $s = scalar keys %Errno::;
    goto &NEXTKEY;
}

sub EXISTS {
    my ($self, $errname) = @_;
    my $proto = prototype($errname);
    defined($proto) && $proto eq "";
}

tie %!, __PACKAGE__;

1;
__END__

=head1 NAME

Errno - System errno constants

=head1 SYNOPSIS

    use Errno qw(EINTR EIO :POSIX);

=head1 DESCRIPTION

C<Errno> defines and conditionally exports all the error constants
defined in your system C<errno.h> include file. It has a single export
tag, C<:POSIX>, which will export all POSIX defined error numbers.

C<Errno> also makes C<%!> magic such that each element of C<%!> has a non-zero
value only if C<$!> is set to that value, eg

    use Errno;
    
    unless (open(FH, "/fangorn/spouse")) {
        if ($!{ENOENT}) {
            warn "Get a wife!\n";
        } else {
            warn "This path is barred: $!";
        } 
    } 

=head1 AUTHOR

Graham Barr <gbarr@pobox.com>

=head1 COPYRIGHT

Copyright (c) 1997-8 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

