/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

 /* Make the following functions globally visible */
.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r4,r0,ASR 16 /* places MSB bits of r0 into r4 for multiplicand  */
    mov r5,r0,LSL 16 /* shifts LSB bits of r0 into MSB bits at r5 */
    ASR r5,r5,16 /* shifts current MSB bits into LSB bits, rest become signed bits for multiplier */
    
    STR r4,[r1] /* stores multiplicand into address for a bit */
    STR r5,[r2] /* stores multiplier into address for b bit */
    
    pop {r4-r11,LR}
    mov PC,LR
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit:
 *                  0 = "+", 1 = "-"
 *    outputs:  r0: Absolute value of r0 input. Same value
 *                  as stored to location given in r1
 *              memory: 
 *                  1) store absolute value in location
 *                     given by r1
 *                  2) store sign bit in location 
 *                     given by r2
 */
asmAbs:  
    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r3,r0,LSR 31 /* gets signed bit of inputted value */
    STR r3,[r2] /* stores sign bit in address given */
    mov r5,0 /* register for 0 */
    cmp r5,r3 /* checks if signed bit is 1 or negative */
    LDR r4,=0x0000ffff /* register for value to be used in and logic */
    bmi negative /* if signed bit negative or 1 */
    
    AND r0,r0,r4 /* if positive, get absolute value right away */
    STR r0,[r1] /* store absolute value in address given */
    b done /* branch to pop */
    
negative:
    ORN r0,r5,r0 /* flips all the bits to get negative value */
    AND r0,r0,r4 /* changes all sign bits to 0 for absolute value */
    ADD r0,r0,1 /* adds 1 for 2s complement */
    STR r0,[r1] /* stores absolute value into address given */
  
done:
    POP {r4-r11,LR}
    mov PC,LR
    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */    
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r3,0 /* resets register for initial product */
    shift_and_add:
	mov r2,0 /* register for 0 */
	CMP r1,r2 /* check if multiplier equal 0 */
	beq product_done /* if multiplier equal 0 */
	mov r2,1 /* register for 0x00000001 */
	AND r4,r1,r2 /* checks multiplier LSB if 0 or 1 */
	CMP r4,0 /* checks if LSB 0 */
	beq LSB_not_1 /* if 0 go straight to shifts */
	ADD r3,r3,r0 /* if LSB 1, add product and multiplicand */
	
    LSB_not_1:
	LSR r1,r1,1 /* shift multiplier 1 to right */
	LSL r0,r0,1 /* shift multiplicand 1 to left */
	b shift_and_add /* go back to shift_and_add loop */
	
    product_done:
	mov r0,r3 /* moves initial product into r0 */
	pop {r4-r11,LR}
	mov PC,LR

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/
   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    EOR r3,r1,r2 /* if both sign bits same = positive, else = negative */
    CMP r3,0 /* if result is 0 or positive, intiial product is final product */
    beq final_product /* if result is 1 or negative, move to flipping bits */
    
    mov r4,0 /* register for 0 */
    ORN r0,r4,r0 /* flips all bits in initial product */
    ADD r0,1 /* adds 1 for 2s complement */
    
    final_product:
	pop {r4-r11,LR}
	mov PC,LR
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */
asmMain: /*unfortunately I was not able to figure out the main method, the other methods
     were all good and passed every case but I was having difficulties how to call each 
     function in the main method. I tried a couple different ways but they resulted in 
     exception errors. If you could possibly show how to get past these difficulties when
     grading, it would be much appreciated */
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11,LR} 
    /* Step 1:
     * call asmUnpack. Have it store the output values in 
     * a_Multiplicand and b_Multiplier.
     */
    BL asmUnpack
    LDR r6,=a_Multiplicand
    LDR r7,=b_Multiplier
    STR r4,[r6] /*stores unpacked value into a_Multiplicand */
    STR r5,[r7] /* stores unpacked value into b_Multiplier */


    /* Step 2a:
     * call asmAbs for the multiplicand (A). Have it store the
     * absolute value in a_Abs, and the sign in a_Sign.
     */
    mov r0,r4 /* moves multiplicand into r0 */
    BL asmAbs
    LDR r6,=a_Abs
    STR r0,[r6] /* stores absolute value in a_Abs */
    LDR r7,=a_Sign
    STR r3,[r7] /* stores sign bit in a_Sign */
    


    /* Step 2b:
     * call asmAbs for the multiplier (B). Have it store the
     * absolute value in b_Abs, and the sign in b_Sign.
     */
    mov r0,r5 /* moves multiplier into r0 */
    BL asmAbs
    LDR r8,=b_Abs
    STR r0,[r8] /* stores absolute value in b_Abs */
    LDR r9,=b_Sign
    STR r3,[r9] /* stores sign bit in b_Sign */

    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * Store the value returned in r0 to mem location 
     * init_Product.
     */
    LDR r0,[r6] /* loads a_Abs into r0 for multiplicand */
    LDR r1,[r8] /* loads b_Abse into r1 for multiplier */
    BL asmMult
    LDR r10,=init_Product
    STR r0,[r10] /* stores returned value into init_Product */

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. 
     * Store the value returned in r0 to mem location 
     * final_Product.
     */
    LDR r1,[r7] /*loads a sign bits into r1 */
    LDR r2,[r9] /* loads b sign bits into r2 */
    BL asmFixSign
    LDR r11,=final_Product
    STR r0,[r11] /* stores returned value into final_Product */
    

    /* Step 5:
     * END! Return to caller. Make sure of the following:
     * 1) Stack has been correctly managed.
     * 2) the final answer is stored in r0, so that the C call
     *    can access it.
     */
    pop {r4-r11,LR}
    mov PC,LR
    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
