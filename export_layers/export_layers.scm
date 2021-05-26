(define (script-fu-export-layers inImage inDrawable inOutputFolder inFileType inRemLayerExt)
    ;(gimp-message "Hello world")
    (let* (
            (theLayers (cadr (gimp-image-get-layers inImage)))
            (theImageType (car (gimp-image-base-type inImage)))
            ;get total layers
            (theTotalLayers (car (gimp-image-get-layers inImage)))
            (theCurrentLayer 0)
            (theProgress 0)
            (theLayerID 0)
            (theParasite (list))
            (theLayerName "")
            (theLSLength 0)
            (theLSIndex 0)
            (theLSSTS 1)
            (theFileTypes #(".jpg" ".png"))
            (theChosenFileType (vector-ref theFileTypes inFileType))
            (theExportFile "")
            (theLayerHeight 10)
            (theLayerWidth 10)
            (theNewImage 0)
            (theNewLayer 0)
            (theParent 0)
            (thePosition -1)
            (theDisplay 0)
            ;jpg export parameters
            (jpg-run-mode 0) (jpg-image 0) (jpg-drawable 0) (jpg-filename "") (jpg-raw-filename "") (jpg-quality 4.5) 
            (jpg-smoothing 0) (jpg-optimize 1) (jpg-progressive 1) (jpg-comment "Created with Gienie Export Layers Script Fu") 
            (jpg-subsmp 2) (jpg-baseline 0) (jpg-restart 0) (jpg-dct 0)
            ;png export parameters
            (png-run-mode 0) (png-image 0) (png-drawable 0) (png-filename "") (png-raw-filename "") (png-interlace 0) 
            (png-compression 9) (png-bkgd 1) (png-gama 0) (png-offs 0) (png-phys 0) (png-time 1) (png-comment 0) (png-svtrans 0)
          )
          ;create new image with theHeight and theWidth
          (set! theNewImage (car (gimp-image-new theLayerWidth theLayerHeight theImageType)))
          ;create display and flush
          (set! theDisplay (car (gimp-display-new theNewImage)))
          (gimp-displays-flush)
          ;export files
          ;loop using theLayers
          (while (< theCurrentLayer theTotalLayers)
            ;call function export-image-from-layer
            (set! theLayerID (vector-ref  theLayers theCurrentLayer))
            (set! theLayerName (car (gimp-item-get-name theLayerID)))
            ;remove or keep extension from layername
            (if (= TRUE inRemLayerExt)
                (begin
                  ;get the string length
                  (set! theLSLength (string-length theLayerName))
                  (set! theLSIndex (- theLSLength 1))
                  (set! theLSSTS 1)
                  ;search for a dot from last index to 0
                  (while (= 1 theLSSTS)
                    (if (string=? (string (string-ref theLayerName theLSIndex)) ".")
                      (begin
                        (if (= theLSIndex 0)
                          (begin
                            ;replace the dot (.) by underscore (_)
                            (if (> theLSLength 1)
                              (begin
                                (set! theLayerName (substring theLayerName 1 theLSLength))
                                (set! theLayerName (string-append "_" theLayerName))
                              )
                              (set! theLayerName "_")
                            )
                          )
                        )
                        (set! theLSSTS 0)
                      )
                      (begin
                        (if (> theLSIndex 0) 
                          (set! theLSIndex (- theLSIndex 1))
                          0
                        )
                      )
                    )
                    (if (= theLSIndex 0)
                      (set! theLSSTS 0)
                      0
                    )
                  )
                  ;(set! theLSLength (+ theLSIndex 1))
                  ;if index = 0 do nothing
                  ;else trim the string from right to the index we got
                  (if (= theLSIndex 0)
                    0
                    (set! theLayerName (substring theLayerName 0 theLSIndex))
                  ) 
                )
            )
            (set! theExportFile (string-append inOutputFolder "/" theLayerName theChosenFileType))
            (set! theLayerHeight (car (gimp-drawable-height theLayerID)))
            (set! theLayerWidth (car (gimp-drawable-width theLayerID)))
            (gimp-image-scale theNewImage theLayerWidth theLayerHeight)
            ;copy layer from primary image
            (set! theNewLayer (car (gimp-layer-new-from-drawable theLayerID theNewImage)))
            ;insert copied layer into the new image
            (gimp-image-insert-layer theNewImage theNewLayer theParent thePosition)
            ;offset of the layer to left top
            (gimp-layer-set-offsets theNewLayer 0 0)
            (gimp-displays-flush)
            (if (= 0 inFileType)
              ; export to jpg
              (begin
                (set! jpg-image theNewImage)
                (set! jpg-drawable theNewLayer)
                (set! jpg-filename theExportFile)
                (set! jpg-raw-filename theExportFile)
                (if (= 0 theCurrentLayer) 
                  (begin
                    (set! jpg-run-mode 0)
                    (file-jpeg-save jpg-run-mode jpg-image jpg-drawable jpg-filename jpg-raw-filename jpg-quality 
                                    jpg-smoothing jpg-optimize jpg-progressive jpg-comment jpg-subsmp 
                                    jpg-baseline jpg-restart jpg-dct)
                  )
                  (begin
                    (set! jpg-run-mode 2)
                    (gimp-file-save jpg-run-mode jpg-image jpg-drawable jpg-filename jpg-raw-filename)
                  )
                )
              )
            )
            (if (= 1 inFileType)
              ; export to png
              (begin
                (set! png-image theNewImage)
                (set! png-drawable theNewLayer)
                (set! png-filename theExportFile)
                (set! png-raw-filename theExportFile)
                (if (= 0 theCurrentLayer) 
                  (begin
                    (set! png-run-mode 0)
                    (file-png-save2 png-run-mode png-image png-drawable png-filename png-raw-filename png-interlace 
                                    png-compression png-bkgd png-gama png-offs png-phys png-time png-comment png-svtrans)
                  )
                  (begin
                    (set! png-run-mode 2)
                    (gimp-file-save png-run-mode png-image png-drawable png-filename png-raw-filename)
                  )
                )
              )
            )
            ;increament of theCurrentLayer
            (set! theCurrentLayer (+ theCurrentLayer 1))
            ;gimp progress increase
            (set! theProgress (* (/ theCurrentLayer theTotalLayers) 100))
            (gimp-image-remove-layer theNewImage theNewLayer)
            (gimp-progress-update theProgress)
          )
          ;delete display
          (gimp-display-delete theDisplay)
          ;delete image
          ;(gimp-image-delete theNewImage)
    )
    (gimp-message "Layers exported to the destination. Please check the output folder.")
    (gimp-progress-end)
)

(script-fu-register
    "script-fu-export-layers"                               ;func name **required
    "_Export Layers..."                                     ;menu label
    "Export layers into individual image files"             ;description
    "Smruti Ranjan Gochhayat"                               ;author
    "copyright 2021, Smruti Ranjan Gochhayat 
    2021, the Gienie Group"                                 ;copyright notice
    "May 16, 2021"                                          ;date created
    "RGB* INDEXED* GRAY*"                                   ;image type that the script works on
    SF-IMAGE       "Image"                        0
    SF-DRAWABLE    "Drawable"                     0
    SF-DIRNAME     "Output Folder"                ""
    SF-OPTION      "File Type (Extension)"        '("jpg" "png")
    SF-TOGGLE      "Remove extension from layer name; Note: avoid using dots (.) in layer name"
                                                  TRUE
)
(script-fu-menu-register "script-fu-export-layers" "<Image>/File/Export")
