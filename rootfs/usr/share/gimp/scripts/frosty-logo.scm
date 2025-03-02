;  FROZEN-TEXT effect
;  Thanks to Ed Mackey for this one
;   Written by Spencer Kimball

(define (min a b) (if (< a b) a b))

(define (script-fu-frosty-logo text size font bg-color)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
	 (border (/ size 5))
	 (text-layer (car (gimp-text img -1 0 0 text (* border 2) TRUE size PIXELS "*" font "*" "*" "*" "*")))
	 (width (car (gimp-drawable-width text-layer)))
	 (height (car (gimp-drawable-height text-layer)))
	 (text-layer-mask (car (gimp-layer-create-mask text-layer BLACK-MASK)))
	 (sparkle-layer (car (gimp-layer-new img width height RGBA_IMAGE "Sparkle" 100 NORMAL)))
	 (matte-layer (car (gimp-layer-new img width height RGBA_IMAGE "Matte" 100 NORMAL)))
	 (shadow-layer (car (gimp-layer-new img width height RGBA_IMAGE "Shadow" 90 MULTIPLY)))
	 (bg-layer (car (gimp-layer-new img width height RGB_IMAGE "Background" 100 NORMAL)))
	 (selection 0)
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-bg (car (gimp-palette-get-background)))
	 (old-brush (car (gimp-brushes-get-brush)))
	 (old-paint-mode (car (gimp-brushes-get-paint-mode))))
    (gimp-image-disable-undo img)
    (gimp-image-resize img width height 0 0)
    (gimp-image-add-layer img sparkle-layer 2)
    (gimp-image-add-layer img matte-layer 3)
    (gimp-image-add-layer img shadow-layer 4)
    (gimp-image-add-layer img bg-layer 5)
    (gimp-selection-none img)
    (gimp-edit-clear img sparkle-layer)
    (gimp-edit-clear img matte-layer)
    (gimp-edit-clear img shadow-layer)
    (gimp-selection-layer-alpha img text-layer)
    (set! selection (car (gimp-selection-save img)))
    (gimp-selection-feather img border)
    (gimp-palette-set-background '(0 0 0))
    (gimp-edit-fill img sparkle-layer)
    (plug-in-noisify 1 img sparkle-layer FALSE 0.2 0.2 0.2 0.0)
    (plug-in-c-astretch 1 img sparkle-layer)
    (gimp-selection-none img)
    (plug-in-sparkle 1 img sparkle-layer 0.03 0.45 (/ (min width height) 2) 6 15)
    (gimp-levels img sparkle-layer 1 0 255 0.2 0 255)
    (gimp-levels img sparkle-layer 2 0 255 0.7 0 255)
    (gimp-selection-layer-alpha img sparkle-layer)
    (gimp-palette-set-foreground '(0 0 0))
    (gimp-brushes-set-brush "Circle Fuzzy (11)")
    (gimp-edit-stroke img matte-layer)
    (gimp-selection-feather img border)
    (gimp-edit-fill img shadow-layer)
    (gimp-selection-none img)
    (gimp-palette-set-background bg-color)
    (gimp-edit-fill img bg-layer)
    (gimp-palette-set-background '(0 0 0))
    (gimp-edit-fill img text-layer)
    (gimp-image-add-layer-mask img text-layer text-layer-mask)
    (gimp-selection-load img selection)
    (gimp-palette-set-background '(255 255 255))
    (gimp-edit-fill img text-layer-mask)
    (gimp-selection-feather img border)
    (gimp-selection-translate img (/ border 2) (/ border 2))
    (gimp-edit-fill img text-layer)
    (gimp-image-remove-layer-mask img text-layer 0)
    (gimp-selection-load img selection)
    (gimp-brushes-set-brush "Circle Fuzzy (07)")
    (gimp-brushes-set-paint-mode BEHIND)
    (gimp-palette-set-foreground '(186 241 255))
    (gimp-edit-stroke img text-layer)
    (gimp-selection-none img)
    (gimp-image-remove-channel img selection)
    (gimp-palette-set-foreground old-fg)
    (gimp-palette-set-background old-bg)
    (gimp-brushes-set-brush old-brush)
    (gimp-brushes-set-paint-mode old-paint-mode)
    (gimp-layer-translate shadow-layer border border)
    (gimp-image-enable-undo img)
    (gimp-display-new img)))

(script-fu-register "script-fu-frosty-logo"
		    "<Toolbox>/Xtns/Script-Fu/Logos/Frosty"
		    "Frozen logos with drop shadows"
		    "Spencer Kimball & Ed Mackey"
		    "Spencer Kimball & Ed Mackey"
		    "1997"
		    ""
		    SF-VALUE "Text String" "\"The GIMP\""
		    SF-VALUE "Font Size (in pixels)" "100"
		    SF-VALUE "Font" "\"Becker\""
		    SF-COLOR "Background Color" '(255 255 255))
