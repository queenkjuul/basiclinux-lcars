(in-package 'si)

;;  (load "gprof.o")
;;  You must have a kcl image with profiling information and monstartup
;;  typically saved_kcp.   NOTE: if monstartup calls sbrk (true in
;;  most 4.3bsd's except sun >= OS 4.0)  you must be very careful to
;;  allocate all the space you will use prior to calling monstartup.
;;  If subsequent storage allocation causes the hole to move you will
;;  most certainly lose.  See below for instructions
;;  on how to construct saved_kcp.

;; If you want function invocation counts to be kept do
;; (setq compiler::*cc* (concatentate 'string compiler::*cc* " -pg "))
;; before compiling the relevant files.  (This is done when you load
;; lsp/gprof.o)

;; In the image saved_kcp Load in your files.  Load in gprof.o: (load
;; "lsp/gprof.o") Invoke monstartup once to setup buffers: (monstartup
;; lowpc highpc) eg. (monstartup #x800 3000000) [highpc should be a bit
;; bigger than the highest address you have seen when loading your files]
;; Use moncontrol to toggle profiling on and off: (moncontrol 0) to turn
;; profiling off, and (moncontrol 1) to turn it on.  Use
;; (wrtie-gmons+syms) to terminate with writing a gmon.out and syms.out
;; in the current directory.   I know of no way of clearing the buffers,
;; since secret routines set up the buffers, and we don't know where they
;; are or how large.  Thus all information is cumulative.

;; % gprof syms.out
;; will display the output (add -b) to make it briefer.

;; A sample session on rascal:
#|
/usr2/skcl/unixport/saved_kcp
GCL (Austin Kyoto Common Lisp)  Version(1.147) Sun May 14 15:26:07 CDT 1989
Contains Enhancements by W. Schelter

>(load "/tmp/fo")
Loading /tmp/fo.o
start address -T 1d04e0 Finished loading /tmp/fo.o
528

>(load "/usr2/skcl/lsp/gprof")
Loading gprof.o

 Adding -pg to the *cc* commandstart address -T 1d0800 
Finished loading gprof.o
2112

;; NOTE:  If the following calls sbrk [eg 4.3bsd or sun OS3 ] but not Sun OS4,
;; then you MUST make sure to allocate sufficient memory before doing
;; monstartup, so that the hole will not have to be moved.   
>(si::monstartup #x800 2000000)
2584576

>(si::goo)(si::goo)                  ;;defined in /tmp/foo.lisp
NIL

>NIL

>(si::write-gmon+syms)
writing syms..
0
[NOTE: The safest way to exit the lisp is to stop it with Ctrl-Z
and then kill it.   We do NOT want to run the exit code which
normally writes out a monitoring file].

rascal% gprof -b syms.out
...
                                  called/total       parents 
index  %time    self descendents  called+self    name    	index
                                  called/total       children

                0.00        0.00       1/200         _call_or_link [8]
                0.02        0.02     199/200         GOO [2]
[1]     49.6    0.02        0.02     200         FOO [1]
                0.02        0.00     200/203         _make_cons [4]

...  Interpretation: Foo is called 199 times by (parent) goo and once
by (parent) call_or_link (the setting up of the fast link).  Foo
itself calls (child) make_cons 200 of the 203 times that make_cons is
called...  Lower down we would see that goo is called twice.

-- /tmp/fo.lisp --
 (defun foo () (cons nil nil))
 (defun goo () (sloop::sloop for i below 100 do (foo)))
-- end of file --

|#

;;  Creating saved_gcp
;;  
;;  cd gcl
;;  make go
;;  (cd unixport ; make gcp-sun)
;;  (cd go ; ln -s ../o/makefile ../o/*.o ../o/*.c ../o/*.d ../o/*.ini  .)
;;  remove a few .o files and do
;;  (cd go ; make  "CFLAGS = -I../h -I../gcl-tk -pg -g -c")

;;  then (cd unixport ; make kcp)

(clines
 #-aix3 "#include \"gprof.hc\""
 #+aix3 "#include \"aix_gprof.hc\""
 )

(eval-when (load)
(progn (setq compiler::*cc* (CONCATENATE 'string compiler::*cc* " -pg "))
        (format t "~% Adding -pg to the *cc* command"))
)
(defun write-gmon+syms()
  (monitor2 0 0 0 0)
  (princ "writing syms..")
  (set-up-combined)
  (write_outsyms)
  )


(defentry monstartup (int int) (int "mymonstartup"))

(defentry monitor2 (int int int int) (int "mymonitor"))

(defentry moncontrol (int) (int "moncontrol"))

(defentry write_outsyms () (int "write_outsyms"))









