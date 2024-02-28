; File: rp6502enhance.s 
;
; Enhancements EhBASIC specific to rp6502 SBC to assemble under CC65
;
; Date: 24-Dec-2023
;
; Revisions: 
;       27-Feb-2024 - Add reading RIA's 100-hz clock().  -ntz
;

.include "rp6502.inc"

.export F_HGR, F_HPLOT, F_TEXT, F_CLS 
;.export PLOT_XBYT, PLOT_YBYT, PLOT_COLOR
.export F_GETCLK
.export CLK_VAL32
.import LAB_FCER, LAB_SCGB, LAB_295E, LAB_18E0
.import _init_bitmap_graphics, _draw_pixel, _init_console_text, _cls

;
; The following imports from ca65 libraries were difficult to find 
; but proved to be key in integrating EnBasci-assembly -> C calling parameters.  
; This greatly aided parameter/stack prep in using the added EhBasic 'CALL' command 
; parameters 'HPLOT,x,y,color' prior to call the c-function _plot_pixel().
; 
.import pushwysp, staxysp, stax0sp


AA_begin_enhancements:
; Let's show this label in the listing file / mapfile.

; ----------------------------------------------------------------------------
; New ehanced features added here after AA_end_basic:
;
; ntz - force compiler / linker to place these functions defined in C following 
;       the EhBASIC-interpreter executable code.
;       For now, they will be CALL'ed via BASIC's 'CALL' command.
; 
F_HGR:      ; HGR now has 1-parameter: dimension-flag 0x00=320x180x8bpp 0xFF=320x240x4bpp
      JSR   LAB_SCGB        ; scan for "," then get dimension byte in x-reg. 
                            ; Else syntax-error, warm start.
      txa                   ; Transfer x-reg to a-reg, our screen-dimension-flag byte
                            ; before doing our c-call to:
      jmp _init_bitmap_graphics
      rts ; for safety

F_HPLOT:                    ; HPLOT has 3-parameters: x, y, color 
      JSR   LAB_SCGB        ; scan for "," and get byte. Else syntax-error, warm start.
      STX   PLOT_XBYT       ; save plot x
      JSR   LAB_SCGB        ; scan for "," and get byte
      ;;CPX   #$40            ; compare with max+1
      ;;BCS   PLOT_FCER       ; if 64d or greater do function call error
      STX   PLOT_YBYT       ; save plot y
      JSR   LAB_SCGB        ; scan for "," and get byte
      STX   PLOT_COLOR      ; save color

      ; now tie-in our C-code to perform the HPLOT command: draw_pixel(x,y,color)
      ; TO-DO: How to get x, y, and color vars on the c-call-stack before calling draw_pixel?...
      ; Unclear how to get the bytes: PLOT_XBYT, PLOT_YBYT, and PLOT_COLOR
      ; over to _draw_pixel which (btw) expects uint16_t's.

        ; setup C-stack before calling draw_pixel(x,y,color)
        ldx #$00              ; x-hi-byte 0; do this as a 8-bit, ignore hi-order-byte
        lda PLOT_XBYT         ; x-lo-byte valid upto 255 (not 319)
        ldy #$02
        jsr staxysp    ; x=PLOT_XBYT
        lda PLOT_YBYT
        jsr stax0sp    ; y=PLOT_YBYT

        ;; Example code copied from c-test harness.
        ;; x = 160; y = 100;
        ;;
        ;ldx     #$00
        ;lda     #$A0
        ;ldy     #$02
        ;jsr     staxysp  ; x=160
        ;lda     #$64
        ;jsr     stax0sp  ; y=100


; Here is working code found by reverse-engr'ing C-code assembly:
       ldy     #$05
       jsr     pushwysp  ; x
       ldy     #$05
       jsr     pushwysp  ; y
;       ldx     #$00      ; test-code for forced green
;       lda     #$0A      ; test-code color forced green, via 'fastcall' convention
       ldx #$00
       lda PLOT_COLOR ; stored color, via 'fastcall' convention
      jmp    _draw_pixel
      RTS                     ; for safety; or to: return to BASIC

     ; does BASIC function call error
PLOT_FCER:
      JMP   LAB_FCER      ; do function call error, then warm start
      rts ; for safety

    ; now we just need the variable storage for the V_HPLOT / draw_pixel() function.
PLOT_XBYT:
        .byte   $00         ; set default x - to-do: needs to be 16-bits since x-max is 319
PLOT_YBYT:
        .byte   $00         ; set default y
PLOT_COLOR:
        .byte   $0A         ; default to Green


F_TEXT:     ; TEXTMODE now has 1-parameter: console-column-width (40 or 80)
      JSR   LAB_SCGB        ; scan for "," then get dimension byte in x-reg. 
                            ; Else syntax-error, warm start.
      txa                   ; Transfer x-reg to a-reg, our text-console-size-flag byte
                            ; before doing our c-call to:
      jmp _init_console_text
      rts ; for safety

F_CLS:
      jmp _cls
      rts ; for safety

F_GETCLK:
      lda #RIA_OP_CLOCK
      sta RIA_OP             ; Ask RIA to provide its 32-bits of timer clock
                             ; Results will be in: $FFF9(hi), $FFF8, $FFF6, $FFF4(lo)
                             ;                   RIA_SREG+1 RIA_SREG  RIA_X  RIA_A
      jsr RIA_SPIN           ; Pend until RIA_OP is done.
      
 ; Note: XA swapped in LAB_295E print routine, so items swapped in following
      ldx RIA_SREG           ; get upper 16-bits of clock result (lo)
      lda RIA_SREG+1         ; (hi)
 ;    lda #$0A               ; test code - gets stored in CLK_VAL32.01
 ;    ldx #$0B               ; test code - gets stored in CLK_VAL32.02
      sta CLK_VAL32
      stx CLK_VAL32+1
      jsr LAB_295E           ; print XA as unsigned integer and return here
 
      jsr LAB_18E0           ; print a " " space

 ; Note: XA swapped in LAB_295E print routine, so items swapped in following
      ldx RIA_A              ; get lower 16-bits of clock result (lo)
      lda RIA_X              ; (hi)
;     lda #$0C               ; test code - gets stored in CLK_VAL32.03
;     ldx #$0D               ; test code - gets stored in CLK_VAL32.04
      sta CLK_VAL32+2
      stx CLK_VAL32+3
      jmp LAB_295E           ; print XA as unsigned integer testcode:0x0C.0D = 3085-decimal
                             ; Note: XA swapped in print routine    reg-A.reg-X
      rts ; not-reached;safety

CLK_VAL32:
      .byte $01
      .byte $02
      .byte $03
      .byte $04

; Let's show this label in the listing file / mapfile.
AA_end_enhancements:
    ; Let keep track of how much code-space we use.
    ; AA_end_enhancements - AA_begin_enhancements
    ;