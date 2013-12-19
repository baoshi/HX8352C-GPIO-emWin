/**
  ******************************************************************************
  * @file    GUIDRV_HX8352C.h
  * @author  Baoshi
  * @version 0.1
  * @date    15-Nov-2013
  * @brief   emWin Driver for HX8352C based LCD
  ******************************************************************************
  * @attention
  *
  * This code is derivative work based on the STemWin which is licensed under
  * MCD-ST Liberty SW License Agreement V2, available at:
  *
  *     http://www.st.com/software_license_agreement_liberty_v2
  *
  * However this source code itself is licensed under (CC BY-SA 3.0), available at:
  *
  *     http://creativecommons.org/licenses/by-sa/3.0
  *
  * User should pay attention to the dual license embarrassment and when in doubt,
  * MCD-ST Liberty SW License Agreement V2 shall take precedence.
  *
  * THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY EXPRESS OR IMPLIED
  * WARRANTY.  IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES
  * ARISING FROM THE USE OF THIS SOFTWARE
  *
  ******************************************************************************
  */


#ifndef GUIDRV_HX8352C_H
#define GUIDRV_HX8352C_H


extern const GUI_DEVICE_API GUIDRV_HX8352C_API;


#define GUIDRV_HX8352C &GUIDRV_HX8352C_API


typedef struct _HX8352C_HW_API
{
    //! Reset LCD controller
    void (*pfWriteReg)(U16 data);
    //! Write 16-bit data to LCD (RS = 1)
    void (*pfWriteData)(U16 data);
    //! Write data buffer to LCD (RS = 0)
    void (*pfWriteMultipleData)(U16 *pData, unsigned int count);
    //! Write same data to LCD multiple times (RS = 0)
    void (*pfWriteRepeatingData)(U16 data, unsigned int count);
    //! Read Register from LCD (RS = 1)
    U16 (*pfReadReg)(void);
    //! Read GRAM from LCD (RS = 1)
    U16 (*pfReadData)(void);
    //! Read multiple 16-bit data from LCD GRAM (RS = 1)
    void (*pfReadMultipleData)(U16 *pData, unsigned int count);
} HX8352C_HW_API;


void GUIDRV_HX8352C_SetFunc(GUI_DEVICE *device, HX8352C_HW_API *pAPI);


#endif  // GUIDRV_HX8352C_H
