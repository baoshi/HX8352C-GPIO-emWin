/**
  ******************************************************************************
  * @file    GUIConf.h
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

#ifndef GUICONF_H
#define GUICONF_H

//! Multi layer/display support
#define GUI_NUM_LAYERS              (1)    // Maximum number of available layers

//! Multitasking support
#define GUI_OS                      (0)

//! Touchscreen support
#define GUI_SUPPORT_TOUCH           (0)


//! Default font
#define GUI_DEFAULT_FONT            &GUI_Font6x8

//! Other options
#define GUI_SUPPORT_MOUSE           (0)
#define GUI_SUPPORT_UNICODE         (0)
#define GUI_WINSUPPORT              (1)
#define GUI_SUPPORT_MEMDEV          (1)
#define GUI_SUPPORT_AA              (1)
#define WM_SUPPORT_STATIC_MEMDEV    (1)

#endif  // GUICONF_H

/*************************** End of file ****************************/
