;
;
;
; Chris Gutteridge (cjg@ecs.soton.ac.uk)
; At ECS Dept, University of Southampton, England.

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


(define (script-fu-tile-blur inImage inLayer inRadius inHoriz inVert inType)

   (set! theImage inImage)
   (set! theLayer inLayer)
   (set! theHeight (car (gimp-drawable-height theLayer)))
   (set! theWidth (car (gimp-drawable-width theLayer)))

   (gimp-image-disable-undo theImage)
   (gimp-layer-resize theLayer (* 3 theWidth) (* 3 theHeight) 0 0)

   (gimp-rect-select theImage 0 0 theWidth theHeight REPLACE 0 0)
   (gimp-edit-cut theImage theLayer)

   (gimp-selection-none theImage)
   (gimp-layer-set-offsets theLayer theWidth theHeight)

   (cjg-pasteat 1 1) (cjg-pasteat 1 2) (cjg-pasteat 1 3)
   (cjg-pasteat 2 1) (cjg-pasteat 2 2) (cjg-pasteat 2 3)
   (cjg-pasteat 3 1) (cjg-pasteat 3 2) (cjg-pasteat 3 3)

   (gimp-selection-none theImage)
   (if (= inType FALSE) 
       (plug-in-gauss-iir TRUE theImage theLayer inRadius inHoriz inVert)
       (plug-in-gauss-rle TRUE theImage theLayer inRadius inHoriz inVert)
   )

   (gimp-layer-resize theLayer theWidth theHeight (- 0 theWidth) (- 0 theHeight))
   (gimp-layer-set-offsets theLayer 0 0)
   (gimp-image-enable-undo theImage)
   (gimp-displays-flush)
)

(define (cjg-pasteat xoff yoff) 
   (let 	((theFloat (car(gimp-edit-paste theImage theLayer 0)))) 
		(gimp-layer-set-offsets theFloat (* xoff theWidth) (* yoff theHeight) )
		(gimp-floating-sel-anchor theFloat)
   )
)

; Register the function with the GIMP:

(script-fu-register
    "script-fu-tile-blur"
	"<Image>/Filters/Blur/Tilable Blur"
    "foo"
    "Chris Gutteridge"
    "1998, Chris Gutteridge / ECS dept, University of Southampton, England."
    "25th April 1998"
    "RGBA RGB"
    SF-IMAGE "The Image" 0
    SF-DRAWABLE "The Layer" 0
    SF-VALUE "Radius:" "5"
    SF-TOGGLE "Blur Vertically?" TRUE
    SF-TOGGLE "Blur Horizontally?" TRUE
    SF-TOGGLE "Blur Type: TRUE=RLE, FALSE=IIR" FALSE
)
