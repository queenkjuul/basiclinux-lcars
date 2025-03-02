; web-browser.scm -- install bookmarks
; Copyright (c) 1997 Misha Dynin <misha@xcf.berkeley.edu>
; Note: script-fu must be able to handle zero argument procedures to
;       process this file!
;
; For more information see webbrowser.readme or
;   http://www.xcf.berkeley.edu/~misha/gimp/
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

(set! web-browser-new-window 0)

(define (script-fu-bookmark url)
  (extension-web-browser 1 url web-browser-new-window))

(define (bookmark-register proc menu help)
  (script-fu-register proc menu help
		    "Misha Dynin <misha@xcf.berkeley.edu>"
		    "Misha Dynin"
		    "1997"
		    ""))

(define (script-fu-bookmark-1)
    (script-fu-bookmark "http://www.gimp.org/the_gimp.html"))

(bookmark-register  "script-fu-bookmark-1"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/The GIMP"
		    "Link to http://www.gimp.org/the_gimp.html")

(define (script-fu-bookmark-2)
    (script-fu-bookmark "http://www.gimp.org/docs.html"))

(bookmark-register  "script-fu-bookmark-2"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/Documenation"
		    "Link to http://www.gimp.org/docs.html")

(define (script-fu-bookmark-3)
    (script-fu-bookmark "http://www.gimp.org/mailing_list.html"))

(bookmark-register  "script-fu-bookmark-3"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/Mailing Lists"
		    "Link to http://www.gimp.org/mailing_list.html")

(define (script-fu-bookmark-4)
    (script-fu-bookmark "http://www.gimp.org/data.html"))

(bookmark-register  "script-fu-bookmark-4"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/Resources"
		    "Link to http://www.gimp.org/data.html")

(define (script-fu-bookmark-5)
    (script-fu-bookmark "http://www.gimp.org/download.html"))

(bookmark-register  "script-fu-bookmark-5"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/Download"
		    "Link to http://www.gimp.org/download.html")

(define (script-fu-bookmark-6)
    (script-fu-bookmark "http://www.gimp.org/art.html"))

(bookmark-register  "script-fu-bookmark-6"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/GIMP Art"
		    "Link to http://www.gimp.org/art.html")

(define (script-fu-bookmark-7)
    (script-fu-bookmark "http://www.gimp.org/links.html"))

(bookmark-register  "script-fu-bookmark-7"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/Links"
		    "Link to http://www.gimp.org/links.html")

(define (script-fu-bookmark-8)
    (script-fu-bookmark "http://www.gimp.org/gtk/"))

(bookmark-register  "script-fu-bookmark-8"
		    "<Toolbox>/Xtns/Web Browser/GIMP.ORG/GTK"
		    "Link to http://www.gimp.org/gtk/")

(define (script-fu-bookmark-10)
    (script-fu-bookmark "http://xach.dorknet.com/gimp/news/"))

(bookmark-register  "script-fu-bookmark-10"
		    "<Toolbox>/Xtns/Web Browser/GIMP News"
		    "Link to http://xach.dorknet.com/gimp/news/")

(define (script-fu-bookmark-11)
    (script-fu-bookmark "http://gimp.foebud.org/registry/"))

(bookmark-register  "script-fu-bookmark-11"
		    "<Toolbox>/Xtns/Web Browser/Plug-In Registry"
		    "Link to http://gimp.foebud.org/registry/")

(define (script-fu-bookmark-12)
    (script-fu-bookmark "http://www.rru.com/~meo/gimp/faq-user.html"))

(bookmark-register  "script-fu-bookmark-12"
		    "<Toolbox>/Xtns/Web Browser/User FAQ"
		    "Link to http://www.rru.com/~meo/gimp/faq-user.html")

(define (script-fu-bookmark-13)
    (script-fu-bookmark "http://www.rru.com/~meo/gimp/faq-dev.html"))

(bookmark-register  "script-fu-bookmark-13"
		    "<Toolbox>/Xtns/Web Browser/Developer FAQ"
		    "Link to http://www.rru.com/~meo/gimp/faq-dev.html")

(define (script-fu-bookmark-14)
    (script-fu-bookmark "http://manual.gimp.org/"))

(bookmark-register  "script-fu-bookmark-14"
		    "<Toolbox>/Xtns/Web Browser/GIMP Manual"
		    "Link to http://manual.gimp.org/")

(define (script-fu-bookmark-15)
    (script-fu-bookmark "http://abattoir.cc.ndsu.nodak.edu/~nem/gimp/tuts/"))

(bookmark-register  "script-fu-bookmark-15"
		    "<Toolbox>/Xtns/Web Browser/GIMP Tutorials"
		    "Link to http://abattoir.cc.ndsu.nodak.edu/~nem/gimp/tuts/")

(define (script-fu-bookmark-16)
    (script-fu-bookmark "http://www.wilberworks.com/bugs.cgi"))

(bookmark-register  "script-fu-bookmark-16"
		    "<Toolbox>/Xtns/Web Browser/GIMP Bugs"
		    "Link to http://www.wilberworks.com/bugs.cgi")
