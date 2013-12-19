/**
  ******************************************************************************
  * @file    HX8352C_GPIO_Lowlevel.s
  * @author  Baoshi
  * @version 0.2
  * @date    29-Nov-2013
  * @brief   GPIO 16-bit interface for HX8352C LCD controller
  ******************************************************************************
  * @copyright
  * This code is licensed under (CC BY-SA 3.0), available at:
  *
  *     http://creativecommons.org/licenses/by-sa/3.0/
  *
  * THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY EXPRESS OR IMPLIED
  * WARRANTY.  IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES
  * ARISING FROM THE USE OF THIS SOFTWARE.
  *
  * @note   The idea behind GPIO LCD interface and ARM assembly implementation
  *         is originated by Andy Brown and his excellent stm32plus library.
  *         Please visit Andy's Workshop at: http://andybrown.me.uk/ \n
  *         Please note I have no intention to promot my work by using Author's
  *         name and stm32plus library.
  ******************************************************************************
  */

//! @cond DOXYGEN_SHOW_ASM

.syntax unified

@ External variables found in LCDAccess.c which define LCD wiring
.extern LCD_Data_GPIOx_BASE
.extern LCD_Ctrl_GPIOx_BASE
.extern LCD_RS_Pin
.extern LCD_WR_Pin
.extern LCD_RD_Pin

.section .text

//! @endcond


/**
 * @fn      void lcdWriteData(uint16_t data)
 * @brief   Write 16-bit data to LCD (RS = 1)
 * @param   data    Data to be written (r0)
 * @note    This function is written in ARM assembly language.
 *          WR control pulse "L" duration is 28ns @72MHz processor clock
 *          (Datasheet requires 15ns "L" and 100ns full write cycle).
 */
 //! @cond DOXYGEN_SHOW_ASM
 .align  2
.global lcdWriteData
.thumb
.thumb_func
lcdWriteData:
    ldr  r1,  =LCD_Data_GPIOx_BASE  @ r1 = &LCD_Data_GPIOx_BASE
    ldr  r1,  [r1]                  @ r1 = LCD_Data_GPIOx_BASE
    strh r0,  [r1, #0x0C]           @ GPIOx_ODR = data
    ldr  r1,  =LCD_Ctrl_GPIOx_BASE  @ r1 = &LCD_Ctrl_GPIOx_BASE
    ldr  r1,  [r1]                  @ r1 = LCD_Ctrl_GPIOx_BASE
    ldr  r2,  =LCD_RS_Pin           @ r2 = &LCD_RS_Pin
    ldrh r2,  [r2]                  @ r2 = LCD_RS_Pin
    strh r2,  [r1, #0x10]           @ GPIOx_BSRR, RS = 1
    ldr  r2,  =LCD_WR_Pin           @ r2 = &LCD_WR_Pin
    ldrh r2,  [r2]                  @ r2 = LCD_WR_Pin
    strh r2,  [r1, #0x14]           @ GPIOx_BRR,  WR = 0
    strh r2,  [r1, #0x10]           @ GPIOx_BSRR, WR = 1
    @ We do not need to wait 100-15=85ns since this function cannot be called again within 85ns
    bx   lr                         @ return
//! @endcond


/**
 * @fn      void lcdWriteReg(uint16_t data)
 * @brief   Write 16-bit data to LCD (RS = 0)
 * @param   data    Data to be written (r0)
 * @note    This function is written in ARM assembly language.
 *          WR control pulse "L" duration is 28ns @72MHz processor clock
 *          (Datasheet requires 15ns "L" and 100ns full write cycle).
 */
 //! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdWriteReg
.thumb
.thumb_func
lcdWriteReg:
    ldr  r1,  =LCD_Data_GPIOx_BASE  @ r1 = &LCD_Data_GPIOx_BASE
    ldr  r1,  [r1]                  @ r1 = LCD_Data_GPIOx_BASE
    strh r0,  [r1, #0x0C]           @ GPIOx_ODR = data
    ldr  r1,  =LCD_Ctrl_GPIOx_BASE  @ r2 = &LCD_Ctrl_GPIOx_BASE
    ldr  r1,  [r1]                  @ r1 = LCD_Ctrl_GPIOx_BASE
    ldr  r2,  =LCD_RS_Pin           @ r2 = &LCD_RS_Pin
    ldrh r2,  [r2]                  @ r2 = LCD_RS_Pin
    strh r2,  [r1, #0x14]           @ GPIOx_BRR, RS = 0
    ldr  r2,  =LCD_WR_Pin           @ r2 = &LCD_WR_Pin
    ldrh r2,  [r2]                  @ r3 = LCD_WR_Pin
    strh r2,  [r1, #0x14]           @ GPIOx_BRR,  WR = 0
    strh r2,  [r1, #0x10]           @ GPIOx_BSRR, WR = 1
    @ We do not need to wait 100-15=85ns since this function cannot be called again within 85ns
    bx   lr                         @ return
//! @endcond


/**
 * @fn      void lcdWriteMultipleData(uint16_t *pData, unsigned int count)
 * @brief   Write data buffer to LCD (RS = 0)
 * @param   pData   Pointer to data array to be written (r0)
 * @param   count   Length of the data array (r1)
 * @note    This function is written in ARM assembly language.
 *          Loading of new data and conditional jump slows down the writing cycle.
 *          WR control pulse "L" duration is 70ns and "H" duration is 110ns @ 72MHz processor clock.
 */
//! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdWriteMultipleData
.thumb
.thumb_func
lcdWriteMultipleData:
    push {r4, r5, lr}
    ldr  r2,  =LCD_Ctrl_GPIOx_BASE  @ r2 = &LCD_Ctrl_GPIOx_BASE
    ldr  r2,  [r2]                  @ r2 = LCD_Ctrl_GPIOx_BASE
    ldr  r3,  =LCD_RS_Pin           @ r3 = &LCD_RS_Pin
    ldrh r3,  [r3]                  @ r3 = LCD_RS_Pin
    strh r3,  [r2, #0x10]           @ GPIOx_BSRR, RS = 1
    ldr  r3,  =LCD_Data_GPIOx_BASE  @ r3 = &LCD_Data_GPIOx_BASE
    ldr  r3,  [r3]                  @ r3 = LCD_Data_GPIOx_BASE
    ldr  r4,  =LCD_WR_Pin           @ r4 = &LCD_WR_Pin
    ldr  r4,  [r4]                  @ r4 = LCD_WR_Pin
    add  r1,  r1                    @ r1 = r0 + r1 * 2 (each data is 2 bytes)
    add  r1,  r0, r1                @ end = r1
    ldrh r5,  [r0]                  @ r5 = *data, preload data
.Lwmd_loop:
    cmp  r0,  r1                    @ data - end ?
    bge  .Lwmd_finish               @ if (data >= end) goto finish
    strh r5,  [r3, #0x0C]           @ GPIOx_ODR = r5
    strh r4,  [r2, #0x14]           @ GPIOx_BRR, WR = 0
    ldrh r5,  [r0, #2]!             @ ++data; r5 = *data;
    strh r4,  [r2, #0x10]           @ GPIOx_BSRR, WR = 1
    b .Lwmd_loop;                   @ next
.Lwmd_finish:
    pop  {r4, r5, pc}
//! @endcond


/**
 * @fn      void lcdWriteRepeatingData(uint16_t data, unsigned int count)
 * @brief   Write same data to LCD multiple times (RS = 0)
 * @param   data    Data to be written (r0)
 * @param   count   Number of times to write the data (r1)
 * @note    This function is written in ARM assembly language.
 *          It writes databus once and toggles WR pin repeatedly.
 *          On 72MHz processor the toggle timing is 56ns "L" and 56ns "H".
 *          The idea of fast toggling WR originates from Andy Brown in his
 *          stm32plus library, more information can be found at:
 *          http://andybrown.me.uk/wk/2013/08/03/lg-kf700/
 */
//! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdWriteRepeatingData
.thumb
.thumb_func
lcdWriteRepeatingData:
    ldr  r2,  =LCD_Data_GPIOx_BASE  @ r2 = &LCD_Data_GPIOx_BASE
    ldr  r2,  [r2]                  @ r2 = LCD_Data_GPIOx_BASE
    strh r0,  [r2, #0x0C]           @ GPIOx_ODR = r0
    ldr  r3,  =LCD_Ctrl_GPIOx_BASE  @ r3 = &LCD_Ctrl_GPIOx_BASE
    ldr  r3,  [r3]                  @ r3 = LCD_Ctrl_GPIOx_BASE
    ldr  r2,  =LCD_RS_Pin           @ r2 = &LCD_RS_Pin
    ldrh r2,  [r2]                  @ r2 = LCD_RS_Pin
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, RS = 1
    ldr  r2,  =LCD_WR_Pin           @ r2 = &LCD_WR_Pin
    ldrh r2,  [r2]                  @ r2 = LCD_WR_Pin
    cmp  r1,  #40                   @ count - 40 ?
    blo  .Lwrd_lastlot              @ if (count < 40) goto lastlot
.Lwrd_batchloop:
    @ Begin 40 pulses
    @ Pulse 1
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 2
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 3
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 4
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 5
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 6
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 7
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 8
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 9
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 10
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 11
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 12
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 13
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 14
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 15
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 16
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 18
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 19
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 20
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 21
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 22
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 23
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 24
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 25
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 26
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 27
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 28
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 29
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 30
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 31
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 32
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 33
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 34
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 35
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 36
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 37
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 38
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 39
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 40
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    sub  r1,  #40                   @ count = count - 40
    cmp  r1,  #40                   @ count > 40?
    bhs  .Lwrd_batchloop
.Lwrd_lastlot:
    ldr  r0,  =.Lwrd_finish         @ scratch r0, jump = r0 = finish
    lsl  r1,  #4                    @ count = count * 16, each writing is 16 instructions
    sub  r0,  r1                    @ jump = jump - count
    orr  r0,  #1                    @ bit[0] = 1 stay in thumb mode
    bx   r0
    @ Begin 39 pulses
    @ Pulse 1
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 2
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 3
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 4
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 5
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 6
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 7
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 8
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 9
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 10
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 11
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 12
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 13
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 14
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 15
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 16
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 18
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 19
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 20
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 21
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 22
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 23
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 24
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 25
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 26
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 27
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 28
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 29
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 30
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 31
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 32
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 33
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 34
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 35
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 36
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 37
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 38
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    @ Pulse 39
    strh r2,  [r3, #0x14]           @ GPIOx_BRR,  WR = 0
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    strh r2,  [r3, #0x10]           @ GPIOx_BSRR, WR = 1
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
    mov  r0,  r0                    @ NOP
.Lwrd_finish:
    bx   lr
//! @endcond


/**
 * @fn      void lcdReadReg(void)
 * @brief   Read Register from LCD (RS = 1)
 * @return  16 bit Register data
 * @note    This function is written in ARM assembly language.
 *          RD control pulse "L" duration is 336ns @ 72MHz processor clock
 *          (Datasheet requires minimal 45ns "L" and 160ns full cycle for Register).
 *          Reading of Register is same as reading GRAM, but with different timing.
 *          Caller must first set Register address using lcdWriteReg(), then call
 *          this function to read Register value.
 */
//! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdReadReg
.thumb
.thumb_func
lcdReadReg:
    push {r4, lr}
    ldr  r1, =LCD_Ctrl_GPIOx_BASE   @ r1 = &LCD_Ctrl_GPIOx_BASE
    ldr  r1, [r1]                   @ r1 = LCD_Ctrl_GPIOx_BASE
    ldr  r2, =LCD_RS_Pin            @ r2 = &LCD_RS_Pin
    ldrh r2, [r2]                   @ r2 = LCD_RS_Pin
    strh r2, [r1, #0x10]            @ GPIOx_BSRR, RS = 1
    ldr  r2, =LCD_RD_Pin            @ r2 = &LCD_RD_Pin
    ldrh r2, [r2]                   @ r2 = LCD_RD_Pin
    strh r2, [r1, #0x14]            @ GPIOx_BRR, RD = 0
    @ Now we need to wait 45ns before register data are ready
    @ Do some meaningful things first
    @ Set data bus to input
    ldr  r3, =LCD_Data_GPIOx_BASE   @ r3 = &LCD_Data_GPIOx_BASE
    ldr  r3, [r3]                   @ r3 = LCD_Data_GPIOx_BASE
    mov  r4, #0x44444444            @ r4 = 0x44444444
    str  r4, [r3]                   @ DATA_CRL = 0x44444444
    str  r4, [r3, #4]               @ DATA_CRH = 0x44444444
    @ We've far exceeded 45ns
    ldrh r0, [r3, #8]               @ GPIOx_IDR, read bus
    strh r2, [r1, #0x10]            @ GPIOx_BSRR, RD = 1
    @ Again we need to kill 160-45=115ns
    @ Set bus back to output
    mov  r4, #0x11111111            @ r4 = 0x11111111
    str  r4, [r3]                   @ DATA_CRL = 0x44444444
    str  r4, [r3, #4]               @ DATA_CRH = 0x44444444
    @ Again we have exceeded 115ns
    pop  {r4, pc}                   @ return
//! @endcond


/**
 * @fn      void lcdReadData(void)
 * @brief   Read GRAM from LCD (RS = 1)
 * @return  16 bit GRAM data
 * @note    This function is written in ARM assembly language.
 *          RD control pulse "L" duration is 361ns @ 72MHz processor clock
 *          (Datasheet requires minimal 355ns "L" and 450ns full cycle for GRAM).
 *          Caller must first write Register (R22h) using lcdWriteReg(), then call
 *          this function to read GRAM value.
 */
//! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdReadData
.thumb
.thumb_func
lcdReadData:
    push {r4, lr}
    ldr  r1, =LCD_Ctrl_GPIOx_BASE   @ r1 = &LCD_Ctrl_GPIOx_BASE
    ldr  r1, [r1]                   @ r1 = LCD_Ctrl_GPIOx_BASE
    ldr  r2, =LCD_RS_Pin            @ r2 = &LCD_RS_Pin
    ldrh r2, [r2]                   @ r2 = LCD_RS_Pin
    strh r2, [r1, #0x10]            @ GPIOx_BSRR, RS = 1
    ldr  r2, =LCD_RD_Pin            @ r2 = &LCD_RD_Pin
    ldrh r2, [r2]                   @ r2 = LCD_RD_Pin
    strh r2, [r1, #0x14]            @ GPIOx_BRR, RD = 0
    @ Now we need to wait 355ns before GRAM data are ready
    @ Do some meaningful things then wait
    @ Set data bus to input
    ldr  r3, =LCD_Data_GPIOx_BASE   @ r3 = &LCD_Data_GPIOx_BASE
    ldr  r3, [r3]                   @ r3 = LCD_Data_GPIOx_BASE
    mov  r4, #0x44444444            @ r4 = 0x44444444
    str  r4, [r3]                   @ DATA_CRL = 0x44444444
    str  r4, [r3, #4]               @ DATA_CRH = 0x44444444
    @ Wait some more
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    ldrh r0, [r3, #8]               @ r0 = GPIOx_IDR, read bus
    strh r2, [r1, #0x10]            @ GPIOx_BRR, RD = 1
    @ Again we need to kill 450-355=95ns
    @ Set bus back to output
    mov  r4, #0x11111111            @ r4 = 0x11111111
    str  r4, [r3]                   @ DATA_CRL = 0x44444444
    str  r4, [r3, #4]               @ DATA_CRH = 0x44444444
    pop  {r4, pc}                   @ return
//! @endcond


/**
 * @fn      void lcdReadMultipleData(uint16_t *pData, unsigned int count)
 * @brief   Read multiple 16-bit data from LCD GRAM (RS = 1)
 * @param   pData   Pointer to the data array to store result (r0)
 * @param   count   Number of data to read (r1)
 * @note    RD control pulse "L" duration is 361ns and "H" duration is 112ns
 *          @ 72MHz processor clock
 *          (Datasheet requires 355ns "L" and 450ns full cycle for GRAM).
 *          Caller must first write Register (R22h) using @p lcdWriteReg, then call
 *          this function to read GRAM value.
 */
//! @cond DOXYGEN_SHOW_ASM
.align 2
.global lcdReadMultipleData
.thumb
.thumb_func
lcdReadMultipleData:
    push {r4, r5, lr}
    ldr  r2, =LCD_Ctrl_GPIOx_BASE   @ r2 = &LCD_Ctrl_GPIOx_BASE
    ldr  r2, [r2]                   @ r2 = LCD_Ctrl_GPIOx_BASE
    ldr  r3, =LCD_RS_Pin            @ r3 = &LCD_RS_Pin
    ldrh r3, [r3]                   @ r3 = LCD_RS_Pin
    strh r3, [r2, #0x10]            @ GPIOx_BSRR, RS = 1
    ldr  r3, =LCD_RD_Pin            @ r3 = &LCD_RD_Pin
    ldrh r3, [r3]                   @ r3 = LCD_RD_Pin
    add  r1,  r1                    @ r1 = r0 + r1 * 2 (each data is 2 bytes)
    add  r1,  r0, r1                @ end = r1
.Lrmd_loop:
    cmp  r0,  r1                    @ data - end ?
    bge  .Lrmd_finish               @ if (data >= end) goto finish
    strh r3, [r2, #0x14]            @ GPIOx_BRR, RD = 0
    @ Now we need to wait 355ns before GRAM data are ready
    @ Do some meaningful things then wait
    @ Set data bus to input, we can do this outisde the loop but anyway we have some time to kill
    ldr  r4, =LCD_Data_GPIOx_BASE   @ r4 = &LCD_Data_GPIOx_BASE
    ldr  r4, [r4]                   @ r4 = LCD_Data_GPIOx_BASE
    mov  r5, #0x44444444            @ r5 = 0x44444444
    str  r5, [r4]                   @ DATA_CRL = 0x44444444
    str  r5, [r4, #4]               @ DATA_CRH = 0x44444444
    @ Wait some more
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    mov  r0, r0                     @ NOP
    ldrh r5, [r4, #8]               @ r6 = GPIOx_IDR, read bus
    strh r5, [r0], #2               @ *data = r6; data++
    strh r3, [r2, #0x10]            @ GPIOx_BSRR, RD = 1
    @ Again we need to kill 450-355=95ns
    mov  r0, r0                     @ NOP
    b    .Lrmd_loop                 @ next
.Lrmd_finish:
    @ Set bus back to output
    mov  r5,  #0x11111111           @ r5 = 0x11111111
    str  r5,  [r4]                  @ DATA_CRL = 0x11111111
    str  r5,  [r4, #4]              @ DATA_CRH = 0x11111111
    pop  {r4, r5, pc}               @ return

.end

//! @endcond
