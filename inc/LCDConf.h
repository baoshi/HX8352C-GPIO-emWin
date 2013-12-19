/**
  ******************************************************************************
  * @file    LCDConf.h
  * @author  Baoshi
  * @version 0.1
  * @date    03-Nov-2013
  * @brief   emWin LCD driver layer configuration
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

#ifndef LCDCONF_H
#define LCDCONF_H

/**
 * @name    Configuration for panel rotation
 * @note    Normal rotation:    SWAP_XY = 0, MIRROR_X = 0, MIRROR_Y = 0
 *          Rotate 90:          SWAP_XY = 1, MIRROR_X = 1, MIRROR_Y = 0
 *          Rotate 180:         SWAP_XY = 0, MIRROR_X = 1, MIRROR_Y = 1
 *          Rotate 270:         SWAP_XY = 1, MIRROR_X = 0, MIRROR_Y = 1
 * @{
 */


//! Swap X-Y axis
#define LCD_SWAP_XY 1

//! Mirror X axis (before swapping)
#define LCD_MIRROR_X 0

//! Mirror Y axis (before swapping)
#define LCD_MIRROR_Y 1

/* @} */

#endif // LCDCONF_H

/*************************** End of file ****************************/
