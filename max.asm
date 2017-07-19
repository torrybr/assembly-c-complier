; PA7 Assignment
; Author: Torry Brelsford
; Date:   3/30/2015
; Email:  torrybr@rams.colostate.edu
; Class:  CS270
;
; Description: Implements the manipulation of half precision (16-bit) floating point numbers

;------------------------------------------------------------------------------
; Begin reserved section: do not change ANYTHING in reserved section!

                .ORIG x3000
                BR MAIN

; A jump table defined as an array of addresses
Functions       .FILL flt16_add      ; (option 0)
                .FILL flt16_sub      ; (option 1)
                .FILL flt16_get_sign ; (option 2)
                .FILL flt16_get_exp  ; (option 3)
                .FILL flt16_get_val  ; (option 4)
                .FILL flt16_abs      ; (option 5)
                .FILL flt16_neg      ; (option 6)
                .FILL left_most1     ; (option 7)
                .FILL left_shift     ; (option 8)
                .FILL right_shift    ; (option 9)
                .FILL binary_or      ; (option 10)

Main            LEA R0,Functions     ; get base of jump table
                LD  R1,Option        ; get option to use, no error checking
                ADD R0,R0,R1         ; add index of array
                LDR R0,R0,#0         ; get address of function
                JSRR R0              ; call selected function
                HALT

; Parameters and return values for all functions
Option          .BLKW 1              ; which function to call
Param1          .FILL x3E00            ; space to specify first parameter
Param2          .FILL x3D00          ; space to specify second parameter
Result          .BLKW 1              ; space to store result

; You may add variables and functions after here as you see fit. You may use JSR
; within the code of flt16_add or other functions. However, this requires that
; you save and restore return addresses, otherwise a function will not be able
; to use JSR to call another subroutine. See flt16_add for an example of how to
; save and restore a return address. When will this scheme NOT work?

; Here are some useful constants:

SIGN_MASK       .FILL x8000          ; 1 in left most bit 
EXP_MASK        .FILL x001F          ; exactly 5 bits     
VAL_MASK        .FILL x03FF          ; exactly 10 bits    
IMPL1_MASK      .FILL x0400          ; 1 in the 11 bit    
ONE             .FILL #1             ; the number 1       
TEN             .FILL #10            ; the number 10      
SIXTEEN         .FILL #16            ; the value 16
FFFF 		.FILL xFFFF	     ; 1111 1111 1111 1111 
FIVE		.FILL x0005
FOURTEEN	.FILL x000E
; End reserved section: do not change ANYTHING in reserved section!
;------------------------------------------------------------------------------

; Local variables, this is how you will be tested for PA7
; Do not change the names!
X               .BLKW 1              ; X parameter
Y               .BLKW 1              ; Y parameter
signX           .BLKW 1              ; sign of X
expX            .BLKW 1              ; exponent of X
valX            .BLKW 1              ; mantissa of X
signY           .BLKW 1              ; sign of Y
expY            .BLKW 1              ; exponent of Y
valY            .BLKW 1              ; mantissa of Y
signSum         .BLKW 1              ; sign of sum
expSum          .BLKW 1              ; exponent of sum
valSum          .BLKW 1              ; mantissa of sum
left1           .BLKW 1              ; location of left most 1

flt16_add_ra    .BLKW 1              ; return address

flt16_add       ST R7,flt16_add_ra   ; save return address

                LD R0,Param1         ; read X parameter
                ST R0,X              ; store X parameter
                LD R0,Param2         ; read Y parameter
                ST R0,Y              ; store Y parameter

; STEP ONE) Extract fields from operands
	 	;LD R0,Param1
		

		JSR flt16_get_sign   ; calls flt16_get_sign method to return sign of x
		LD R1, Result	     ; loads Result of flt16_get_sign in R1
		ST R1, signX	     ; Stores R1 into signX
		
		JSR flt16_get_exp    ; calls flt16_get_exp to return exponent of x
		LD R2, Result	     ; loads Result of flt16_get_exp into R2
		ST R2, expX	     ; Stores R2 into expX
	
		JSR flt16_get_val    ; calls flt16_get_val to return mantissa of x
		LD R3, Result	     ; loads Result of flt16_get_val in R3
		ST R3, valX	     ; Stores R3 into valX

		LD R0, Param2	     ; loads Param2 into R0
		ST R0, Param1        ; stores R0 into param1
		
 		JSR flt16_get_sign   ;calls flt16_get_sign method to return sign of y
		LD R4, Result	     ;loads Result of flt16_get_sign in R4
		ST R4, signY	     ;stores R4 into signY

	        JSR flt16_get_exp    ;calls JSR flt16_get_exp method to return expoenent of y
		LD R5, Result	     ;Loads Result of JSR flt16_get_exp in R5
 		ST R5, expY	     ;Stores R5 into expY
 
		JSR flt16_get_val    ;calls flt16_get_val to return mantissa of y
		LD R6, Result	     ;Loads Result of JSR flt16_get_val in R6
		ST R6, valY 	     ;Stores R6 into valY

; STEP TWO) Equalize operand exponents (or copy exponent)
		
		ST R5,expSum	     ;Store expY value into expSum
	
; STEP THREE) Convert operands to 2's complement
		LD R1, signX	      ; reassign R1 to signX
		ADD R1,R1,#0          ;is x sign zero or 1
		BRz hip		      ;if zero, skip code (2's compliment of mantissif ;negative)
		NOT R3,R3             ; negate mantissa of x
		ADD R3,R3,#1	      ; add 1 to negation 
		ST R3, valX	      ; store R3 to valx
	hip
		LD R4,signY	      ; reassign R4 to signY
		ADD R4,R4,#0	      ;is y sign zero or 1
		BRz gip		      ;if zero, skip code (2's compliemnt of mantissa if negative
		NOT R6,R6             ; negate R6(y mantissa)
		ADD R6,R6,#1          ;Add 1
		ST R6,valY	      ; store R6 to valY
	gip
	
; STEP FOUR) Add mantissas
		LD R3,valX		
		LD R6,valY
		ADD R0,R6,R3	      ; Adding mantissa's R3,R6
		ST R0, valSum	      ; Store R0 in valsum
		ST R0,Param1          ; save val sum in param1
		JSR flt16_get_sign    ; call get sign on valsum
		AND R0,R0,#0		
		LD R0,Result	      ; load result in R0
		ST R0,signSum         ; Store R0 in signSum
; STEP FIVE) Convert sum from 2's complement
		
		ADD R0,R0,#0	      ; Check to see if R0 is neg or pos
		BRzp negative	      ; if R0 is negative, go into code
		NOT R0,R0	      ; begin 2's compliment. negate R0
		ADD R0,R0,#1	      ; add 1 to R0
		ST R0,valSum
	negative
		
; STEP SIX) Normalize sum
		AND R0,R0,#0  	      ; clear R0		
	        LD R0,valSum
		ST R0,Param1	      ; Store valsum in param1 to find lm1		
		AND R6,R6,#0	      ; clear R6
		JSR left_most1        ; call lm1
		LD R6,Result	      ; R6 contains left most 1 postion
		ADD R6,R6,#-10	      ; check to see if R6 is > than 10	      
		
		BRp yes		      ; if its postive(then R6 is greater)skip. if negative go into code(right side of 10 bits)
		ST R6,Param1          ; store the negative difference(R6) in Param
		LD R5, expSum	      ; Load R5 with expSum (begin to shift by R2)
		ADD R5,R5,R6	      ; subtract R6-expsum
		ST R5,expSum	   
		AND R5,R5,#0
		AND R2,R2,#0
		LD R5, expSum
		NOT R6,R6
		ADD R6,R6,#1
		ST R6,Param2	      ; store R6 in Param2 so it shifts Param1 by that #
		AND R0,R0,#0
		LD R0,valSum
		ST R0, Param1	      ; make sure R0(valSum) is stored in param1
		JSR left_shift	      ; call left shift on valsum(param1 R0) and postive diff(r6)
		LD R6,Result	      ; Load result in R6
		ST R6,valSum	      ; Store R6 in valSum
		BR END_ELSE
	yes	     
		;AND R5,R5,#0	      ; clear R5
		LD R5,valSum
		ST R5,Param1
		ST R6,Param2	      ; store R6 in Param2 so it shifts Param1 by that #
		LD R5, expSum
		ADD R5,R5,R6
		ST R5, expSum		
		JSR right_shift       ; right shift
		LD R6,Result
		ST R6, valSum
	END_ELSE
		
		
; STEP SEVEN) Compose sum from fields
				      ; get expSum into right posistion	
		LD R0,signSum	      ; load signsum into R0
		ADD R0,R0,#0          ; check to see if signsum is a zero or 1
		BRz ants	      ; if zero(positive number) skip, negative go into
		LD R1,#14	      ; Store fourteen into R1
		ST R1,Param2	      ; 14 = Param2
		LD R2,#0	      ; R2 = 0
		ST R2,Param1	      ; param1 = 0
		JSR left_shift        ;0 by 14  
		LD R0,Result          ; 
	ants	
		
		;AND R2,R2,#0
		LD R1, EXP_MASK	       ; R1 = EXP_mask
		LD R2,expSum	       ; R2 = expSum
		AND R1,R1,R2	       ; AND EXP_Mask and exp to get 5 bits 
		ADD R0,R0,R1	       ; ADD Sign + expSum
		ST R0,Param1	       ; store that in Param1 to shift
		AND R3,R3,#0
		LD R3, TEN
		ST R3,Param2
		JSR left_shift
		LD R0,Result
		
		
		
		LD R3,valSum
		LD R4,VAL_MASK
		AND R3,R3,R4
		ADD R0,R0,R3
		ST R0,Result
			
                LD R7,flt16_add_ra    ; restore return address
                RET
;------------------------------------------------------------------------------
flt16_sub_ra    .BLKW 1              ; return address
 
flt16_sub      
	
		                      ; Result is Param1 minus Param2

                ST R7,flt16_sub_ra   ; save return address
		LD R3,Param1
                LD R0,Param2	      ; store param2 in R0
		ST R0,Param1
		JSR flt16_neg
		LD R1,Result
		ST R1,Param2
		ST R3,Param1
		JSR flt16_add
		LD R2,Result
		ST R2,Result

                LD R7,flt16_sub_ra   ; restore return address
                RET
;------------------------------------------------------------------------------
flt16_get_sign                       ; Result is 0 if Param1 is positive, 1 otherwise

                AND R0,R0,#0         ; initialize result
                LD R1,Param1         ; load parameter
                LD R2,SIGN_MASK      ; load sign mask   
                AND R3,R2,R1         ; sign bit set?
                BRz return_sign      ; not set, return 0
                ADD R0,R0,#1         ; set, return 1
return_sign     ST R0,Result         ; save result
                RET
;------------------------------------------------------------------------------
flt16_exp_ra    .BLKW 1              ; return address

flt16_get_exp                        ; Result is biased exponent from Param1

               ST R7,flt16_exp_ra   ; save return address
	       LD R0, Param1
	       LD R1, TEN
	       LD R2, ONE
	       LD R3, SIXTEEN
	       LD R4, #0
 	       AND R5,R5,#0
	       LD R6, ONE
       	       LD R7, EXP_MASK
	panthers
		ADD R2, R2, R2
		ADD R1, R1, #-1
		BRp panthers                 
		AND R1, R1,#0
		NOT R1,R1
		ADD R1,R1,#1
		ADD R1,R3,R1
		LD R1, FIVE
	Towels
		AND R4,R0,R2
		BRz yellows
		ADD R5,R5,R6
	yellows
		ADD R2,R2,R2
		ADD R6,R6,R6
		ADD R1,R1,#-1
		BRp Towels
		ST R5, Result		                   
                LD R7,flt16_exp_ra   ; restore return address
                RET
;------------------------------------------------------------------------------
flt16_get_val                        
		LD R0, Param1	
		BRz Ski		
		LD R1, VAL_MASK		
		LD R2, IMPL1_MASK
		AND R0, R0,R1
		ADD R0, R0, R2
	Ski
		ST R0, Result
                                     
                RET
;------------------------------------------------------------------------------
flt16_abs                            
		LD R0, Param1
		LD R1, SIGN_MASK	
		NOT R1,R1		
		AND R0, R0,R1
		ST R0, Result                         
                RET
;------------------------------------------------------------------------------
flt16_neg                            
		LD R0, Param1
		BRz Skip	
		LD R1, SIGN_MASK
		ADD R0, R0, R1
	Skip
		ST R0, Result
                                     
                RET
;------------------------------------------------------------------------------
left_most1                           ; Result is bit position of leftmost 1 in Param1
                                     ; Algorithm: check bits from right to left
		
		LD R1, x0000     ; total Count
		LD R2, FFFF      ; OneCount set to FFFF because if param1 is zero, code will jump toend
		LD R3, ONE       ; Mask	
		LD R5, SIXTEEN
		LD R0, Param1    ; Param1
		BRz hello        ; if param1 is zero, skip code in branch
		AND R1,R1,#0     ; clear r1 to zero
		AND R2,R2,#0     ; clear r2 to zero
	Skipper		
		AND R4,R0,R3     ; and mask and param 1 to see if its 1 or zero
		BRz yip		 ; if AND R4,R0,R3 is a one, store totalcount in onecount
		ADD R2,R1,#0     ; stores the total count in onecount if AND is a 1
	yip
		ADD R1,R1,#1     ; increment total count by 1		
		ADD R3,R3,R3     ; shift mask left by 1	
		ADD R5,R5,#-1    ; subtract 1 from 15 every iteration
		BRzp Skipper   	 ; loop to check if R5 is zero or positve (end of bit string)
	hello		
		ST R2, Result    ; store onecount in Result
		  		 
                RET
;------------------------------------------------------------------------------
left_shift                           ; Result is Param1 shifted left by Param2 bits
                                     ; Algorithm: shift left by doubling
		LD R0, Param1
		LD R1, Param2
	 	BRnz dogs
	 Loop
		ADD R0, R0, R0
		ADD R1, R1, #-1
		BRp Loop
	dogs
		ST R0, Result
                RET
;------------------------------------------------------------------------------
right_shift                          ; Result is Param1 shifted right by Param2 bits
                                     ; Algorithm: walk source and destination bit
		LD R0,Param1
		LD R2,Param1
		LD R1,Param2
		BRnz return_rs
		AND R2,R2,0
		LD R3,ONE
		LD R4,ONE
	rshift_loop1
		ADD R3,R3,R3
		ADD R1,R1,#-1
		BRp rshift_loop1
	rshift_loop2	
		AND R5,R0,R3
		BRz rshift_next
		ADD R2,R2,R4
	rshift_next
		ADD R4,R4,R4
		ADD R3,R3,R3
		BRnp rshift_loop2
	return_rs	
		ST R2,Result
		RET

;------------------------------------------------------------------------------
binary_or                            ; Result is a bitwise OR of Param1 and Param2
                                     ; Algorithm: De Morgan's Law: a | b = ~(~a & ~b)

                LD R0, Param1
		LD R1, Param2
		NOT R0,R0
		NOT R1,R1
		AND R0,R0,R1
		NOT R0,R0
		ST R0,Result
                RET
;------------------------------------------------------------------------------
                .END


