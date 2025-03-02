;;; python-mode.el --- Major mode for editing Python programs

;; Copyright (C) 1992,1993,1994  Tim Peters

;; Author: 1995-1998 Barry A. Warsaw
;;         1992-1994 Tim Peters
;; Maintainer: python-mode@python.org
;; Created:    Feb 1992
;; Keywords:   python languages oop

(defconst py-version "$Revision: 3.57 $"
  "`python-mode' version number.")

;; This software is provided as-is, without express or implied
;; warranty.  Permission to use, copy, modify, distribute or sell this
;; software, without fee, for any purpose and by any individual or
;; organization, is hereby granted, provided that the above copyright
;; notice and this paragraph appear in all copies.

;;; Commentary:

;; This is a major mode for editing Python programs.  It was developed
;; by Tim Peters after an original idea by Michael A. Guravage.  Tim
;; subsequently left the net; in 1995, Barry Warsaw inherited the
;; mode and is the current maintainer.

;; COMPATIBILITY:

;; This version of python-mode.el is no longer compatible with Emacs
;; 18.  For a gabazillion reasons, I highly recommend upgrading to
;; X/Emacs 19 or X/Emacs 20.  I recommend at least Emacs 19.34 or
;; XEmacs 19.15.  Any of the v20 X/Emacsen should be fine.

;; NOTE TO FSF EMACS USERS:

;; You may need to acquire the Custom library -- this applies to users
;; of Emacs 19.34 and NTEmacs based on 19.34, but not to Emacs 20
;; users.  You must also byte-compile this file before use -- this
;; applies to FSF's Emacs 19.34, 20.x, and NTEmacs based on 19.34.
;; None of this applies to XEmacs (although byte compilation is still
;; recommended).  You will also need to add the following to your
;; .emacs file so that the .py files come up in python-mode:
;;
;;     (autoload 'python-mode "python-mode" "Python editing mode." t)
;;     (setq auto-mode-alist
;;	     (cons '("\\.py$" . python-mode) auto-mode-alist))
;;     (setq interpreter-mode-alist
;;           (cons '("python" . python-mode) interpreter-mode-alist))
;;
;; Assuming python-mode.el is on your load-path, it will be invoked
;; when you visit a .py file, or a file with a first line that looks
;; like:
;;
;;   #! /usr/bin/env python

;; NOTE TO XEMACS USERS:

;; An older version of this file was distributed with XEmacs 19.15,
;; 19.16 and 20.3.  By default, in XEmacs when you visit a .py file,
;; the buffer is put in Python mode.  Likewise for executable scripts
;; with the word `python' on the first line.  You shouldn't need to do
;; much except make sure this new version is earlier in your
;; load-path, and byte-compile this file.

;; FOR MORE INFORMATION:

;; Please see <http://www.python.org/ftp/emacs/pmdetails.html> for the
;; latest information and compatibility notes.

;; BUG REPORTING:

;; To submit bug reports, use C-c C-b.  Please include a complete, but
;; concise code sample and a recipe for reproducing the bug.  Send
;; suggestions and other comments to python-mode@python.org.

;; When in a Python mode buffer, do a C-h m for more help.  It's
;; doubtful that a texinfo manual would be very useful, but if you
;; want to contribute one, I'll certainly accept it!

;; If you are using XEmacs, you may also want to check out OO-Browser
;; that comes bundled with it, including documentation in the info
;; pages.  For GNU Emacs you have to install it yourself.  To read
;; more about OO-Browser, follow these links:

;; http://www.python.org/workshops/1996-06/papers/h.pasanen/oobr_contents.html
;; http://www.infodock.com/manuals/alt-oobr-cover.html

;; You may also want to take a look at Harri Pasanen's "Python Library
;; Reference Hot-Key Help System for XEmacs (or PLRHKHSX for short ;),
;; version 1.0"
;;
;; <http://www.iki.fi/hpa/>

;; TO DO LIST:

;; - Better integration with pdb.py and gud-mode for debugging.
;; - Rewrite according to GNU Emacs Lisp standards.
;; - possibly force indent-tabs-mode == nil, and add a
;;   write-file-hooks that runs untabify on the whole buffer (to work
;;   around potential tab/space mismatch problems).  In practice this
;;   hasn't been a problem... yet.
;; - have py-execute-region on indented code act as if the region is
;;   left justified.  Avoids syntax errors.
;; - add a py-goto-block-down, bound to C-c C-d

;;; Code:

(require 'custom)
(eval-when-compile
  (require 'cl)
  (if (not (and (condition-case nil
		    (require 'custom)
		  (error nil))
		;; Stock Emacs 19.34 has a broken/old Custom library
		;; that does more harm than good.  Fortunately, it is
		;; missing defcustom
		(fboundp 'defcustom)))
      (error "STOP! STOP! STOP! STOP!

The Custom library was not found or is out of date.  A more current
version is required.  Please download and install the latest version
of the Custom library from:

    <http://www.dina.kvl.dk/~abraham/custom/>

See the Python Mode home page for details:

    <http://www.python.org/ftp/emacs/>
")))



;; user definable variables
;; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

(defgroup python nil
  "Support for the Python programming language, <http://www.python.org/>"
  :group 'languages)

(defcustom py-python-command "python"
  "*Shell command used to start Python interpreter."
  :type 'string
  :group 'python)

(defcustom py-jpython-command "jpython"
  "*Shell command used to start the JPython interpreter."
  :type 'string
  :group 'python)

(defcustom py-python-command-args '("-i")
  "*List of string arguments to be used when starting a Python shell."
  :type '(repeat string)
  :group 'python)

(defcustom py-jpython-command-args '("-i")
  "*List of string arguments to be used when starting a JPython shell."
  :type '(repeat string)
  :group 'python)

(defcustom py-indent-offset 4
  "*Amount of offset per level of indentation
Note that `\\[py-guess-indent-offset]' can usually guess a good value
when you're editing someone else's Python code."
  :type 'integer
  :group 'python)

(defcustom py-smart-indentation t
  "*Should `python-mode' try to automagically set some indentation variables?
When this variable is non-nil, two things happen when a buffer is set
to `python-mode':

    1. `py-indent-offset' is guess from existing code in the buffer.
       Only guessed values between 2 and 8 are considered.  If a valid
       guess can't be made (perhaps because you are visiting a new
       file), then the value in `py-indent-offset' is used.

    2. `indent-tabs-mode' is turned off if `py-indent-offset' does not
       equal `tab-width' (`indent-tabs-mode' is never turned on by
       Python mode).  This means that for newly written code, tabs are
       only inserted in indentation if one tab is one indentation
       level, otherwise only spaces are used.

Note that both these settings occur *after* `python-mode-hook' is run,
so if you want to defeat the automagic configuration, you must also
set `py-smart-indentation' to nil in your `python-mode-hook'."
  :type 'boolean
  :group 'python)

(defcustom py-align-multiline-strings-p t
  "*Flag describing how multi-line triple quoted strings are aligned.
When this flag is non-nil, continuation lines are lined up under the
preceding line's indentation.  When this flag is nil, continuation
lines are aligned to column zero."
  :type '(choice (const :tag "Align under preceding line" t)
		 (const :tag "Align to column zero" nil))
  :group 'python)

(defcustom py-block-comment-prefix "## "
  "*String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
`...' is arbitrary)."
  :type 'string
  :group 'python)

(defcustom py-honor-comment-indentation t
  "*Controls how comment lines influence subsequent indentation.

When nil, all comment lines are skipped for indentation purposes, and
if possible, a faster algorithm is used (i.e. X/Emacs 19 and beyond).

When t, lines that begin with a single `#' are a hint to subsequent
line indentation.  If the previous line is such a comment line (as
opposed to one that starts with `py-block-comment-prefix'), then it's
indentation is used as a hint for this line's indentation.  Lines that
begin with `py-block-comment-prefix' are ignored for indentation
purposes.

When not nil or t, comment lines that begin with a `#' are used as
indentation hints, unless the comment character is in column zero."
  :type '(choice
	  (const :tag "Skip all comment lines (fast)" nil)
	  (const :tag "Single # `sets' indentation for next line" t)
	  (const :tag "Single # `sets' indentation except at column zero"
		 other)
	  )
  :group 'python)

(defcustom py-scroll-process-buffer nil
  "*Scroll Python process buffer as output arrives.
If nil, the Python process buffer acts, with respect to scrolling, like
Shell-mode buffers normally act.  This is surprisingly complicated and
so won't be explained here; in fact, you can't get the whole story
without studying the Emacs C code.

If non-nil, the behavior is different in two respects (which are
slightly inaccurate in the interest of brevity):

  - If the buffer is in a window, and you left point at its end, the
    window will scroll as new output arrives, and point will move to the
    buffer's end, even if the window is not the selected window (that
    being the one the cursor is in).  The usual behavior for shell-mode
    windows is not to scroll, and to leave point where it was, if the
    buffer is in a window other than the selected window.

  - If the buffer is not visible in any window, and you left point at
    its end, the buffer will be popped into a window as soon as more
    output arrives.  This is handy if you have a long-running
    computation and don't want to tie up screen area waiting for the
    output.  The usual behavior for a shell-mode buffer is to stay
    invisible until you explicitly visit it.

Note the `and if you left point at its end' clauses in both of the
above:  you can `turn off' the special behaviors while output is in
progress, by visiting the Python buffer and moving point to anywhere
besides the end.  Then the buffer won't scroll, point will remain where
you leave it, and if you hide the buffer it will stay hidden until you
visit it again.  You can enable and disable the special behaviors as
often as you like, while output is in progress, by (respectively) moving
point to, or away from, the end of the buffer.

Warning:  If you expect a large amount of output, you'll probably be
happier setting this option to nil.

Obscure:  `End of buffer' above should really say `at or beyond the
process mark', but if you know what that means you didn't need to be
told <grin>."
  :type 'boolean
  :group 'python)

(defcustom py-temp-directory
  (let ((ok '(lambda (x)
	       (and x
		    (setq x (expand-file-name x)) ; always true
		    (file-directory-p x)
		    (file-writable-p x)
		    x))))
    (or (funcall ok (getenv "TMPDIR"))
	(funcall ok "/usr/tmp")
	(funcall ok "/tmp")
	(funcall ok  ".")
	(error
	 "Couldn't find a usable temp directory -- set `py-temp-directory'")))
  "*Directory used for temp files created by a *Python* process.
By default, the first directory from this list that exists and that you
can write into:  the value (if any) of the environment variable TMPDIR,
/usr/tmp, /tmp, or the current directory."
  :type 'string
  :group 'python)

(defcustom py-beep-if-tab-change t
  "*Ring the bell if tab-width is changed.
If a comment of the form

  \t# vi:set tabsize=<number>:

is found before the first code line when the file is entered, and the
current value of (the general Emacs variable) `tab-width' does not
equal <number>, `tab-width' is set to <number>, a message saying so is
displayed in the echo area, and if `py-beep-if-tab-change' is non-nil
the Emacs bell is also rung as a warning."
  :type 'boolean
  :group 'python)

(defcustom py-jump-on-exception t
  "*Jump to innermost exception frame in *Python Output* buffer.
When this variable is non-nil and ane exception occurs when running
Python code synchronously in a subprocess, jump immediately to the
source code of the innermost frame.")

(defcustom py-backspace-function 'backward-delete-char-untabify
  "*Function called by `py-electric-backspace' when deleting backwards."
  :type 'function
  :group 'python)

(defcustom py-delete-function 'delete-char
  "*Function called by `py-electric-delete' when deleting forwards."
  :type 'function
  :group 'python)

;; Not customizable
(defvar py-master-file nil
  "If non-nil, execute the named file instead of the buffer's file.
The intent is to allow you to set this variable in the file's local
variable section, e.g.:

    # Local Variables:
    # py-master-file: \"master.py\"
    # End:

so that typing \\[py-execute-buffer] in that buffer executes the
named master file instead of the buffer's file.  Note that if the file
name has a relative path, the `default-directory' for the buffer is
prepended to come up with a file name.")
(make-variable-buffer-local 'py-master-file)



;; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;; NO USER DEFINABLE VARIABLES BEYOND THIS POINT

(defconst py-emacs-features
  (let (features)
   ;; NTEmacs 19.34.6 has a broken make-temp-name; it always returns
   ;; the same string.
   (let ((tmp1 (make-temp-name ""))
	 (tmp2 (make-temp-name "")))
     (if (string-equal tmp1 tmp2)
	 (push 'broken-temp-names features)))
   ;; return the features
   features)
  "A list of features extant in the Emacs you are using.
There are many flavors of Emacs out there, with different levels of
support for features needed by `python-mode'.")

(defvar python-font-lock-keywords
  (let ((kw1 (mapconcat 'identity
			'("and"      "assert"   "break"   "class"
			  "continue" "def"      "del"     "elif"
			  "else"     "except"   "exec"    "for"
			  "from"     "global"   "if"      "import"
			  "in"       "is"       "lambda"  "not"
			  "or"       "pass"     "print"   "raise"
			  "return"   "while"
			  )
			"\\|"))
	(kw2 (mapconcat 'identity
			'("else:" "except:" "finally:" "try:")
			"\\|"))
	)
    (list
     ;; keywords
     (cons (concat "\\b\\(" kw1 "\\)\\b[ \n\t(]") 1)
     ;; block introducing keywords with immediately following colons.
     ;; Yes "except" is in both lists.
     (cons (concat "\\b\\(" kw2 "\\)[ \n\t(]") 1)
     ;; classes
     '("\\bclass[ \t]+\\([a-zA-Z_]+[a-zA-Z0-9_]*\\)"
       1 font-lock-type-face)
     ;; functions
     '("\\bdef[ \t]+\\([a-zA-Z_]+[a-zA-Z0-9_]*\\)"
       1 font-lock-function-name-face)
     ))
  "Additional expressions to highlight in Python mode.")
(put 'python-mode 'font-lock-defaults '(python-font-lock-keywords))


(defvar imenu-example--python-show-method-args-p nil 
  "*Controls echoing of arguments of functions & methods in the imenu buffer.
When non-nil, arguments are printed.")

(make-variable-buffer-local 'py-indent-offset)

;; have to bind py-file-queue before installing the kill-emacs-hook
(defvar py-file-queue nil
  "Queue of Python temp files awaiting execution.
Currently-active file is at the head of the list.")


;; Constants

;; Regexp matching a Python string literal
(defconst py-stringlit-re
  (concat
   "'\\([^'\n\\]\\|\\\\.\\)*'"		; single-quoted
   "\\|"				; or
   "\"\\([^\"\n\\]\\|\\\\.\\)*\""))	; double-quoted

;; Regexp matching Python lines that are continued via backslash.
;; This is tricky because a trailing backslash does not mean
;; continuation if it's in a comment
(defconst py-continued-re
  (concat
   "\\(" "[^#'\"\n\\]" "\\|" py-stringlit-re "\\)*"
   "\\\\$"))
  
;; Regexp matching blank or comment lines.
(defconst py-blank-or-comment-re "[ \t]*\\($\\|#\\)")

;; Regexp matching clauses to be outdented one level.
(defconst py-outdent-re
  (concat "\\(" (mapconcat 'identity
			   '("else:"
			     "except\\(\\s +.*\\)?:"
			     "finally:"
			     "elif\\s +.*:")
			   "\\|")
	  "\\)"))
  

;; Regexp matching keywords which typically close a block
(defconst py-block-closing-keywords-re
  "\\(return\\|raise\\|break\\|continue\\|pass\\)")

;; Regexp matching lines to not outdent after.
(defconst py-no-outdent-re
  (concat
   "\\("
   (mapconcat 'identity
	      (list "try:"
		    "except\\(\\s +.*\\)?:"
		    "while\\s +.*:"
		    "for\\s +.*:"
		    "if\\s +.*:"
		    "elif\\s +.*:"
		    (concat py-block-closing-keywords-re "[ \t\n]")
		    )
	      "\\|")
	  "\\)"))

;; Regexp matching a function, method or variable assignment.  If you
;; change this, you probably have to change `py-current-defun' as
;; well.  This is only used by `py-current-defun' to find the name for
;; add-log.el.
(defconst py-defun-start-re
  "^\\([ \t]*\\)def[ \t]+\\([a-zA-Z_0-9]+\\)\\|\\(^[a-zA-Z_0-9]+\\)[ \t]*=")

;; Regexp for finding a class name.  If you change this, you probably
;; have to change `py-current-defun' as well.  This is only used by
;; `py-current-defun' to find the name for add-log.el.
(defconst py-class-start-re "^class[ \t]*\\([a-zA-Z_0-9]+\\)")

;; Regexp that describes tracebacks
(defconst py-traceback-line-re
  "[ \t]+File \"\\([^\"]+\\)\", line \\([0-9]+\\)")



;; Utilities

(defmacro py-safe (&rest body)
  ;; safely execute BODY, return nil if an error occurred
  (` (condition-case nil
	 (progn (,@ body))
       (error nil))))

(defsubst py-keep-region-active ()
  ;; Do whatever is necessary to keep the region active in XEmacs.
  ;; Ignore byte-compiler warnings you might see.  Also note that
  ;; FSF's Emacs 19 does it differently; its policy doesn't require us
  ;; to take explicit action.
  (and (boundp 'zmacs-region-stays)
       (setq zmacs-region-stays t)))

(defsubst py-point (position)
  ;; Returns the value of point at certain commonly referenced POSITIONs.
  ;; POSITION can be one of the following symbols:
  ;; 
  ;; bol  -- beginning of line
  ;; eol  -- end of line
  ;; bod  -- beginning of defun
  ;; boi  -- back to indentation
  ;; 
  ;; This function does not modify point or mark.
  (let ((here (point)))
    (cond
     ((eq position 'bol) (beginning-of-line))
     ((eq position 'eol) (end-of-line))
     ((eq position 'bod) (beginning-of-python-def-or-class))
     ((eq position 'bob) (beginning-of-buffer))
     ((eq position 'eob) (end-of-buffer))
     ((eq position 'boi) (back-to-indentation))
     (t (error "unknown buffer position requested: %s" position))
     )
    (prog1
	(point)
      (goto-char here))))

(defsubst py-highlight-line (from to file line)
  (cond
   ((fboundp 'make-extent)
    ;; XEmacs
    (let ((e (make-extent from to)))
      (set-extent-property e 'mouse-face 'highlight)
      (set-extent-property e 'py-exc-info (cons file line))
      (set-extent-property e 'keymap py-mode-output-map)))
   (t
    ;; Emacs -- Please port this!
    )
   ))

(defun py-in-literal (&optional lim)
  ;; Determine if point is in a Python literal, defined as a comment
  ;; or string.  This is the version used for non-XEmacs, which has a
  ;; nicer interface.
  ;;
  ;; WARNING: Watch out for infinite recursion.
  (let* ((lim (or lim (c-point 'bod)))
	 (state (parse-partial-sexp lim (point))))
    (cond
     ((nth 3 state) 'string)
     ((nth 4 state) 'comment)
     (t nil))))

;; XEmacs has a built-in function that should make this much quicker.
;; In this case, lim is ignored
(defun py-fast-in-literal (&optional lim)
  ;; don't have to worry about context == 'block-comment
  (buffer-syntactic-context))

(if (fboundp 'buffer-syntactic-context)
    (defalias 'c-in-literal 'c-fast-in-literal))



;; Major mode boilerplate

;; define a mode-specific abbrev table for those who use such things
(defvar python-mode-abbrev-table nil
  "Abbrev table in use in `python-mode' buffers.")
(define-abbrev-table 'python-mode-abbrev-table nil)

(defvar python-mode-hook nil
  "*Hook called by `python-mode'.")

;; in previous version of python-mode.el, the hook was incorrectly
;; called py-mode-hook, and was not defvar'd.  deprecate its use.
(and (fboundp 'make-obsolete-variable)
     (make-obsolete-variable 'py-mode-hook 'python-mode-hook))

(defvar py-mode-map ()
  "Keymap used in `python-mode' buffers.")
(if py-mode-map
    nil
  (setq py-mode-map (make-sparse-keymap))
  ;; electric keys
  (define-key py-mode-map ":" 'py-electric-colon)
  ;; indentation level modifiers
  (define-key py-mode-map "\C-c\C-l"  'py-shift-region-left)
  (define-key py-mode-map "\C-c\C-r"  'py-shift-region-right)
  (define-key py-mode-map "\C-c<"     'py-shift-region-left)
  (define-key py-mode-map "\C-c>"     'py-shift-region-right)
  ;; subprocess commands
  (define-key py-mode-map "\C-c\C-c"  'py-execute-buffer)
  (define-key py-mode-map "\C-c|"     'py-execute-region)
  (define-key py-mode-map "\C-c!"     'py-shell)
  (define-key py-mode-map "\C-c\C-t"  'py-toggle-shells)
  ;; Caution!  Enter here at your own risk.  We are trying to support
  ;; several behaviors and it gets disgusting. :-( This logic ripped
  ;; largely from CC Mode.
  ;;
  ;; In XEmacs 19, Emacs 19, and Emacs 20, we use this to bind
  ;; backwards deletion behavior to DEL, which both Delete and
  ;; Backspace get translated to.  There's no way to separate this
  ;; behavior in a clean way, so deal with it!  Besides, it's been
  ;; this way since the dawn of time.
  (if (not (boundp 'delete-key-deletes-forward))
      (define-key py-mode-map "\177" 'py-electric-backspace)
    ;; However, XEmacs 20 actually achieved enlightenment.  It is
    ;; possible to sanely define both backward and forward deletion
    ;; behavior under X separately (TTYs are forever beyond hope, but
    ;; who cares?  XEmacs 20 does the right thing with these too).
    (define-key py-mode-map [delete]    'py-electric-delete)
    (define-key py-mode-map [backspace] 'py-electric-backspace))
  ;; Separate M-BS from C-M-h.  The former should remain
  ;; backward-kill-word.
  (define-key py-mode-map [(control meta h)] 'py-mark-def-or-class)
  (define-key py-mode-map "\C-c\C-k"  'py-mark-block)
  ;; Miscellaneous
  (define-key py-mode-map "\C-c:"     'py-guess-indent-offset)
  (define-key py-mode-map "\C-c\t"    'py-indent-region)
  (define-key py-mode-map "\C-c\C-n"  'py-next-statement)
  (define-key py-mode-map "\C-c\C-p"  'py-previous-statement)
  (define-key py-mode-map "\C-c\C-u"  'py-goto-block-up)
  (define-key py-mode-map "\C-c#"     'py-comment-region)
  (define-key py-mode-map "\C-c?"     'py-describe-mode)
  (define-key py-mode-map "\C-c\C-hm" 'py-describe-mode)
  (define-key py-mode-map "\e\C-a"    'beginning-of-python-def-or-class)
  (define-key py-mode-map "\e\C-e"    'end-of-python-def-or-class)
  (define-key py-mode-map "\C-c-"     'py-up-exception)
  (define-key py-mode-map "\C-c="     'py-down-exception)
  ;; information
  (define-key py-mode-map "\C-c\C-b" 'py-submit-bug-report)
  (define-key py-mode-map "\C-c\C-v" 'py-version)
  ;; py-newline-and-indent mappings
  (define-key py-mode-map "\n"   'py-newline-and-indent)
  (define-key py-mode-map "\C-m" 'py-newline-and-indent)
  ;; shadow global bindings for newline-and-indent w/ the py- version.
  ;; BAW - this is extremely bad form, but I'm not going to change it
  ;; for now.
  (mapcar #'(lambda (key)
	      (define-key py-mode-map key 'py-newline-and-indent))
	  (where-is-internal 'newline-and-indent))
  )

(defvar py-mode-output-map nil
  "Keymap used in *Python Output* buffers*")
(if py-mode-output-map
    nil
  (setq py-mode-output-map (make-sparse-keymap))
  (define-key py-mode-output-map [button2]  'py-mouseto-exception)
  (define-key py-mode-output-map "\C-c\C-c" 'py-goto-exception)
  ;; TBD: Disable all self-inserting keys.  This is bogus, we should
  ;; really implement this as *Python Output* buffer being read-only
  (mapcar #' (lambda (key)
	       (define-key py-mode-output-map key
		 #'(lambda () (interactive) (beep))))
	     (where-is-internal 'self-insert-command))
  )

(defvar py-mode-syntax-table nil
  "Syntax table used in `python-mode' buffers.")
(if py-mode-syntax-table
    nil
  (setq py-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\( "()" py-mode-syntax-table)
  (modify-syntax-entry ?\) ")(" py-mode-syntax-table)
  (modify-syntax-entry ?\[ "(]" py-mode-syntax-table)
  (modify-syntax-entry ?\] ")[" py-mode-syntax-table)
  (modify-syntax-entry ?\{ "(}" py-mode-syntax-table)
  (modify-syntax-entry ?\} "){" py-mode-syntax-table)
  ;; Add operator symbols misassigned in the std table
  (modify-syntax-entry ?\$ "."  py-mode-syntax-table)
  (modify-syntax-entry ?\% "."  py-mode-syntax-table)
  (modify-syntax-entry ?\& "."  py-mode-syntax-table)
  (modify-syntax-entry ?\* "."  py-mode-syntax-table)
  (modify-syntax-entry ?\+ "."  py-mode-syntax-table)
  (modify-syntax-entry ?\- "."  py-mode-syntax-table)
  (modify-syntax-entry ?\/ "."  py-mode-syntax-table)
  (modify-syntax-entry ?\< "."  py-mode-syntax-table)
  (modify-syntax-entry ?\= "."  py-mode-syntax-table)
  (modify-syntax-entry ?\> "."  py-mode-syntax-table)
  (modify-syntax-entry ?\| "."  py-mode-syntax-table)
  ;; For historical reasons, underscore is word class instead of
  ;; symbol class.  GNU conventions say it should be symbol class, but
  ;; there's a natural conflict between what major mode authors want
  ;; and what users expect from `forward-word' and `backward-word'.
  ;; Guido and I have hashed this out and have decided to keep
  ;; underscore in word class.  If you're tempted to change it, try
  ;; binding M-f and M-b to py-forward-into-nomenclature and
  ;; py-backward-into-nomenclature instead.
  (modify-syntax-entry ?\_ "w"  py-mode-syntax-table)
  ;; Both single quote and double quote are string delimiters
  (modify-syntax-entry ?\' "\"" py-mode-syntax-table)
  (modify-syntax-entry ?\" "\"" py-mode-syntax-table)
  ;; backquote is open and close paren
  (modify-syntax-entry ?\` "$"  py-mode-syntax-table)
  ;; comment delimiters
  (modify-syntax-entry ?\# "<"  py-mode-syntax-table)
  (modify-syntax-entry ?\n ">"  py-mode-syntax-table)
  )



;; Menu definitions, only relevent if you have the easymenu.el package
;; (standard in the latest Emacs 19 and XEmacs 19 distributions).
(defvar py-menu nil
  "Menu for Python Mode.
This menu will get created automatically if you have the `easymenu'
package.  Note that the latest X/Emacs releases contain this package.")

(and (py-safe (require 'easymenu) t)
     (easy-menu-define
      py-menu py-mode-map "Python Mode menu"
      '("Python"
	["Comment Out Region"   py-comment-region  (mark)]
	["Uncomment Region"     (py-comment-region (point) (mark) '(4)) (mark)]
	"-"
	["Mark current block"   py-mark-block t]
	["Mark current def"     py-mark-def-or-class t]
	["Mark current class"   (py-mark-def-or-class t) t]
	"-"
	["Shift region left"    py-shift-region-left (mark)]
	["Shift region right"   py-shift-region-right (mark)]
	"-"
	["Execute buffer"       py-execute-buffer t]
	["Execute region"       py-execute-region (mark)]
	["Start interpreter..." py-shell t]
	"-"
	["Go to start of block" py-goto-block-up t]
	["Go to start of class" (beginning-of-python-def-or-class t) t]
	["Move to end of class" (end-of-python-def-or-class t) t]
	["Move to start of def" beginning-of-python-def-or-class t]
	["Move to end of def"   end-of-python-def-or-class t]
	"-"
	["Describe mode"        py-describe-mode t]
	)))



;; imenu definitions, courtesy of Perry A. Stoll <stoll@atr-sw.atr.co.jp>
(defvar imenu-example--python-class-regexp
  (concat				; <<classes>>
   "\\("				;
   "^[ \t]*"				; newline and maybe whitespace
   "\\(class[ \t]+[a-zA-Z0-9_]+\\)"	; class name
					; possibly multiple superclasses
   "\\([ \t]*\\((\\([a-zA-Z0-9_,. \t\n]\\)*)\\)?\\)"
   "[ \t]*:"				; and the final :
   "\\)"				; >>classes<<
   )
  "Regexp for Python classes for use with the imenu package."
  )

(defvar imenu-example--python-method-regexp
  (concat                               ; <<methods and functions>>
   "\\("                                ; 
   "^[ \t]*"                            ; new line and maybe whitespace
   "\\(def[ \t]+"                       ; function definitions start with def
   "\\([a-zA-Z0-9_]+\\)"                ;   name is here
					;   function arguments...
   "[ \t]*(\\([a-zA-Z0-9_=,\* \t\n]*\\))"
   "\\)"                                ; end of def
   "[ \t]*:"                            ; and then the :
   "\\)"                                ; >>methods and functions<<
   )
  "Regexp for Python methods/functions for use with the imenu package."
  )

(defvar imenu-example--python-method-no-arg-parens '(2 8)
  "Indicies into groups of the Python regexp for use with imenu.

Using these values will result in smaller imenu lists, as arguments to
functions are not listed.

See the variable `imenu-example--python-show-method-args-p' for more
information.")

(defvar imenu-example--python-method-arg-parens '(2 7)
  "Indicies into groups of the Python regexp for use with imenu.
Using these values will result in large imenu lists, as arguments to
functions are listed.

See the variable `imenu-example--python-show-method-args-p' for more
information.")

;; Note that in this format, this variable can still be used with the
;; imenu--generic-function. Otherwise, there is no real reason to have
;; it.
(defvar imenu-example--generic-python-expression
  (cons
   (concat 
    imenu-example--python-class-regexp
    "\\|"				; or...
    imenu-example--python-method-regexp
    )
   imenu-example--python-method-no-arg-parens)
  "Generic Python expression which may be used directly with imenu.
Used by setting the variable `imenu-generic-expression' to this value.
Also, see the function \\[imenu-example--create-python-index] for a
better alternative for finding the index.")

;; These next two variables are used when searching for the python
;; class/definitions. Just saving some time in accessing the
;; generic-python-expression, really.
(defvar imenu-example--python-generic-regexp nil)
(defvar imenu-example--python-generic-parens nil)


(defun imenu-example--create-python-index ()
  "Python interface function for imenu package.
Finds all python classes and functions/methods. Calls function
\\[imenu-example--create-python-index-engine].  See that function for
the details of how this works."
  (setq imenu-example--python-generic-regexp
	(car imenu-example--generic-python-expression))
  (setq imenu-example--python-generic-parens
	(if imenu-example--python-show-method-args-p
	    imenu-example--python-method-arg-parens
	  imenu-example--python-method-no-arg-parens))
  (goto-char (point-min))
  (imenu-example--create-python-index-engine nil))

(defun imenu-example--create-python-index-engine (&optional start-indent)
  "Function for finding imenu definitions in Python.

Finds all definitions (classes, methods, or functions) in a Python
file for the imenu package.

Returns a possibly nested alist of the form

	(INDEX-NAME . INDEX-POSITION)

The second element of the alist may be an alist, producing a nested
list as in

	(INDEX-NAME . INDEX-ALIST)

This function should not be called directly, as it calls itself
recursively and requires some setup.  Rather this is the engine for
the function \\[imenu-example--create-python-index].

It works recursively by looking for all definitions at the current
indention level.  When it finds one, it adds it to the alist.  If it
finds a definition at a greater indentation level, it removes the
previous definition from the alist. In it's place it adds all
definitions found at the next indentation level.  When it finds a
definition that is less indented then the current level, it retuns the
alist it has created thus far.

The optional argument START-INDENT indicates the starting indentation
at which to continue looking for Python classes, methods, or
functions.  If this is not supplied, the function uses the indentation
of the first definition found."
  (let ((index-alist '())
	(sub-method-alist '())
	looking-p
	def-name prev-name
	cur-indent def-pos
	(class-paren (first  imenu-example--python-generic-parens)) 
	(def-paren   (second imenu-example--python-generic-parens)))
    (setq looking-p
	  (re-search-forward imenu-example--python-generic-regexp
			     (point-max) t))
    (while looking-p
      (save-excursion
	;; used to set def-name to this value but generic-extract-name is
	;; new to imenu-1.14. this way it still works with imenu-1.11
	;;(imenu--generic-extract-name imenu-example--python-generic-parens))
	(let ((cur-paren (if (match-beginning class-paren)
			     class-paren def-paren)))
	  (setq def-name
		(buffer-substring-no-properties (match-beginning cur-paren)
						(match-end  cur-paren))))
	(beginning-of-line)
	(setq cur-indent (current-indentation)))

      ;; HACK: want to go to the next correct definition location. we
      ;; explicitly list them here. would be better to have them in a
      ;; list.
      (setq def-pos
	    (or  (match-beginning class-paren)
		 (match-beginning def-paren)))

      ;; if we don't have a starting indent level, take this one
      (or start-indent
	  (setq start-indent cur-indent))

      ;; if we don't have class name yet, take this one
      (or prev-name
	  (setq prev-name def-name))

      ;; what level is the next definition on?  must be same, deeper
      ;; or shallower indentation
      (cond
       ;; at the same indent level, add it to the list...
       ((= start-indent cur-indent)

	;; if we don't have push, use the following...
	;;(setf index-alist (cons (cons def-name def-pos) index-alist))
	(push (cons def-name def-pos) index-alist))

       ;; deeper indented expression, recur...
       ((< start-indent cur-indent)

	;; the point is currently on the expression we're supposed to
	;; start on, so go back to the last expression. The recursive
	;; call will find this place again and add it to the correct
	;; list
	(re-search-backward imenu-example--python-generic-regexp
			    (point-min) 'move)
	(setq sub-method-alist (imenu-example--create-python-index-engine
				cur-indent))

	(if sub-method-alist
	    ;; we put the last element on the index-alist on the start
	    ;; of the submethod alist so the user can still get to it.
	    (let ((save-elmt (pop index-alist)))
	      (push (cons prev-name
			  (cons save-elmt sub-method-alist))
		    index-alist))))

       ;; found less indented expression, we're done.
       (t 
	(setq looking-p nil)
	(re-search-backward imenu-example--python-generic-regexp 
			    (point-min) t)))
      (setq prev-name def-name)
      (and looking-p
	   (setq looking-p
		 (re-search-forward imenu-example--python-generic-regexp
				    (point-max) 'move))))
    (nreverse index-alist)))


;;;###autoload
(defun python-mode ()
  "Major mode for editing Python files.
To submit a problem report, enter `\\[py-submit-bug-report]' from a
`python-mode' buffer.  Do `\\[py-describe-mode]' for detailed
documentation.  To see what version of `python-mode' you are running,
enter `\\[py-version]'.

This mode knows about Python indentation, tokens, comments and
continuation lines.  Paragraphs are separated by blank lines only.

COMMANDS
\\{py-mode-map}
VARIABLES

py-indent-offset\t\tindentation increment
py-block-comment-prefix\t\tcomment string used by comment-region
py-python-command\t\tshell command to invoke Python interpreter
py-scroll-process-buffer\t\talways scroll Python process buffer
py-temp-directory\t\tdirectory used for temp files (if needed)
py-beep-if-tab-change\t\tring the bell if tab-width is changed"
  (interactive)
  ;; set up local variables
  (kill-all-local-variables)
  (make-local-variable 'font-lock-defaults)
  (make-local-variable 'paragraph-separate)
  (make-local-variable 'paragraph-start)
  (make-local-variable 'require-final-newline)
  (make-local-variable 'comment-start)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-start-skip)
  (make-local-variable 'comment-column)
  (make-local-variable 'indent-region-function)
  (make-local-variable 'indent-line-function)
  (make-local-variable 'add-log-current-defun-function)
  ;;
  (set-syntax-table py-mode-syntax-table)
  (setq major-mode             'python-mode
	mode-name              "Python"
	local-abbrev-table     python-mode-abbrev-table
	font-lock-defaults     '(python-font-lock-keywords)
	paragraph-separate     "^[ \t]*$"
	paragraph-start        "^[ \t]*$"
	require-final-newline  t
	comment-start          "# "
	comment-end            ""
	comment-start-skip     "# *"
	comment-column         40
	indent-region-function 'py-indent-region
	indent-line-function   'py-indent-line
	;; tell add-log.el how to find the current function/method/variable
	add-log-current-defun-function 'py-current-defun
	)
  (use-local-map py-mode-map)
  ;; add the menu
  (if py-menu
      (easy-menu-add py-menu))
  ;; Emacs 19 requires this
  (if (boundp 'comment-multi-line)
      (setq comment-multi-line nil))
  ;; Install Imenu, only works for Emacs.
  (when (py-safe (require 'imenu))
    (make-variable-buffer-local 'imenu-create-index-function)
    (setq imenu-create-index-function
	  (function imenu-example--create-python-index))
    (setq imenu-generic-expression
	  imenu-example--generic-python-expression)
    (if (fboundp 'imenu-add-to-menubar)
	(imenu-add-to-menubar (format "%s-%s" "IM" mode-name)))
    )
  ;; Run the mode hook.  Note that py-mode-hook is deprecated.
  (if python-mode-hook
      (run-hooks 'python-mode-hook)
    (run-hooks 'py-mode-hook))
  ;; Now do the automagical guessing
  (if py-smart-indentation
    (let ((offset py-indent-offset))
      ;; Its okay if this fails to guess a good value
      (if (and (py-safe (py-guess-indent-offset))
	       (<= py-indent-offset 8)
	       (>= py-indent-offset 2))
	  (setq offset py-indent-offset))
      (setq py-indent-offset offset)
      ;; Only turn indent-tabs-mode off if tab-width !=
      ;; py-indent-offset.  Never turn it on, because the user must
      ;; have explicitly turned it off.
      (if (/= tab-width py-indent-offset)
	  (setq indent-tabs-mode nil))
      )))


;; electric characters
(defun py-outdent-p ()
  ;; returns non-nil if the current line should outdent one level
  (save-excursion
    (and (progn (back-to-indentation)
		(looking-at py-outdent-re))
	 (progn (forward-line -1)
		(py-goto-initial-line)
		(back-to-indentation)
		(while (or (looking-at py-blank-or-comment-re)
			   (bobp))
		  (backward-to-indentation 1))
		(not (looking-at py-no-outdent-re)))
	 )))
      
(defun py-electric-colon (arg)
  "Insert a colon.
In certain cases the line is outdented appropriately.  If a numeric
argument is provided, that many colons are inserted non-electrically.
Electric behavior is inhibited inside a string or comment."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  ;; are we in a string or comment?
  (if (save-excursion
	(let ((pps (parse-partial-sexp (save-excursion
					 (beginning-of-python-def-or-class)
					 (point))
				       (point))))
	  (not (or (nth 3 pps) (nth 4 pps)))))
      (save-excursion
	(let ((here (point))
	      (outdent 0)
	      (indent (py-compute-indentation t)))
	  (if (and (not arg)
		   (py-outdent-p)
		   (= indent (save-excursion
			       (py-next-statement -1)
			       (py-compute-indentation t)))
		   )
	      (setq outdent py-indent-offset))
	  ;; Don't indent, only outdent.  This assumes that any lines that
	  ;; are already outdented relative to py-compute-indentation were
	  ;; put there on purpose.  Its highly annoying to have `:' indent
	  ;; for you.  Use TAB, C-c C-l or C-c C-r to adjust.  TBD: Is
	  ;; there a better way to determine this???
	  (if (< (current-indentation) indent) nil
	    (goto-char here)
	    (beginning-of-line)
	    (delete-horizontal-space)
	    (indent-to (- indent outdent))
	    )))))


;; Python subprocess utilities and filters
(defun py-execute-file (proc filename)
  ;; Send a properly formatted execfile('FILENAME') to the underlying
  ;; Python interpreter process FILENAME.  Make that process's buffer
  ;; visible and force display.  Also make comint believe the user
  ;; typed this string so that kill-output-from-shell does The Right
  ;; Thing.
  (let ((curbuf (current-buffer))
	(procbuf (process-buffer proc))
	(comint-scroll-to-bottom-on-output t)
	(msg (format "## working on region in file %s...\n" filename))
	(cmd (format "execfile('%s')\n" filename)))
    (unwind-protect
	(progn
	  (set-buffer procbuf)
	  (goto-char (point-max))
	  (move-marker (process-mark proc) (point))
	  (funcall (process-filter proc) proc msg))
      (set-buffer curbuf))
    (process-send-string proc cmd)))

(defun py-process-filter (pyproc string)
  (let ((curbuf (current-buffer))
	(pbuf (process-buffer pyproc))
	(pmark (process-mark pyproc))
	file-finished)
    ;; make sure we switch to a different buffer at least once.  if we
    ;; *don't* do this, then if the process buffer is in the selected
    ;; window, and point is before the end, and lots of output is
    ;; coming at a fast pace, then (a) simple cursor-movement commands
    ;; like C-p, C-n, C-f, C-b, C-a, C-e take an incredibly long time
    ;; to have a visible effect (the window just doesn't get updated,
    ;; sometimes for minutes(!)), and (b) it takes about 5x longer to
    ;; get all the process output (until the next python prompt).
    ;;
    ;; #b makes no sense to me at all.  #a almost makes sense: unless
    ;; we actually change buffers, set_buffer_internal in buffer.c
    ;; doesn't set windows_or_buffers_changed to 1, & that in turn
    ;; seems to make the Emacs command loop reluctant to update the
    ;; display.  Perhaps the default process filter in process.c's
    ;; read_process_output has update_mode_lines++ for a similar
    ;; reason?  beats me ...

    (unwind-protect
	;; make sure current buffer is restored
	;; BAW - we want to check to see if this still applies
	(progn
	  ;; mysterious ugly hack
	  (if (eq curbuf pbuf)
	      (set-buffer (get-buffer-create "*scratch*")))

	  (set-buffer pbuf)
	  (let* ((start (point))
		 (goback (< start pmark))
		 (goend (and (not goback) (= start (point-max))))
		 (buffer-read-only nil))
	    (goto-char pmark)
	    (insert string)
	    (move-marker pmark (point))
	    (setq file-finished
		  (and py-file-queue
		       (equal ">>> "
			      (buffer-substring
			       (prog2 (beginning-of-line) (point)
				 (goto-char pmark))
			       (point)))))
	    (if goback (goto-char start)
	      ;; else
	      (if py-scroll-process-buffer
		  (let* ((pop-up-windows t)
			 (pwin (display-buffer pbuf)))
		    (set-window-point pwin (point)))))
	    (set-buffer curbuf)
	    (if file-finished
		(progn
		  (py-safe (delete-file (car py-file-queue)))
		  (setq py-file-queue (cdr py-file-queue))
		  (if py-file-queue
		      (py-execute-file pyproc (car py-file-queue)))))
	    (and goend
		 (progn (set-buffer pbuf)
			(goto-char (point-max))))
	    ))
      (set-buffer curbuf))))

(defun py-postprocess-output-buffer (buf)
  ;; Highlight exceptions found in BUF.  If an exception occurred
  ;; return t, otherwise return nil.  BUF must exist.
  (let (line file bol err-p)
    (save-excursion
      (set-buffer buf)
      (beginning-of-buffer)
      (while (re-search-forward py-traceback-line-re nil t)
	(setq file (match-string 1)
	      line (string-to-int (match-string 2))
	      bol (py-point 'bol))
	(py-highlight-line bol (py-point 'eol) file line)))
    (when (and py-jump-on-exception line)
      (beep)
      (py-jump-to-exception file line)
      (setq err-p t))
    err-p))



;;; Subprocess commands

;; only used when (memq 'broken-temp-names py-emacs-features)
(defvar py-serial-number 0)
(defvar py-exception-buffer nil)
(defconst py-output-buffer "*Python Output*")
(make-variable-buffer-local 'py-output-buffer)

;; for toggling between CPython and JPython
(defvar py-which-shell py-python-command)
(defvar py-which-args  py-python-command-args)
(defvar py-which-bufname "Python")
(make-variable-buffer-local 'py-which-shell)
(make-variable-buffer-local 'py-which-args)
(make-variable-buffer-local 'py-which-bufname)

(defun py-toggle-shells (arg)
  "Toggles between the CPython and JPython shells.
With positive \\[universal-argument], uses the CPython shell, with
negative \\[universal-argument] uses the JPython shell, and with a
zero argument, toggles the shell."
  (interactive "P")
  ;; default is to toggle
  (if (null arg)
      (setq arg 0))
  ;; toggle if zero
  (if (= arg 0)
      (if (string-equal py-which-bufname "Python")
	  (setq arg -1)
	(setq arg 1)))
  (let (msg)
    (cond
     ((< 0 arg)
      ;; set to CPython
      (setq py-which-shell py-python-command
	    py-which-args py-python-command-args
	    py-which-bufname "Python"
	    msg "CPython"
	    mode-name "Python"))
     ((> 0 arg)
      (setq py-which-shell py-jpython-command
	    py-which-args py-jpython-command-args
	    py-which-bufname "JPython"
	    msg "JPython"
	    mode-name "JPython"))
     )
    (message "Using the %s shell" msg)
    (setq py-output-buffer (format "*%s Output*" py-which-bufname))))

;;;###autoload
(defun py-shell ()
  "Start an interactive Python interpreter in another window.
This is like Shell mode, except that Python is running in the window
instead of a shell.  See the `Interactive Shell' and `Shell Mode'
sections of the Emacs manual for details, especially for the key
bindings active in the `*Python*' buffer.

See the docs for variable `py-scroll-buffer' for info on scrolling
behavior in the process window.

Note: You can toggle between using the CPython interpreter and the
JPython interpreter by hitting \\[py-toggle-shells].  This toggles
buffer local variables which control whether all your subshell
interactions happen to the `*JPython*' or `*Python*' buffers (the
latter is the name used for the CPython buffer).

Warning: Don't use an interactive Python if you change sys.ps1 or
sys.ps2 from their default values, or if you're running code that
prints `>>> ' or `... ' at the start of a line.  `python-mode' can't
distinguish your output from Python's output, and assumes that `>>> '
at the start of a line is a prompt from Python.  Similarly, the Emacs
Shell mode code assumes that both `>>> ' and `... ' at the start of a
line are Python prompts.  Bad things can happen if you fool either
mode.

Warning:  If you do any editing *in* the process buffer *while* the
buffer is accepting output from Python, do NOT attempt to `undo' the
changes.  Some of the output (nowhere near the parts you changed!) may
be lost if you do.  This appears to be an Emacs bug, an unfortunate
interaction between undo and process filters; the same problem exists in
non-Python process buffers using the default (Emacs-supplied) process
filter."
  ;; BAW - should undo be disabled in the python process buffer, if
  ;; this bug still exists?
  (interactive)
  (require 'comint)
  (switch-to-buffer-other-window
   (apply 'make-comint py-which-bufname py-which-shell nil py-which-args))
  (make-local-variable 'comint-prompt-regexp)
  (setq comint-prompt-regexp "^>>> \\|^[.][.][.] ")
  (set-process-filter (get-buffer-process (current-buffer)) 'py-process-filter)
  (set-syntax-table py-mode-syntax-table)
  ;; set up keybindings for this subshell
  (local-set-key [tab]   'self-insert-command)
  (local-set-key "\C-c-" 'py-up-exception)
  (local-set-key "\C-c=" 'py-down-exception)
  )

(defun py-clear-queue ()
  "Clear the queue of temporary files waiting to execute."
  (interactive)
  (let ((n (length py-file-queue)))
    (mapcar 'delete-file py-file-queue)
    (setq py-file-queue nil)
    (message "%d pending files de-queued." n)))

(defun py-execute-region (start end &optional async)
  "Execute the the region in a Python interpreter.
The region is first copied into a temporary file (in the directory
`py-temp-directory').  If there is no Python interpreter shell
running, this file is executed synchronously using
`shell-command-on-region'.  If the program is long running, use an
optional \\[universal-argument] to run the command asynchronously in
its own buffer.

If the Python interpreter shell is running, the region is execfile()'d
in that shell.  If you try to execute regions too quickly,
`python-mode' will queue them up and execute them one at a time when
it sees a `>>> ' prompt from Python.  Each time this happens, the
process buffer is popped into a window (if it's not already in some
window) so you can see it, and a comment of the form

    \t## working on region in file <name>...

is inserted at the end.  See also the command `py-clear-queue'."
  (interactive "r\nP")
  (or (< start end)
      (error "Region is empty"))
  (let* ((proc (get-process "Python"))
	 (temp (if (memq 'broken-temp-names py-emacs-features)
		   (prog1
		       (format "python-%d" py-serial-number)
		     (setq py-serial-number (1+ py-serial-number)))
		 (make-temp-name "python-")))
	 (file (expand-file-name temp py-temp-directory)))
    (write-region start end file nil 'nomsg)
    (cond
     ;; always run the code in it's own asynchronous subprocess
     (async
      (let* ((buf (generate-new-buffer-name py-output-buffer)))
	(start-process "Python" buf py-python-command "-u" file)
	(pop-to-buffer buf)
	(py-postprocess-output-buffer buf)
	))
     ;; if the Python interpreter shell is running, queue it up for
     ;; execution there.
     (proc
      ;; use the existing python shell
      (if (not py-file-queue)
	  (py-execute-file proc file)
	(message "File %s queued for execution" file))
      (push file py-file-queue)
      (setq py-exception-buffer (cons file (current-buffer))))
     (t
      ;; otherwise either run it synchronously in a subprocess
      (shell-command-on-region start end py-python-command py-output-buffer)
      ;; shell-command-on-region kills the output buffer if it never
      ;; existed and there's no output from the command
      (if (not (get-buffer py-output-buffer))
	  (message "No output.")
	(setq py-exception-buffer (current-buffer))
	(let ((err-p (py-postprocess-output-buffer py-output-buffer)))
	  (pop-to-buffer py-output-buffer)
	  (if err-p
	      (pop-to-buffer py-exception-buffer)))
	))
     )))

;; Code execution command
(defun py-execute-buffer (&optional async)
  "Send the contents of the buffer to a Python interpreter.
If the file local variable `py-master-file' is non-nil, execute the
named file instead of the buffer's file.

If there is a *Python* process buffer it is used.  If a clipping
restriction is in effect, only the accessible portion of the buffer is
sent.  A trailing newline will be supplied if needed.

See the `\\[py-execute-region]' docs for an account of some subtleties."
  (interactive "P")
  (if py-master-file
      (let* ((filename (expand-file-name py-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer)))
  (py-execute-region (point-min) (point-max) async))



(defun py-jump-to-exception (file line)
  (let ((buffer (cond ((string-equal file "<stdin>")
		       py-exception-buffer)
		      ((and (consp py-exception-buffer)
			    (string-equal file (car py-exception-buffer)))
		       (cdr py-exception-buffer))
		      ((py-safe (find-file-noselect file)))
		      ;; could not figure out what file the exception
		      ;; is pointing to, so prompt for it
		      (t (find-file (read-file-name "Exception file: "
						    nil
						    file t))))))
    (pop-to-buffer buffer)
    (goto-line line)
    (message "Jumping to exception in file %s on line %d" file line)))

(defun py-mouseto-exception (event)
  (interactive "e")
  (cond
   ((fboundp 'event-point)
    ;; XEmacs
    (let* ((point (event-point event))
	   (buffer (event-buffer event))
	   (e (and point buffer (extent-at point buffer 'py-exc-info)))
	   (info (and e (extent-property e 'py-exc-info))))
      (message "Event point: %d, info: %s" point info)
      (and info
	   (py-jump-to-exception (car info) (cdr info)))
      ))
   ;; Emacs -- Please port this!
   ))

(defun py-goto-exception ()
  "Go to the line indicated by the traceback."
  (interactive)
  (let (file line)
    (save-excursion
      (beginning-of-line)
      (if (looking-at py-traceback-line-re)
	  (setq file (match-string 1)
		line (string-to-int (match-string 2)))))
    (if (not file)
	(error "Not on a traceback line."))
    (py-jump-to-exception file line)))

(defun py-find-next-exception (start buffer searchdir errwhere)
  ;; Go to start position in buffer, search in the specified
  ;; direction, and jump to the exception found.  If at the end of the
  ;; exception, print error message
  (let (file line)
    (save-excursion
      (set-buffer buffer)
      (goto-char (py-point start))
      (if (funcall searchdir py-traceback-line-re nil t)
	  (setq file (match-string 1)
		line (string-to-int (match-string 2)))))
    (if (and file line)
	(py-jump-to-exception file line)
      (error "%s of traceback" errwhere))))

(defun py-down-exception (&optional bottom)
  "Go to the next line down in the traceback.
With optional \\[universal-argument], jump to the bottom (innermost)
exception in the exception stack."
  (interactive "P")
  (let* ((proc (get-process "Python"))
	 (buffer (if proc "*Python*" py-output-buffer)))
    (if bottom
	(py-find-next-exception 'eob buffer 're-search-backward "Bottom")
      (py-find-next-exception 'eol buffer 're-search-forward "Bottom"))))

(defun py-up-exception (&optional top)
  "Go to the previous line up in the traceback.
With optional \\[universal-argument], jump to the top (outermost)
exception in the exception stack."
  (interactive "P")
  (let* ((proc (get-process "Python"))
	 (buffer (if proc "*Python*" py-output-buffer)))
    (if top
	(py-find-next-exception 'bob buffer 're-search-forward "Top")
      (py-find-next-exception 'bol buffer 're-search-backward "Top"))))


;; Electric deletion
(defun py-electric-backspace (arg)
  "Deletes preceding character or levels of indentation.
Deletion is performed by calling the function in `py-backspace-function'
with a single argument (the number of characters to delete).

If point is at the leftmost column, deletes the preceding newline.

Otherwise, if point is at the leftmost non-whitespace character of a
line that is neither a continuation line nor a non-indenting comment
line, or if point is at the end of a blank line, this command reduces
the indentation to match that of the line that opened the current
block of code.  The line that opened the block is displayed in the
echo area to help you keep track of where you are.  With numeric arg,
outdents that many blocks (but not past column zero).

Otherwise the preceding character is deleted, converting a tab to
spaces if needed so that only a single column position is deleted.
Numeric argument deletes that many preceding characters."
  (interactive "*p")
  (if (or (/= (current-indentation) (current-column))
	  (bolp)
	  (py-continuation-line-p)
	  (not py-honor-comment-indentation)
	  (looking-at "#[^ \t\n]"))	; non-indenting #
      (funcall py-backspace-function arg)
    ;; else indent the same as the colon line that opened the block
    ;; force non-blank so py-goto-block-up doesn't ignore it
    (insert-char ?* 1)
    (backward-char)
    (let ((base-indent 0)		; indentation of base line
	  (base-text "")		; and text of base line
	  (base-found-p nil))
      (save-excursion
	(while (< 0 arg)
	  (condition-case nil		; in case no enclosing block
	      (progn
		(py-goto-block-up 'no-mark)
		(setq base-indent (current-indentation)
		      base-text   (py-suck-up-leading-text)
		      base-found-p t))
	    (error nil))
	  (setq arg (1- arg))))
      (delete-char 1)			; toss the dummy character
      (delete-horizontal-space)
      (indent-to base-indent)
      (if base-found-p
	  (message "Closes block: %s" base-text)))))


(defun py-electric-delete (arg)
  "Deletes preceding or following character or levels of whitespace.

The behavior of this function depends on the variable
`delete-key-deletes-forward'.  If this variable is nil (or does not
exist, as in older Emacsen), then this function behaves identical to
\\[c-electric-backspace].

If `delete-key-deletes-forward' is non-nil and is supported in your
Emacs, then deletion occurs in the forward direction, by calling the
function in `py-delete-function'."
  (interactive "*p")
  (if (and (boundp 'delete-key-deletes-forward)
	   delete-key-deletes-forward)
      (funcall py-delete-function arg)
    ;; else
    (py-electric-backspace arg)))

;; required for pending-del and delsel modes
(put 'py-electric-backspace 'delete-selection 'supersede) ;delsel
(put 'py-electric-backspace 'pending-delete   'supersede) ;pending-del
(put 'py-electric-delete    'delete-selection 'supersede) ;delsel
(put 'py-electric-delete    'pending-delete   'supersede) ;pending-del



(defun py-indent-line (&optional arg)
  "Fix the indentation of the current line according to Python rules.
With \\[universal-argument], ignore outdenting rules for block
closing statements (e.g. return, raise, break, continue, pass)

This function is normally bound to `indent-line-function' so
\\[indent-for-tab-command] will call it."
  (interactive "P")
  (let* ((ci (current-indentation))
	 (move-to-indentation-p (<= (current-column) ci))
	 (need (py-compute-indentation (not arg))))
    ;; see if we need to outdent
    (if (py-outdent-p)
	(setq need (- need py-indent-offset)))
    (if (/= ci need)
	(save-excursion
	  (beginning-of-line)
	  (delete-horizontal-space)
	  (indent-to need)))
    (if move-to-indentation-p (back-to-indentation))))

(defun py-newline-and-indent ()
  "Strives to act like the Emacs `newline-and-indent'.
This is just `strives to' because correct indentation can't be computed
from scratch for Python code.  In general, deletes the whitespace before
point, inserts a newline, and takes an educated guess as to how you want
the new line indented."
  (interactive)
  (let ((ci (current-indentation)))
    (if (< ci (current-column))		; if point beyond indentation
	(newline-and-indent)
      ;; else try to act like newline-and-indent "normally" acts
      (beginning-of-line)
      (insert-char ?\n 1)
      (move-to-column ci))))

(defun py-compute-indentation (honor-block-close-p)
  ;; implements all the rules for indentation computation.  when
  ;; honor-block-close-p is non-nil, statements such as return, raise,
  ;; break, continue, and pass force one level of outdenting.
  (save-excursion
    (beginning-of-line)
    (let* ((bod (py-point 'bod))
	   (pps (parse-partial-sexp bod (point)))
	   (boipps (parse-partial-sexp bod (py-point 'boi))))
      (cond
       ;; are we inside a multi-line string or comment?
       ((or (and (nth 3 pps) (nth 3 boipps))
	    (and (nth 4 pps) (nth 4 boipps)))
	(save-excursion
	  (if (not py-align-multiline-strings-p) 0
	    ;; skip back over blank & non-indenting comment lines
	    ;; note: will skip a blank or non-indenting comment line
	    ;; that happens to be a continuation line too
	    (re-search-backward "^[ \t]*\\([^ \t\n#]\\|#[ \t\n]\\)" nil 'move)
	    (back-to-indentation)
	    (current-column))))
       ;; are we on a continuation line?
       ((py-continuation-line-p)
	(let ((startpos (point))
	      (open-bracket-pos (py-nesting-level))
	      endpos searching found state)
	  (if open-bracket-pos
	      (progn
		;; align with first item in list; else a normal
		;; indent beyond the line with the open bracket
		(goto-char (1+ open-bracket-pos)) ; just beyond bracket
		;; is the first list item on the same line?
		(skip-chars-forward " \t")
		(if (null (memq (following-char) '(?\n ?# ?\\)))
					; yes, so line up with it
		    (current-column)
		  ;; first list item on another line, or doesn't exist yet
		  (forward-line 1)
		  (while (and (< (point) startpos)
			      (looking-at "[ \t]*[#\n\\\\]")) ; skip noise
		    (forward-line 1))
		  (if (and (< (point) startpos)
			   (/= startpos
			       (save-excursion
				 (goto-char (1+ open-bracket-pos))
				 (skip-chars-forward " \t\n")
				 (point))))
		      ;; again mimic the first list item
		      (current-indentation)
		    ;; else they're about to enter the first item
		    (goto-char open-bracket-pos)
		    (+ (current-indentation) py-indent-offset))))

	    ;; else on backslash continuation line
	    (forward-line -1)
	    (if (py-continuation-line-p) ; on at least 3rd line in block
		(current-indentation)	; so just continue the pattern
	      ;; else started on 2nd line in block, so indent more.
	      ;; if base line is an assignment with a start on a RHS,
	      ;; indent to 2 beyond the leftmost "="; else skip first
	      ;; chunk of non-whitespace characters on base line, + 1 more
	      ;; column
	      (end-of-line)
	      (setq endpos (point)  searching t)
	      (back-to-indentation)
	      (setq startpos (point))
	      ;; look at all "=" from left to right, stopping at first
	      ;; one not nested in a list or string
	      (while searching
		(skip-chars-forward "^=" endpos)
		(if (= (point) endpos)
		    (setq searching nil)
		  (forward-char 1)
		  (setq state (parse-partial-sexp startpos (point)))
		  (if (and (zerop (car state)) ; not in a bracket
			   (null (nth 3 state))) ; & not in a string
		      (progn
			(setq searching nil) ; done searching in any case
			(setq found
			      (not (or
				    (eq (following-char) ?=)
				    (memq (char-after (- (point) 2))
					  '(?< ?> ?!)))))))))
	      (if (or (not found)	; not an assignment
		      (looking-at "[ \t]*\\\\")) ; <=><spaces><backslash>
		  (progn
		    (goto-char startpos)
		    (skip-chars-forward "^ \t\n")))
	      (1+ (current-column))))))

       ;; not on a continuation line
       ((bobp) (current-indentation))

       ;; Dfn: "Indenting comment line".  A line containing only a
       ;; comment, but which is treated like a statement for
       ;; indentation calculation purposes.  Such lines are only
       ;; treated specially by the mode; they are not treated
       ;; specially by the Python interpreter.

       ;; The rules for indenting comment lines are a line where:
       ;;   - the first non-whitespace character is `#', and
       ;;   - the character following the `#' is whitespace, and
       ;;   - the line is outdented with respect to (i.e. to the left
       ;;     of) the indentation of the preceding non-blank line.

       ;; The first non-blank line following an indenting comment
       ;; line is given the same amount of indentation as the
       ;; indenting comment line.

       ;; All other comment-only lines are ignored for indentation
       ;; purposes.

       ;; Are we looking at a comment-only line which is *not* an
       ;; indenting comment line?  If so, we assume that its been
       ;; placed at the desired indentation, so leave it alone.
       ;; Indenting comment lines are aligned as statements down
       ;; below.
       ((and (looking-at "[ \t]*#[^ \t\n]")
	     ;; NOTE: this test will not be performed in older Emacsen
	     (fboundp 'forward-comment)
	     (<= (current-indentation)
		 (save-excursion
		   (forward-comment (- (point-max)))
		   (current-indentation))))
	(current-indentation))

       ;; else indentation based on that of the statement that
       ;; precedes us; use the first line of that statement to
       ;; establish the base, in case the user forced a non-std
       ;; indentation for the continuation lines (if any)
       (t
	;; skip back over blank & non-indenting comment lines note:
	;; will skip a blank or non-indenting comment line that
	;; happens to be a continuation line too.  use fast Emacs 19
	;; function if it's there.
	(if (and (eq py-honor-comment-indentation nil)
		 (fboundp 'forward-comment))
	    (forward-comment (- (point-max)))
	  (let (done)
	    (while (not done)
	      (re-search-backward "^[ \t]*\\([^ \t\n#]\\|#[ \t\n]\\)"
				  nil 'move)
	      (setq done (or (eq py-honor-comment-indentation t)
			     (bobp)
			     (/= (following-char) ?#)
			     (not (zerop (current-column)))))
	      )))
	;; if we landed inside a string, go to the beginning of that
	;; string. this handles triple quoted, multi-line spanning
	;; strings.
	(let* ((delim (nth 3 (parse-partial-sexp bod (point))))
	       (skip (and delim (make-string 1 delim))))
	  (when skip
	    (save-excursion
	      (py-safe (search-backward skip))
	      (if (and (eq (char-before) delim)
		       (eq (char-before (1- (point))) delim))
		  (setq skip (make-string 3 delim))))
	    ;; we're looking at a triple-quoted string
	    (py-safe (search-backward skip))))
	;; now skip backward over continued lines
	(py-goto-initial-line)
	(+ (current-indentation)
	   (if (py-statement-opens-block-p)
	       py-indent-offset
	     (if (and honor-block-close-p (py-statement-closes-block-p))
		 (- py-indent-offset)
	       0)))
	)))))

(defun py-guess-indent-offset (&optional global)
  "Guess a good value for, and change, `py-indent-offset'.
By default (without a prefix arg), makes a buffer-local copy of
`py-indent-offset' with the new value.  This will not affect any other
Python buffers.  With a prefix arg, changes the global value of
`py-indent-offset'.  This affects all Python buffers (that don't have
their own buffer-local copy), both those currently existing and those
created later in the Emacs session.

Some people use a different value for `py-indent-offset' than you use.
There's no excuse for such foolishness, but sometimes you have to deal
with their ugly code anyway.  This function examines the file and sets
`py-indent-offset' to what it thinks it was when they created the
mess.

Specifically, it searches forward from the statement containing point,
looking for a line that opens a block of code.  `py-indent-offset' is
set to the difference in indentation between that line and the Python
statement following it.  If the search doesn't succeed going forward,
it's tried again going backward."
  (interactive "P")			; raw prefix arg
  (let (new-value
	(start (point))
	(restart (point))
	(found nil)
	colon-indent)
    (py-goto-initial-line)
    (while (not (or found (eobp)))
      (when (and (re-search-forward ":[ \t]*\\($\\|[#\\]\\)" nil 'move)
		 (not (py-in-literal restart)))
	(setq restart (point))
	(py-goto-initial-line)
	(if (py-statement-opens-block-p)
	    (setq found t)
	  (goto-char restart))))
    (unless found
      (goto-char start)
      (py-goto-initial-line)
      (while (not (or found (bobp)))
	(setq found (and
		     (re-search-backward ":[ \t]*\\($\\|[#\\]\\)" nil 'move)
		     (or (py-goto-initial-line) t) ; always true -- side effect
		     (py-statement-opens-block-p)))))
    (setq colon-indent (current-indentation)
	  found (and found (zerop (py-next-statement 1)))
	  new-value (- (current-indentation) colon-indent))
    (goto-char start)
    (if (not found)
	(error "Sorry, couldn't guess a value for py-indent-offset")
      (funcall (if global 'kill-local-variable 'make-local-variable)
	       'py-indent-offset)
      (setq py-indent-offset new-value)
      (message "%s value of py-indent-offset set to %d"
	       (if global "Global" "Local")
	       py-indent-offset))
    ))

(defun py-shift-region (start end count)
  (save-excursion
    (goto-char end)   (beginning-of-line) (setq end (point))
    (goto-char start) (beginning-of-line) (setq start (point))
    (indent-rigidly start end count)))

(defun py-shift-region-left (start end &optional count)
  "Shift region of Python code to the left.
The lines from the line containing the start of the current region up
to (but not including) the line containing the end of the region are
shifted to the left, by `py-indent-offset' columns.

If a prefix argument is given, the region is instead shifted by that
many columns.  With no active region, outdent only the current line.
You cannot outdent the region if any line is already at column zero."
  (interactive
   (let ((p (point))
	 (m (mark))
	 (arg current-prefix-arg))
     (if m
	 (list (min p m) (max p m) arg)
       (list p (save-excursion (forward-line 1) (point)) arg))))
  ;; if any line is at column zero, don't shift the region
  (save-excursion
    (goto-char start)
    (while (< (point) end)
      (back-to-indentation)
      (if (and (zerop (current-column))
	       (not (looking-at "\\s *$")))
	  (error "Region is at left edge."))
      (forward-line 1)))
  (py-shift-region start end (- (prefix-numeric-value
				 (or count py-indent-offset))))
  (py-keep-region-active))

(defun py-shift-region-right (start end &optional count)
  "Shift region of Python code to the right.
The lines from the line containing the start of the current region up
to (but not including) the line containing the end of the region are
shifted to the right, by `py-indent-offset' columns.

If a prefix argument is given, the region is instead shifted by that
many columns.  With no active region, indent only the current line."
  (interactive
   (let ((p (point))
	 (m (mark))
	 (arg current-prefix-arg))
     (if m
	 (list (min p m) (max p m) arg)
       (list p (save-excursion (forward-line 1) (point)) arg))))
  (py-shift-region start end (prefix-numeric-value
			      (or count py-indent-offset)))
  (py-keep-region-active))

(defun py-indent-region (start end &optional indent-offset)
  "Reindent a region of Python code.

The lines from the line containing the start of the current region up
to (but not including) the line containing the end of the region are
reindented.  If the first line of the region has a non-whitespace
character in the first column, the first line is left alone and the
rest of the region is reindented with respect to it.  Else the entire
region is reindented with respect to the (closest code or indenting
comment) statement immediately preceding the region.

This is useful when code blocks are moved or yanked, when enclosing
control structures are introduced or removed, or to reformat code
using a new value for the indentation offset.

If a numeric prefix argument is given, it will be used as the value of
the indentation offset.  Else the value of `py-indent-offset' will be
used.

Warning: The region must be consistently indented before this function
is called!  This function does not compute proper indentation from
scratch (that's impossible in Python), it merely adjusts the existing
indentation to be correct in context.

Warning: This function really has no idea what to do with
non-indenting comment lines, and shifts them as if they were indenting
comment lines.  Fixing this appears to require telepathy.

Special cases: whitespace is deleted from blank lines; continuation
lines are shifted by the same amount their initial line was shifted,
in order to preserve their relative indentation with respect to their
initial line; and comment lines beginning in column 1 are ignored."
  (interactive "*r\nP")			; region; raw prefix arg
  (save-excursion
    (goto-char end)   (beginning-of-line) (setq end (point-marker))
    (goto-char start) (beginning-of-line)
    (let ((py-indent-offset (prefix-numeric-value
			     (or indent-offset py-indent-offset)))
	  (indents '(-1))		; stack of active indent levels
	  (target-column 0)		; column to which to indent
	  (base-shifted-by 0)		; amount last base line was shifted
	  (indent-base (if (looking-at "[ \t\n]")
			   (py-compute-indentation t)
			 0))
	  ci)
      (while (< (point) end)
	(setq ci (current-indentation))
	;; figure out appropriate target column
	(cond
	 ((or (eq (following-char) ?#)	; comment in column 1
	      (looking-at "[ \t]*$"))	; entirely blank
	  (setq target-column 0))
	 ((py-continuation-line-p)	; shift relative to base line
	  (setq target-column (+ ci base-shifted-by)))
	 (t				; new base line
	  (if (> ci (car indents))	; going deeper; push it
	      (setq indents (cons ci indents))
	    ;; else we should have seen this indent before
	    (setq indents (memq ci indents)) ; pop deeper indents
	    (if (null indents)
		(error "Bad indentation in region, at line %d"
		       (save-restriction
			 (widen)
			 (1+ (count-lines 1 (point)))))))
	  (setq target-column (+ indent-base
				 (* py-indent-offset
				    (- (length indents) 2))))
	  (setq base-shifted-by (- target-column ci))))
	;; shift as needed
	(if (/= ci target-column)
	    (progn
	      (delete-horizontal-space)
	      (indent-to target-column)))
	(forward-line 1))))
  (set-marker end nil))

(defun py-comment-region (beg end &optional arg)
  "Like `comment-region' but uses double hash (`#') comment starter."
  (interactive "r\nP")
  (let ((comment-start py-block-comment-prefix))
    (comment-region beg end arg)))


;; Functions for moving point
(defun py-previous-statement (count)
  "Go to the start of previous Python statement.
If the statement at point is the i'th Python statement, goes to the
start of statement i-COUNT.  If there is no such statement, goes to the
first statement.  Returns count of statements left to move.
`Statements' do not include blank, comment, or continuation lines."
  (interactive "p")			; numeric prefix arg
  (if (< count 0) (py-next-statement (- count))
    (py-goto-initial-line)
    (let (start)
      (while (and
	      (setq start (point))	; always true -- side effect
	      (> count 0)
	      (zerop (forward-line -1))
	      (py-goto-statement-at-or-above))
	(setq count (1- count)))
      (if (> count 0) (goto-char start)))
    count))

(defun py-next-statement (count)
  "Go to the start of next Python statement.
If the statement at point is the i'th Python statement, goes to the
start of statement i+COUNT.  If there is no such statement, goes to the
last statement.  Returns count of statements left to move.  `Statements'
do not include blank, comment, or continuation lines."
  (interactive "p")			; numeric prefix arg
  (if (< count 0) (py-previous-statement (- count))
    (beginning-of-line)
    (let (start)
      (while (and
	      (setq start (point))	; always true -- side effect
	      (> count 0)
	      (py-goto-statement-below))
	(setq count (1- count)))
      (if (> count 0) (goto-char start)))
    count))

(defun py-goto-block-up (&optional nomark)
  "Move up to start of current block.
Go to the statement that starts the smallest enclosing block; roughly
speaking, this will be the closest preceding statement that ends with a
colon and is indented less than the statement you started on.  If
successful, also sets the mark to the starting point.

`\\[py-mark-block]' can be used afterward to mark the whole code
block, if desired.

If called from a program, the mark will not be set if optional argument
NOMARK is not nil."
  (interactive)
  (let ((start (point))
	(found nil)
	initial-indent)
    (py-goto-initial-line)
    ;; if on blank or non-indenting comment line, use the preceding stmt
    (if (looking-at "[ \t]*\\($\\|#[^ \t\n]\\)")
	(progn
	  (py-goto-statement-at-or-above)
	  (setq found (py-statement-opens-block-p))))
    ;; search back for colon line indented less
    (setq initial-indent (current-indentation))
    (if (zerop initial-indent)
	;; force fast exit
	(goto-char (point-min)))
    (while (not (or found (bobp)))
      (setq found
	    (and
	     (re-search-backward ":[ \t]*\\($\\|[#\\]\\)" nil 'move)
	     (or (py-goto-initial-line) t) ; always true -- side effect
	     (< (current-indentation) initial-indent)
	     (py-statement-opens-block-p))))
    (if found
	(progn
	  (or nomark (push-mark start))
	  (back-to-indentation))
      (goto-char start)
      (error "Enclosing block not found"))))

(defun beginning-of-python-def-or-class (&optional class)
  "Move point to start of def (or class, with prefix arg).

Searches back for the closest preceding `def'.  If you supply a prefix
arg, looks for a `class' instead.  The docs assume the `def' case;
just substitute `class' for `def' for the other case.

If point is in a def statement already, and after the `d', simply
moves point to the start of the statement.

Else (point is not in a def statement, or at or before the `d' of a
def statement), searches for the closest preceding def statement, and
leaves point at its start.  If no such statement can be found, leaves
point at the start of the buffer.

Returns t iff a def statement is found by these rules.

Note that doing this command repeatedly will take you closer to the
start of the buffer each time.

If you want to mark the current def/class, see
`\\[py-mark-def-or-class]'."
  (interactive "P")			; raw prefix arg
  (let ((at-or-before-p (<= (current-column) (current-indentation)))
	(start-of-line (progn (beginning-of-line) (point)))
	(start-of-stmt (progn (py-goto-initial-line) (point))))
    (if (or (/= start-of-stmt start-of-line)
	    (not at-or-before-p))
	(end-of-line))			; OK to match on this line
    (re-search-backward (if class "^[ \t]*class\\>" "^[ \t]*def\\>")
			nil 'move)))

(defun end-of-python-def-or-class (&optional class)
  "Move point beyond end of def (or class, with prefix arg) body.

By default, looks for an appropriate `def'.  If you supply a prefix arg,
looks for a `class' instead.  The docs assume the `def' case; just
substitute `class' for `def' for the other case.

If point is in a def statement already, this is the def we use.

Else if the def found by `\\[beginning-of-python-def-or-class]'
contains the statement you started on, that's the def we use.

Else we search forward for the closest following def, and use that.

If a def can be found by these rules, point is moved to the start of
the line immediately following the def block, and the position of the
start of the def is returned.

Else point is moved to the end of the buffer, and nil is returned.

Note that doing this command repeatedly will take you closer to the
end of the buffer each time.

If you want to mark the current def/class, see
`\\[py-mark-def-or-class]'."
  (interactive "P")			; raw prefix arg
  (let ((start (progn (py-goto-initial-line) (point)))
	(which (if class "class" "def"))
	(state 'not-found))
    ;; move point to start of appropriate def/class
    (if (looking-at (concat "[ \t]*" which "\\>")) ; already on one
	(setq state 'at-beginning)
      ;; else see if beginning-of-python-def-or-class hits container
      (if (and (beginning-of-python-def-or-class class)
	       (progn (py-goto-beyond-block)
		      (> (point) start)))
	  (setq state 'at-end)
	;; else search forward
	(goto-char start)
	(if (re-search-forward (concat "^[ \t]*" which "\\>") nil 'move)
	    (progn (setq state 'at-beginning)
		   (beginning-of-line)))))
    (cond
     ((eq state 'at-beginning) (py-goto-beyond-block) t)
     ((eq state 'at-end) t)
     ((eq state 'not-found) nil)
     (t (error "internal error in end-of-python-def-or-class")))))


;; Functions for marking regions
(defun py-mark-block (&optional extend just-move)
  "Mark following block of lines.  With prefix arg, mark structure.
Easier to use than explain.  It sets the region to an `interesting'
block of succeeding lines.  If point is on a blank line, it goes down to
the next non-blank line.  That will be the start of the region.  The end
of the region depends on the kind of line at the start:

 - If a comment, the region will include all succeeding comment lines up
   to (but not including) the next non-comment line (if any).

 - Else if a prefix arg is given, and the line begins one of these
   structures:

     if elif else try except finally for while def class

   the region will be set to the body of the structure, including
   following blocks that `belong' to it, but excluding trailing blank
   and comment lines.  E.g., if on a `try' statement, the `try' block
   and all (if any) of the following `except' and `finally' blocks
   that belong to the `try' structure will be in the region.  Ditto
   for if/elif/else, for/else and while/else structures, and (a bit
   degenerate, since they're always one-block structures) def and
   class blocks.

 - Else if no prefix argument is given, and the line begins a Python
   block (see list above), and the block is not a `one-liner' (i.e.,
   the statement ends with a colon, not with code), the region will
   include all succeeding lines up to (but not including) the next
   code statement (if any) that's indented no more than the starting
   line, except that trailing blank and comment lines are excluded.
   E.g., if the starting line begins a multi-statement `def'
   structure, the region will be set to the full function definition,
   but without any trailing `noise' lines.

 - Else the region will include all succeeding lines up to (but not
   including) the next blank line, or code or indenting-comment line
   indented strictly less than the starting line.  Trailing indenting
   comment lines are included in this case, but not trailing blank
   lines.

A msg identifying the location of the mark is displayed in the echo
area; or do `\\[exchange-point-and-mark]' to flip down to the end.

If called from a program, optional argument EXTEND plays the role of
the prefix arg, and if optional argument JUST-MOVE is not nil, just
moves to the end of the block (& does not set mark or display a msg)."
  (interactive "P")			; raw prefix arg
  (py-goto-initial-line)
  ;; skip over blank lines
  (while (and
	  (looking-at "[ \t]*$")	; while blank line
	  (not (eobp)))			; & somewhere to go
    (forward-line 1))
  (if (eobp)
      (error "Hit end of buffer without finding a non-blank stmt"))
  (let ((initial-pos (point))
	(initial-indent (current-indentation))
	last-pos			; position of last stmt in region
	(followers
	 '((if elif else) (elif elif else) (else)
	   (try except finally) (except except) (finally)
	   (for else) (while else)
	   (def) (class) ) )
	first-symbol next-symbol)

    (cond
     ;; if comment line, suck up the following comment lines
     ((looking-at "[ \t]*#")
      (re-search-forward "^[ \t]*[^ \t#]" nil 'move) ; look for non-comment
      (re-search-backward "^[ \t]*#")	; and back to last comment in block
      (setq last-pos (point)))

     ;; else if line is a block line and EXTEND given, suck up
     ;; the whole structure
     ((and extend
	   (setq first-symbol (py-suck-up-first-keyword) )
	   (assq first-symbol followers))
      (while (and
	      (or (py-goto-beyond-block) t) ; side effect
	      (forward-line -1)		; side effect
	      (setq last-pos (point))	; side effect
	      (py-goto-statement-below)
	      (= (current-indentation) initial-indent)
	      (setq next-symbol (py-suck-up-first-keyword))
	      (memq next-symbol (cdr (assq first-symbol followers))))
	(setq first-symbol next-symbol)))

     ;; else if line *opens* a block, search for next stmt indented <=
     ((py-statement-opens-block-p)
      (while (and
	      (setq last-pos (point))	; always true -- side effect
	      (py-goto-statement-below)
	      (> (current-indentation) initial-indent))
	nil))

     ;; else plain code line; stop at next blank line, or stmt or
     ;; indenting comment line indented <
     (t
      (while (and
	      (setq last-pos (point))	; always true -- side effect
	      (or (py-goto-beyond-final-line) t)
	      (not (looking-at "[ \t]*$")) ; stop at blank line
	      (or
	       (>= (current-indentation) initial-indent)
	       (looking-at "[ \t]*#[^ \t\n]"))) ; ignore non-indenting #
	nil)))

    ;; skip to end of last stmt
    (goto-char last-pos)
    (py-goto-beyond-final-line)

    ;; set mark & display
    (if just-move
	()				; just return
      (push-mark (point) 'no-msg)
      (forward-line -1)
      (message "Mark set after: %s" (py-suck-up-leading-text))
      (goto-char initial-pos))))

(defun py-mark-def-or-class (&optional class)
  "Set region to body of def (or class, with prefix arg) enclosing point.
Pushes the current mark, then point, on the mark ring (all language
modes do this, but although it's handy it's never documented ...).

In most Emacs language modes, this function bears at least a
hallucinogenic resemblance to `\\[end-of-python-def-or-class]' and
`\\[beginning-of-python-def-or-class]'.

And in earlier versions of Python mode, all 3 were tightly connected.
Turned out that was more confusing than useful: the `goto start' and
`goto end' commands are usually used to search through a file, and
people expect them to act a lot like `search backward' and `search
forward' string-search commands.  But because Python `def' and `class'
can nest to arbitrary levels, finding the smallest def containing
point cannot be done via a simple backward search: the def containing
point may not be the closest preceding def, or even the closest
preceding def that's indented less.  The fancy algorithm required is
appropriate for the usual uses of this `mark' command, but not for the
`goto' variations.

So the def marked by this command may not be the one either of the
`goto' commands find: If point is on a blank or non-indenting comment
line, moves back to start of the closest preceding code statement or
indenting comment line.  If this is a `def' statement, that's the def
we use.  Else searches for the smallest enclosing `def' block and uses
that.  Else signals an error.

When an enclosing def is found: The mark is left immediately beyond
the last line of the def block.  Point is left at the start of the
def, except that: if the def is preceded by a number of comment lines
followed by (at most) one optional blank line, point is left at the
start of the comments; else if the def is preceded by a blank line,
point is left at its start.

The intent is to mark the containing def/class and its associated
documentation, to make moving and duplicating functions and classes
pleasant."
  (interactive "P")			; raw prefix arg
  (let ((start (point))
	(which (if class "class" "def")))
    (push-mark start)
    (if (not (py-go-up-tree-to-keyword which))
	(progn (goto-char start)
	       (error "Enclosing %s not found" which))
      ;; else enclosing def/class found
      (setq start (point))
      (py-goto-beyond-block)
      (push-mark (point))
      (goto-char start)
      (if (zerop (forward-line -1))	; if there is a preceding line
	  (progn
	    (if (looking-at "[ \t]*$")	; it's blank
		(setq start (point))	; so reset start point
	      (goto-char start))	; else try again
	    (if (zerop (forward-line -1))
		(if (looking-at "[ \t]*#") ; a comment
		    ;; look back for non-comment line
		    ;; tricky: note that the regexp matches a blank
		    ;; line, cuz \n is in the 2nd character class
		    (and
		     (re-search-backward "^[ \t]*[^ \t#]" nil 'move)
		     (forward-line 1))
		  ;; no comment, so go back
		  (goto-char start)))))))
  (exchange-point-and-mark)
  (py-keep-region-active))

;; ripped from cc-mode
(defun py-forward-into-nomenclature (&optional arg)
  "Move forward to end of a nomenclature section or word.
With arg, to it arg times.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (let ((case-fold-search nil))
    (if (> arg 0)
	(re-search-forward
	 "\\(\\W\\|[_]\\)*\\([A-Z]*[a-z0-9]*\\)"
	 (point-max) t arg)
      (while (and (< arg 0)
		  (re-search-backward
		   "\\(\\W\\|[a-z0-9]\\)[A-Z]+\\|\\(\\W\\|[_]\\)\\w+"
		   (point-min) 0))
	(forward-char 1)
	(setq arg (1+ arg)))))
  (py-keep-region-active))

(defun py-backward-into-nomenclature (&optional arg)
  "Move backward to beginning of a nomenclature section or word.
With optional ARG, move that many times.  If ARG is negative, move
forward.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (py-forward-into-nomenclature (- arg))
  (py-keep-region-active))



;; Documentation functions

;; dump the long form of the mode blurb; does the usual doc escapes,
;; plus lines of the form ^[vc]:name$ to suck variable & command docs
;; out of the right places, along with the keys they're on & current
;; values
(defun py-dump-help-string (str)
  (with-output-to-temp-buffer "*Help*"
    (let ((locals (buffer-local-variables))
	  funckind funcname func funcdoc
	  (start 0) mstart end
	  keys )
      (while (string-match "^%\\([vc]\\):\\(.+\\)\n" str start)
	(setq mstart (match-beginning 0)  end (match-end 0)
	      funckind (substring str (match-beginning 1) (match-end 1))
	      funcname (substring str (match-beginning 2) (match-end 2))
	      func (intern funcname))
	(princ (substitute-command-keys (substring str start mstart)))
	(cond
	 ((equal funckind "c")		; command
	  (setq funcdoc (documentation func)
		keys (concat
		      "Key(s): "
		      (mapconcat 'key-description
				 (where-is-internal func py-mode-map)
				 ", "))))
	 ((equal funckind "v")		; variable
	  (setq funcdoc (documentation-property func 'variable-documentation)
		keys (if (assq func locals)
			 (concat
			  "Local/Global values: "
			  (prin1-to-string (symbol-value func))
			  " / "
			  (prin1-to-string (default-value func)))
		       (concat
			"Value: "
			(prin1-to-string (symbol-value func))))))
	 (t				; unexpected
	  (error "Error in py-dump-help-string, tag `%s'" funckind)))
	(princ (format "\n-> %s:\t%s\t%s\n\n"
		       (if (equal funckind "c") "Command" "Variable")
		       funcname keys))
	(princ funcdoc)
	(terpri)
	(setq start end))
      (princ (substitute-command-keys (substring str start))))
    (print-help-return-message)))

(defun py-describe-mode ()
  "Dump long form of Python-mode docs."
  (interactive)
  (py-dump-help-string "Major mode for editing Python files.
Knows about Python indentation, tokens, comments and continuation lines.
Paragraphs are separated by blank lines only.

Major sections below begin with the string `@'; specific function and
variable docs begin with `->'.

@EXECUTING PYTHON CODE

\\[py-execute-buffer]\tsends the entire buffer to the Python interpreter
\\[py-execute-region]\tsends the current region
\\[py-shell]\tstarts a Python interpreter window; this will be used by
\tsubsequent \\[py-execute-buffer] or \\[py-execute-region] commands
%c:py-execute-buffer
%c:py-execute-region
%c:py-shell

@VARIABLES

py-indent-offset\tindentation increment
py-block-comment-prefix\tcomment string used by comment-region

py-python-command\tshell command to invoke Python interpreter
py-scroll-process-buffer\talways scroll Python process buffer
py-temp-directory\tdirectory used for temp files (if needed)

py-beep-if-tab-change\tring the bell if tab-width is changed
%v:py-indent-offset
%v:py-block-comment-prefix
%v:py-python-command
%v:py-scroll-process-buffer
%v:py-temp-directory
%v:py-beep-if-tab-change

@KINDS OF LINES

Each physical line in the file is either a `continuation line' (the
preceding line ends with a backslash that's not part of a comment, or
the paren/bracket/brace nesting level at the start of the line is
non-zero, or both) or an `initial line' (everything else).

An initial line is in turn a `blank line' (contains nothing except
possibly blanks or tabs), a `comment line' (leftmost non-blank
character is `#'), or a `code line' (everything else).

Comment Lines

Although all comment lines are treated alike by Python, Python mode
recognizes two kinds that act differently with respect to indentation.

An `indenting comment line' is a comment line with a blank, tab or
nothing after the initial `#'.  The indentation commands (see below)
treat these exactly as if they were code lines: a line following an
indenting comment line will be indented like the comment line.  All
other comment lines (those with a non-whitespace character immediately
following the initial `#') are `non-indenting comment lines', and
their indentation is ignored by the indentation commands.

Indenting comment lines are by far the usual case, and should be used
whenever possible.  Non-indenting comment lines are useful in cases
like these:

\ta = b   # a very wordy single-line comment that ends up being
\t        #... continued onto another line

\tif a == b:
##\t\tprint 'panic!' # old code we've `commented out'
\t\treturn a

Since the `#...' and `##' comment lines have a non-whitespace
character following the initial `#', Python mode ignores them when
computing the proper indentation for the next line.

Continuation Lines and Statements

The Python-mode commands generally work on statements instead of on
individual lines, where a `statement' is a comment or blank line, or a
code line and all of its following continuation lines (if any)
considered as a single logical unit.  The commands in this mode
generally (when it makes sense) automatically move to the start of the
statement containing point, even if point happens to be in the middle
of some continuation line.


@INDENTATION

Primarily for entering new code:
\t\\[indent-for-tab-command]\t indent line appropriately
\t\\[py-newline-and-indent]\t insert newline, then indent
\t\\[py-electric-backspace]\t reduce indentation, or delete single character

Primarily for reindenting existing code:
\t\\[py-guess-indent-offset]\t guess py-indent-offset from file content; change locally
\t\\[universal-argument] \\[py-guess-indent-offset]\t ditto, but change globally

\t\\[py-indent-region]\t reindent region to match its context
\t\\[py-shift-region-left]\t shift region left by py-indent-offset
\t\\[py-shift-region-right]\t shift region right by py-indent-offset

Unlike most programming languages, Python uses indentation, and only
indentation, to specify block structure.  Hence the indentation supplied
automatically by Python-mode is just an educated guess:  only you know
the block structure you intend, so only you can supply correct
indentation.

The \\[indent-for-tab-command] and \\[py-newline-and-indent] keys try to suggest plausible indentation, based on
the indentation of preceding statements.  E.g., assuming
py-indent-offset is 4, after you enter
\tif a > 0: \\[py-newline-and-indent]
the cursor will be moved to the position of the `_' (_ is not a
character in the file, it's just used here to indicate the location of
the cursor):
\tif a > 0:
\t    _
If you then enter `c = d' \\[py-newline-and-indent], the cursor will move
to
\tif a > 0:
\t    c = d
\t    _
Python-mode cannot know whether that's what you intended, or whether
\tif a > 0:
\t    c = d
\t_
was your intent.  In general, Python-mode either reproduces the
indentation of the (closest code or indenting-comment) preceding
statement, or adds an extra py-indent-offset blanks if the preceding
statement has `:' as its last significant (non-whitespace and non-
comment) character.  If the suggested indentation is too much, use
\\[py-electric-backspace] to reduce it.

Continuation lines are given extra indentation.  If you don't like the
suggested indentation, change it to something you do like, and Python-
mode will strive to indent later lines of the statement in the same way.

If a line is a continuation line by virtue of being in an unclosed
paren/bracket/brace structure (`list', for short), the suggested
indentation depends on whether the current line contains the first item
in the list.  If it does, it's indented py-indent-offset columns beyond
the indentation of the line containing the open bracket.  If you don't
like that, change it by hand.  The remaining items in the list will mimic
whatever indentation you give to the first item.

If a line is a continuation line because the line preceding it ends with
a backslash, the third and following lines of the statement inherit their
indentation from the line preceding them.  The indentation of the second
line in the statement depends on the form of the first (base) line:  if
the base line is an assignment statement with anything more interesting
than the backslash following the leftmost assigning `=', the second line
is indented two columns beyond that `='.  Else it's indented to two
columns beyond the leftmost solid chunk of non-whitespace characters on
the base line.

Warning:  indent-region should not normally be used!  It calls \\[indent-for-tab-command]
repeatedly, and as explained above, \\[indent-for-tab-command] can't guess the block
structure you intend.
%c:indent-for-tab-command
%c:py-newline-and-indent
%c:py-electric-backspace


The next function may be handy when editing code you didn't write:
%c:py-guess-indent-offset


The remaining `indent' functions apply to a region of Python code.  They
assume the block structure (equals indentation, in Python) of the region
is correct, and alter the indentation in various ways while preserving
the block structure:
%c:py-indent-region
%c:py-shift-region-left
%c:py-shift-region-right

@MARKING & MANIPULATING REGIONS OF CODE

\\[py-mark-block]\t mark block of lines
\\[py-mark-def-or-class]\t mark smallest enclosing def
\\[universal-argument] \\[py-mark-def-or-class]\t mark smallest enclosing class
\\[comment-region]\t comment out region of code
\\[universal-argument] \\[comment-region]\t uncomment region of code
%c:py-mark-block
%c:py-mark-def-or-class
%c:comment-region

@MOVING POINT

\\[py-previous-statement]\t move to statement preceding point
\\[py-next-statement]\t move to statement following point
\\[py-goto-block-up]\t move up to start of current block
\\[beginning-of-python-def-or-class]\t move to start of def
\\[universal-argument] \\[beginning-of-python-def-or-class]\t move to start of class
\\[end-of-python-def-or-class]\t move to end of def
\\[universal-argument] \\[end-of-python-def-or-class]\t move to end of class

The first two move to one statement beyond the statement that contains
point.  A numeric prefix argument tells them to move that many
statements instead.  Blank lines, comment lines, and continuation lines
do not count as `statements' for these commands.  So, e.g., you can go
to the first code statement in a file by entering
\t\\[beginning-of-buffer]\t to move to the top of the file
\t\\[py-next-statement]\t to skip over initial comments and blank lines
Or do `\\[py-previous-statement]' with a huge prefix argument.
%c:py-previous-statement
%c:py-next-statement
%c:py-goto-block-up
%c:beginning-of-python-def-or-class
%c:end-of-python-def-or-class

@LITTLE-KNOWN EMACS COMMANDS PARTICULARLY USEFUL IN PYTHON MODE

`\\[indent-new-comment-line]' is handy for entering a multi-line comment.

`\\[set-selective-display]' with a `small' prefix arg is ideally suited for viewing the
overall class and def structure of a module.

`\\[back-to-indentation]' moves point to a line's first non-blank character.

`\\[indent-relative]' is handy for creating odd indentation.

@OTHER EMACS HINTS

If you don't like the default value of a variable, change its value to
whatever you do like by putting a `setq' line in your .emacs file.
E.g., to set the indentation increment to 4, put this line in your
.emacs:
\t(setq  py-indent-offset  4)
To see the value of a variable, do `\\[describe-variable]' and enter the variable
name at the prompt.

When entering a key sequence like `C-c C-n', it is not necessary to
release the CONTROL key after doing the `C-c' part -- it suffices to
press the CONTROL key, press and release `c' (while still holding down
CONTROL), press and release `n' (while still holding down CONTROL), &
then release CONTROL.

Entering Python mode calls with no arguments the value of the variable
`python-mode-hook', if that value exists and is not nil; for backward
compatibility it also tries `py-mode-hook'; see the `Hooks' section of
the Elisp manual for details.

Obscure:  When python-mode is first loaded, it looks for all bindings
to newline-and-indent in the global keymap, and shadows them with
local bindings to py-newline-and-indent."))


;; Helper functions
(defvar py-parse-state-re
  (concat
   "^[ \t]*\\(if\\|elif\\|else\\|while\\|def\\|class\\)\\>"
   "\\|"
   "^[^ #\t\n]"))

;; returns the parse state at point (see parse-partial-sexp docs)
(defun py-parse-state ()
  (save-excursion
    (let ((here (point))
	  pps done)
      (while (not done)
	;; back up to the first preceding line (if any; else start of
	;; buffer) that begins with a popular Python keyword, or a
	;; non- whitespace and non-comment character.  These are good
	;; places to start parsing to see whether where we started is
	;; at a non-zero nesting level.  It may be slow for people who
	;; write huge code blocks or huge lists ... tough beans.
	(re-search-backward py-parse-state-re nil 'move)
	(beginning-of-line)
	;; In XEmacs, we have a much better way to test for whether
	;; we're in a triple-quoted string or not.  Emacs does not
	;; have this built-in function, which is it's loss because
	;; without scanning from the beginning of the buffer, there's
	;; no accurate way to determine this otherwise.
	(if (not (fboundp 'buffer-syntactic-context))
	    ;; Emacs
	    (progn
	      (save-excursion (setq pps (parse-partial-sexp (point) here)))
	      ;; make sure we don't land inside a triple-quoted string
	      (setq done (or (not (nth 3 pps))
			     (bobp))))
	  ;; XEmacs
	  (setq done (or (not (buffer-syntactic-context))
			 (bobp)))
	  (when done
	    (setq pps (parse-partial-sexp (point) here)))
	  ))
      pps)))

;; if point is at a non-zero nesting level, returns the number of the
;; character that opens the smallest enclosing unclosed list; else
;; returns nil.
(defun py-nesting-level ()
  (let ((status (py-parse-state)))
    (if (zerop (car status))
	nil				; not in a nest
      (car (cdr status)))))		; char# of open bracket

;; t iff preceding line ends with backslash that's not in a comment
(defun py-backslash-continuation-line-p ()
  (save-excursion
    (beginning-of-line)
    (and
     ;; use a cheap test first to avoid the regexp if possible
     ;; use 'eq' because char-after may return nil
     (eq (char-after (- (point) 2)) ?\\ )
     ;; make sure; since eq test passed, there is a preceding line
     (forward-line -1)			; always true -- side effect
     (looking-at py-continued-re))))

;; t iff current line is a continuation line
(defun py-continuation-line-p ()
  (save-excursion
    (beginning-of-line)
    (or (py-backslash-continuation-line-p)
	(py-nesting-level))))

;; go to initial line of current statement; usually this is the line
;; we're on, but if we're on the 2nd or following lines of a
;; continuation block, we need to go up to the first line of the
;; block.
;;
;; Tricky: We want to avoid quadratic-time behavior for long continued
;; blocks, whether of the backslash or open-bracket varieties, or a
;; mix of the two.  The following manages to do that in the usual
;; cases.
;;
;; Also, if we're sitting inside a triple quoted string, this will
;; drop us at the line that begins the string.
(defun py-goto-initial-line ()
  (let (open-bracket-pos)
    (while (py-continuation-line-p)
      (beginning-of-line)
      (if (py-backslash-continuation-line-p)
	  (while (py-backslash-continuation-line-p)
	    (forward-line -1))
	;; else zip out of nested brackets/braces/parens
	(while (setq open-bracket-pos (py-nesting-level))
	  (goto-char open-bracket-pos)))))
  (beginning-of-line))

;; go to point right beyond final line of current statement; usually
;; this is the start of the next line, but if this is a multi-line
;; statement we need to skip over the continuation lines.  Tricky:
;; Again we need to be clever to avoid quadratic time behavior.
(defun py-goto-beyond-final-line ()
  (forward-line 1)
  (let (state)
    (while (and (py-continuation-line-p)
		(not (eobp)))
      ;; skip over the backslash flavor
      (while (and (py-backslash-continuation-line-p)
		  (not (eobp)))
	(forward-line 1))
      ;; if in nest, zip to the end of the nest
      (setq state (py-parse-state))
      (if (and (not (zerop (car state)))
	       (not (eobp)))
	  (progn
	    (parse-partial-sexp (point) (point-max) 0 nil state)
	    (forward-line 1))))))

;; t iff statement opens a block == iff it ends with a colon that's
;; not in a comment.  point should be at the start of a statement
(defun py-statement-opens-block-p ()
  (save-excursion
    (let ((start (point))
	  (finish (progn (py-goto-beyond-final-line) (1- (point))))
	  (searching t)
	  (answer nil)
	  state)
      (goto-char start)
      (while searching
	;; look for a colon with nothing after it except whitespace, and
	;; maybe a comment
	(if (re-search-forward ":\\([ \t]\\|\\\\\n\\)*\\(#.*\\)?$"
			       finish t)
	    (if (eq (point) finish)	; note: no `else' clause; just
					; keep searching if we're not at
					; the end yet
		;; sure looks like it opens a block -- but it might
		;; be in a comment
		(progn
		  (setq searching nil)	; search is done either way
		  (setq state (parse-partial-sexp start
						  (match-beginning 0)))
		  (setq answer (not (nth 4 state)))))
	  ;; search failed: couldn't find another interesting colon
	  (setq searching nil)))
      answer)))

(defun py-statement-closes-block-p ()
  ;; true iff the current statement `closes' a block == the line
  ;; starts with `return', `raise', `break', `continue', and `pass'.
  ;; doesn't catch embedded statements
  (let ((here (point)))
    (back-to-indentation)
    (prog1
	(looking-at (concat py-block-closing-keywords-re "\\>"))
      (goto-char here))))

;; go to point right beyond final line of block begun by the current
;; line.  This is the same as where py-goto-beyond-final-line goes
;; unless we're on colon line, in which case we go to the end of the
;; block.  assumes point is at bolp
(defun py-goto-beyond-block ()
  (if (py-statement-opens-block-p)
      (py-mark-block nil 'just-move)
    (py-goto-beyond-final-line)))

;; go to start of first statement (not blank or comment or
;; continuation line) at or preceding point.  returns t if there is
;; one, else nil
(defun py-goto-statement-at-or-above ()
  (py-goto-initial-line)
  (if (looking-at py-blank-or-comment-re)
      ;; skip back over blank & comment lines
      ;; note:  will skip a blank or comment line that happens to be
      ;; a continuation line too
      (if (re-search-backward "^[ \t]*[^ \t#\n]" nil t)
	  (progn (py-goto-initial-line) t)
	nil)
    t))

;; go to start of first statement (not blank or comment or
;; continuation line) following the statement containing point returns
;; t if there is one, else nil
(defun py-goto-statement-below ()
  (beginning-of-line)
  (let ((start (point)))
    (py-goto-beyond-final-line)
    (while (and
	    (looking-at py-blank-or-comment-re)
	    (not (eobp)))
      (forward-line 1))
    (if (eobp)
	(progn (goto-char start) nil)
      t)))

;; go to start of statement, at or preceding point, starting with
;; keyword KEY.  Skips blank lines and non-indenting comments upward
;; first.  If that statement starts with KEY, done, else go back to
;; first enclosing block starting with KEY.  If successful, leaves
;; point at the start of the KEY line & returns t.  Else leaves point
;; at an undefined place & returns nil.
(defun py-go-up-tree-to-keyword (key)
  ;; skip blanks and non-indenting #
  (py-goto-initial-line)
  (while (and
	  (looking-at "[ \t]*\\($\\|#[^ \t\n]\\)")
	  (zerop (forward-line -1)))	; go back
    nil)
  (py-goto-initial-line)
  (let* ((re (concat "[ \t]*" key "\\b"))
	 (case-fold-search nil)		; let* so looking-at sees this
	 (found (looking-at re))
	 (dead nil))
    (while (not (or found dead))
      (condition-case nil		; in case no enclosing block
	  (py-goto-block-up 'no-mark)
	(error (setq dead t)))
      (or dead (setq found (looking-at re))))
    (beginning-of-line)
    found))

;; return string in buffer from start of indentation to end of line;
;; prefix "..." if leading whitespace was skipped
(defun py-suck-up-leading-text ()
  (save-excursion
    (back-to-indentation)
    (concat
     (if (bolp) "" "...")
     (buffer-substring (point) (progn (end-of-line) (point))))))

;; assuming point at bolp, return first keyword ([a-z]+) on the line,
;; as a Lisp symbol; return nil if none
(defun py-suck-up-first-keyword ()
  (let ((case-fold-search nil))
    (if (looking-at "[ \t]*\\([a-z]+\\)\\b")
	(intern (buffer-substring (match-beginning 1) (match-end 1)))
      nil)))

(defun py-current-defun ()
  ;; tell add-log.el how to find the current function/method/variable
  (save-excursion
    (if (re-search-backward py-defun-start-re nil t)
	(or (match-string 3)
	    (let ((method (match-string 2)))
	      (if (and (not (zerop (length (match-string 1))))
		       (re-search-backward py-class-start-re nil t))
		  (concat (match-string 1) "." method)
		method)))
      nil)))


(defconst py-help-address "python-mode@python.org"
  "Address accepting submission of bug reports.")

(defun py-version ()
  "Echo the current version of `python-mode' in the minibuffer."
  (interactive)
  (message "Using `python-mode' version %s" py-version)
  (py-keep-region-active))

;; only works under Emacs 19
;(eval-when-compile
;  (require 'reporter))

(defun py-submit-bug-report (enhancement-p)
  "Submit via mail a bug report on `python-mode'.
With \\[universal-argument] just submit an enhancement request."
  (interactive
   (list (not (y-or-n-p
	       "Is this a bug report? (hit `n' to send other comments) "))))
  (let ((reporter-prompt-for-summary-p (if enhancement-p
					   "(Very) brief summary: "
					 t)))
    (require 'reporter)
    (reporter-submit-bug-report
     py-help-address			;address
     (concat "python-mode " py-version)	;pkgname
     ;; varlist
     (if enhancement-p nil
       '(py-python-command
	 py-indent-offset
	 py-block-comment-prefix
	 py-scroll-process-buffer
	 py-temp-directory
	 py-beep-if-tab-change))
     nil				;pre-hooks
     nil				;post-hooks
     "Dear Barry,")			;salutation
    (if enhancement-p nil
      (set-mark (point))
      (insert 
"Please replace this text with a sufficiently large code sample\n\
and an exact recipe so that I can reproduce your problem.  Failure\n\
to do so may mean a greater delay in fixing your bug.\n\n")
      (exchange-point-and-mark)
      (py-keep-region-active))))


(defun py-kill-emacs-hook ()
  (mapcar #'(lambda (filename)
	      (py-safe (delete-file filename)))
	  py-file-queue))

;; arrange to kill temp files when Emacs exists
(add-hook 'kill-emacs-hook 'py-kill-emacs-hook)



(provide 'python-mode)
;;; python-mode.el ends here
