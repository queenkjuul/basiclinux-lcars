
(in-package 'si)
(use-package "SLOOP")

;; Sample Usage:
;;    (si::set-up-profile 1000000) (si::prof 0 90)
;;     run program
;;    (si::display-prof)
;;    (si::clear-profile)
;;    profile can be stopped with (si::prof 0 0) and restarted with 
;;start-address will correspond to the beginning of the profile array, and
;;the scale will mean that 256 bytes of code correspond to scale bytes in the
;;profile array.
;;Thus if the profile array is 1,000,000  bytes long and the code segment is 
;;5 megabytes long you can profile the whole thing using a scale of 50
;;Note that long runs may result in overflow, and so an understating of the
;;time in a function.  With a scale of 128 it takes 6,000,000 times through 
;;a loop to overflow the sampling in one part of the code.



;(defun sort-funs (package)
;  (sloop for v in-package package with tem
;	 when (and (fboundp v) (compiled-function-p
;				(setq tem (symbol-function v))))
;	 collect (cons (function-start v) v)  into all
;	 finally (loop-return (sort all #'(lambda (x y)
;				       (< (the fixnum (car x))
;					  (the fixnum (car y))))))))
(defvar si::*profile-array*
		      (make-array 20000 :element-type 'string-char
				  :static t
				  :initial-element
				  (code-char 0)))

(defun create-profile-array (&optional (n 100000))
  (if *profile-array* (profile 0 0))
  (setq *profile-array*	      (make-array n :element-type 'string-char
				  :static t
				  :initial-element
				  (code-char 0)))
   n
  )


(defvar *current-profile* nil)

(defun pr (&optional n)
  (sloop
   with ar = si::*profile-array* declare (string ar)
   for i below (if n (min n (array-total-size ar))   (array-total-size ar))
   
   do 
   (cond ((not (= 0 i))(if (= 0 (mod i 20)) (terpri))))
   (princ (char-code (aref ar i))) (princ " "))
  (values))

(defun fprofile(fun &optional (fract 1000) offset)
  (setq *current-profile* (list  (+ (function-start (symbol-function fun))
				    (or offset 0))
				 fract))
  (apply 'profile  *current-profile* ))

;(defun foo (n) (sloop for i below n do nil))

;;problem: the counter will wrap around at 256, so that it really is not valid
;;for long runs if the functions are heavily used.  This means that
;;Remove all previous ticks from the profile array.

(defun clear-profile () (sloop  with ar = *profile-array* 
			declare (string ar)
                        for i below (array-total-size ar)
			do (setf (aref  ar i) (code-char 0))))


(defun prof-offset (addr) (* (/ (float (cadr *current-profile*)) #x10000)
			        (- addr (car *current-profile*))))

(defun prof (a b)
  (setf *current-profile* (list a b))
  (profile a b))

(defun display-prof()
   (profile 0 0)
   (apply 'display-profile *current-profile*)
   (apply 'profile *current-profile*))


(defun set-up-profile (&optional (array-size 100000)(max-funs 6000)
;			 (name "saved_kcl")(dir *system-directory*)&aux sym
			 )
;  (compiler::safe-system  (format nil "(cd ~a ; rsym ~a \"#sym\")" dir name))
;  (or (probe-file (setq sym  (format nil "~a#sym" dir))) (error "could not find ~a" sym))
;  (read-externals sym)
  (set-up-combined max-funs)
  (unless (and *profile-array*
	       (>= (array-total-size *profile-array*) array-size))
	  (print "making new array")
	  (setq *profile-array*  (make-array array-size
					     :element-type 'string-char
					     :static t
					     :initial-element
					     (code-char 0))))
  (format t "~%Loaded c and other function addresses~
   ~%Using profile-array length ~a ~
    ~%Use (si::prof 0 90) to start and (prof 0 0) to stop:~
    ~%This starts monitoring at address 0 ~
    ~%thru byte (256/90)*(length *profile-array*)~
    ~%(si::display-prof) displays the results" (length *profile-array*)))
  
