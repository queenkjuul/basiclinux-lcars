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


(define (script-fu-camo-pattern inSize inGrain inColor1 inColor2 inColor3 inSmooth inFlatten)

        (set! old-bg (car (gimp-palette-get-background)))
        (set! theWidth inSize)
	(set! theHeight inSize)
        (set! theImage (car(gimp-image-new theWidth theHeight RGB)))

        (set! baseLayer (car (gimp-layer-new theImage theWidth theHeight RGBA_IMAGE "Background" 100 NORMAL)))
        (gimp-image-add-layer theImage baseLayer 0)

        (set! thickLayer (car (gimp-layer-new theImage theWidth theHeight RGBA_IMAGE "Camo Thick Layer" 100 NORMAL)))
        (gimp-image-add-layer theImage thickLayer 0)

        (set! thinLayer (car (gimp-layer-new theImage theWidth theHeight RGBA_IMAGE "Camo Thin Layer" 100 NORMAL)))
        (gimp-image-add-layer theImage thinLayer 0)

        (gimp-selection-all theImage)
        (gimp-palette-set-background inColor1)
        (gimp-drawable-fill baseLayer BG-IMAGE-FILL)

        (plug-in-solid-noise TRUE theImage thickLayer 1 0 (rand 65536) 1 inGrain inGrain)
        (plug-in-solid-noise TRUE theImage thinLayer 1 0 (rand 65536) 1 inGrain inGrain)
        (gimp-threshold theImage thickLayer 127 255)
        (gimp-threshold theImage thinLayer 145 255)

	(set! theBlur (- 16 inGrain))

        (gimp-palette-set-background inColor2)
        (gimp-by-color-select theImage thickLayer '(0 0 0) 127 REPLACE  TRUE FALSE 0 FALSE)
        (gimp-edit-clear theImage thickLayer)
        (gimp-selection-invert theImage)
        (gimp-edit-fill theImage thickLayer)
        (gimp-selection-none theImage)
        (if (= inSmooth TRUE) 
	    (script-fu-tile-blur theImage thickLayer theBlur TRUE TRUE FALSE)
            ()
        )


        (gimp-palette-set-background inColor3)
        (gimp-by-color-select theImage thinLayer '(0 0 0) 127 REPLACE  TRUE FALSE 0 FALSE)
        (gimp-edit-clear theImage thinLayer)
        (gimp-selection-invert theImage)
        (gimp-edit-fill theImage thinLayer)
        (gimp-selection-none theImage)
        (if (= inSmooth TRUE) 
	    (script-fu-tile-blur theImage thinLayer (/ theBlur 2) TRUE TRUE FALSE)
            ()
        )


        (if (= inFlatten TRUE) 
            (gimp-image-flatten theImage)
            ()
        )
        (gimp-palette-set-background old-bg)
        (gimp-display-new theImage)
)



; Register the function with the GIMP:

(script-fu-register
 "script-fu-camo-pattern"
 "<Toolbox>/Xtns/Script-Fu/Patterns/Camouflage"
 "foo"
 "Chris Gutteridge: cjg@ecs.soton.ac.uk"
 "28th April 1998"
 "Chris Gutteridge / ECS @ University of Southampton, England"
 ""
 SF-VALUE "Image Size:" "256"
 SF-VALUE "Granularity (0 - 15):" "7"
 SF-COLOR "Color 1:"      '(33 100 58)
 SF-COLOR "Color 2:"      '(170 170 60)
 SF-COLOR "Color 3:"      '(150 115 100)
 SF-TOGGLE "Smooth?" FALSE
 SF-TOGGLE "Flatten?" TRUE
)

