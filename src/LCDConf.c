/**
  ******************************************************************************
  * @file    LCDConf.c
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
#include <stm32f10x.h>
#include <GUI.h>
#include "GUIDRV_HX8352C.h"
#include "HX8352C.h"


/*===========================================================================*/
/* Public Functions                                                          */
/*===========================================================================*/

/**
 * @brief   Display driver configuration
 */
void LCD_X_Config(void)
{
    GUI_DEVICE *pDevice;
    HX8352C_HW_API hwAPI = {0};

    // Set display driver and color conversion
    pDevice = GUI_DEVICE_CreateAndLink(GUIDRV_HX8352C, GUICC_565, 0, 0);
    // Display driver is compile-time configured. Setting (virtual) screen size is not necessary
    //LCD_SetSizeEx (0, 400, 200);
    //LCD_SetVSizeEx(0, 400, 200);
    // Port access functions
    hwAPI.pfWriteReg = lcdWriteReg;
    hwAPI.pfWriteData = lcdWriteData;
    hwAPI.pfWriteRepeatingData = lcdWriteRepeatingData;
    hwAPI.pfWriteMultipleData = lcdWriteMultipleData;
    hwAPI.pfReadData = lcdReadData;
    hwAPI.pfReadMultipleData = lcdReadMultipleData;
    // Give driver access to the functions
    GUIDRV_HX8352C_SetFunc(pDevice, &hwAPI);
}


/**
 * @brief   Command handler for display driver
 * @param   layerIndex  Index of the driver (layer) which generates the command
 * @param   cmd         Command code
 * @param   pData       Command specific data
 * @return  Command process result
 * @retval  0   Command handled
 * @retval  -1  Command not handled
 * @retval  <-1 Error
 */
int LCD_X_DisplayDriver(unsigned layerIndex, unsigned cmd, void *pData)
{
    int r = -1;

    if (layerIndex == 0)    // Only first controller is handled
    {
        switch (cmd)
        {
        case LCD_X_INITCONTROLLER:
            lcdInit();
            r = 0;
            break;
        case LCD_X_ON:
            lcdOn();
            r = 0;
            break;
        case LCD_X_OFF:
            lcdOff();
            r = 0;
            break;
        }
    }
    return r;
}


/*************************** End of file ****************************/

