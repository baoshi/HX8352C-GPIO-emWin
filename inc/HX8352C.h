/**
  ******************************************************************************
  * @file    HX8352C.h
  * @author  Baoshi
  * @version 0.1
  * @date    28-Nov-2013
  * @brief   Hardware interface driver for HX8352C LCD controller
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
  ******************************************************************************
  */

#ifndef HX8352C_H
#define HX8352C_H

// Low level functions implemented using ARM assembly

//! @fn  void lcdWriteData(uint16_t data)
void lcdWriteData(uint16_t data);
//! @fn  void lcdWriteReg(uint16_t data)
void lcdWriteReg(uint16_t data);
//! @fn  void lcdWriteRepeatingData(uint16_t data, unsigned int count)
void lcdWriteRepeatingData(uint16_t data, unsigned int count);
//! @fn  void lcdWriteMultipleData(uint16_t *pData, unsigned int count)
void lcdWriteMultipleData(uint16_t *pData, unsigned int count);
//! @fn uint16_t lcdReadData(void)
uint16_t lcdReadData(void);
//! @fn uint16_t lcdReadReg(void)
uint16_t lcdReadReg(void);
//! @fn void lcdReadMultipleData(uint16_t *pData, unsigned int count)
void lcdReadMultipleData(uint16_t *pData, unsigned int count);

// C functions
//! @fn void lcdReset(void)
void lcdReset(void);
//! @fn void lcdInit(void)
void lcdInit(void);
//! @fn void lcdOn(void);
void lcdOn(void);
//! @fn void lcdOff(void);
void lcdOff(void);


#endif // HX8352C_H
