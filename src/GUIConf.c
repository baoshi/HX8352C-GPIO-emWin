/**
  ******************************************************************************
  * @file    GUIConf.c
  * @author  Baoshi
  * @version 0.1
  * @date    03-Nov-2013
  * @brief   emWin GUI layer configuration
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

#include "GUI.h"


/*===========================================================================*/
/* Defines                                                                   */
/*===========================================================================*/


//! Define the available number of bytes available for the GUI
#define GUI_NUMBYTES  (1024) *  16   // x KByte


/*===========================================================================*/
/* Static Data                                                               */
/*===========================================================================*/


//! 32 bit aligned memory area
U32 _extMem[GUI_NUMBYTES / 4];


/*===========================================================================*/
/* Public Functions                                                          */
/*===========================================================================*/


/**
 * @brief   Called during GUI initialization
 */
void GUI_X_Config(void)
{
    GUI_ALLOC_AssignMemory(_extMem, GUI_NUMBYTES);
}


/*************************** End of file ****************************/
