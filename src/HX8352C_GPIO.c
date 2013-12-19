/**
  ******************************************************************************
  * @file    HX8352C_GPIO.c
  * @author  Baoshi
  * @version 0.2
  * @date    8-Dec-2013
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
  *         Please note I have no intention to prompt my work by using Andy's
  *         name and stm32plus library.
  ******************************************************************************
  */

#include <stddef.h>
#include <stm32f10x.h>
#include "HX8352C.h"


/*===========================================================================*/
/* Defines                                                                   */
/*===========================================================================*/


// LCD 16-bit data bus  GPIOB
// Reset                GPIOC.4
// RS                   GPIOC.5
// WR                   GPIOC.6
// RD                   GPIOC.7
// CS                   Wired to GND

/** \brief GPIOx_BASE of the port connected to LCD data bus. Must be constant for correct timing. */
const uint32_t LCD_Data_GPIOx_BASE = GPIOB_BASE;
/** \brief GPIOx_BASE of the port connected to LCD control lines. Must be constant for correct timing. */
const uint32_t LCD_Ctrl_GPIOx_BASE = GPIOC_BASE;
/** \brief GPIO_Pin_x of the LCD Reset pin. */
const uint16_t LCD_RST_Pin         = GPIO_Pin_4;
/** \brief GPIO_Pin_x of the LCD RS pin. Must be constant for correct timing. */
const uint16_t LCD_RS_Pin          = GPIO_Pin_5;
/** \brief GPIO_Pin_x of the LCD Reset pin. Must be constant for correct timing. */
const uint16_t LCD_WR_Pin          = GPIO_Pin_6;
/** \brief GPIO_Pin_x of the LCD Reset pin. Must be constant for correct timing. */
const uint16_t LCD_RD_Pin          = GPIO_Pin_7;


/*===========================================================================*/
/* Static Functions                                                          */
/*===========================================================================*/


// An external delay_ms() function is needed. We pluck it from emWin
extern void  GUI_Delay(int Period);
#define _DelayMS GUI_Delay


/**
 * @brief   Configure GPIO port
 */
static void _ConfigPort(void)
{
    GPIO_InitTypeDef gpioInit;

    // Enable GPIO clock
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB | RCC_APB2Periph_GPIOC, ENABLE);
    // Turn on the clock for the alternate function register (must be done before disable JTAG)
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
    // Disable JTAG interface to free up PB3 and PB4
    GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE);

    // TFT Back Light
    //GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    //GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    //GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    //GPIO_Init(GPIOB, &GPIO_InitStructure);

    // Control lines
    gpioInit.GPIO_Pin = LCD_RST_Pin | LCD_RS_Pin | LCD_WR_Pin | LCD_RD_Pin;
    gpioInit.GPIO_Mode = GPIO_Mode_Out_PP;
    gpioInit.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, &gpioInit);

    // Data bus
    gpioInit.GPIO_Speed = GPIO_Speed_10MHz;
    gpioInit.GPIO_Mode = GPIO_Mode_Out_PP;
    gpioInit.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3 | GPIO_Pin_4 | GPIO_Pin_5 | GPIO_Pin_6 | GPIO_Pin_7
                                | GPIO_Pin_8 | GPIO_Pin_9 | GPIO_Pin_10 | GPIO_Pin_11 | GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
    GPIO_Init((GPIO_TypeDef *)LCD_Data_GPIOx_BASE, &gpioInit);

    // Initialize control bits
    //GPIO_SetBits(GPIOB, GPIO_Pin_0 );    // Back LIGHT
    GPIO_SetBits((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, LCD_RST_Pin);   // RST = 1
    GPIO_SetBits((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, LCD_RD_Pin);    // RD = 1
    GPIO_SetBits((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, LCD_WR_Pin);    // WR = 1
}


/*===========================================================================*/
/* Public Functions                                                          */
/*===========================================================================*/


/**
 * @brief   Reset LCD Controller
 */
void lcdReset(void)
{
    GPIO_ResetBits((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, LCD_RST_Pin); // Pull RESET low
    _DelayMS(1); // 10us is enough
    GPIO_SetBits((GPIO_TypeDef *)LCD_Ctrl_GPIOx_BASE, LCD_RST_Pin); // RESET high
    _DelayMS(120); // Long enough reset during STB Out mode
}


/**
 * @brief   Initialize GPIO ports and LCD controller
 */
void lcdInit(void)
{
    // Configure ports, etc
    _ConfigPort();
    // Pulse LCD RESET
    lcdReset();
    // Begin HX8352C initialization sequence
    // Power Voltage Setting
    lcdWriteReg(0x001A); lcdWriteData(0x0004); // BT[2:0]=100, VCL=-VCI; VGH=VCI+2DDVDH; VGL=-2DDVDH
    lcdWriteReg(0x001B); lcdWriteData(0x008C); // VCIRE=1; VRH[4:0]=0Ch, VREG1=(2.5v*1.9)=4.75V
    // VCOM offset
    lcdWriteReg(0x0023); lcdWriteData(0x0000); // SELVCM=0, R24h and R25h selects VCOM
    lcdWriteReg(0x0024); lcdWriteData(0x0040); // VCM[6:0]=1000000, VCOMH voltage=VREG1*0.748 (originally 5F)
    lcdWriteReg(0x0025); lcdWriteData(0x000F); // VDV[4:0]=01111, VCOMH amplitude=VREG*1.00
    lcdWriteReg(0x002D); lcdWriteData(0x0006); // NOW[2:0]=110, Gate output non-overlap period = 6 clocks
    GUI_Delay(20);
    // Power on Setting
    lcdWriteReg(0x0018); lcdWriteData(0x0007); // RADJ[3:0]=0111, Display frame rate 60Hz
    lcdWriteReg(0x0019); lcdWriteData(0x0001); // OSC_EN=1, start OSC
    lcdWriteReg(0x001C); lcdWriteData(0x0006); // AP[2:0]=110, High OPAMP current (default 011)
    lcdWriteReg(0x0001); lcdWriteData(0x0000); // DSTB=0, out deep sleep
    lcdWriteReg(0x001F); lcdWriteData(0x0088); // STB=0
    GUI_Delay(5);
    lcdWriteReg(0x001F); lcdWriteData(0x0080); // DK=0
    GUI_Delay(5);
    lcdWriteReg(0x001F); lcdWriteData(0x0090); // PON=1
    GUI_Delay(5);
    lcdWriteReg(0x001F); lcdWriteData(0x00D0); // VCOMG=1
    GUI_Delay(5);
    lcdWriteReg(0x0017); lcdWriteData(0x0005); // IFPF[2:0]=101, 16-bit/pixel
    // Panel Configuration
    lcdWriteReg(0x0036); lcdWriteData(0x0011); // REV_PANEL=1, SM_PANEL=1, GS_PANEL=1, SS_PANEL=1
    //lcdWriteReg(0x0029); lcdWriteData(0x0031); // NL[5:0]=110001, 400 lines
    //lcdWriteReg(0x0071); lcdWriteData(0x001A); // RTN0
    //Gamma 2.2 Setting
    lcdWriteReg(0x0040); lcdWriteData(0x0000);
    lcdWriteReg(0x0041); lcdWriteData(0x0045);
    lcdWriteReg(0x0042); lcdWriteData(0x0045);
    lcdWriteReg(0x0043); lcdWriteData(0x0004);
    lcdWriteReg(0x0044); lcdWriteData(0x0000);
    lcdWriteReg(0x0045); lcdWriteData(0x0008);
    lcdWriteReg(0x0046); lcdWriteData(0x0023);
    lcdWriteReg(0x0047); lcdWriteData(0x0023);
    lcdWriteReg(0x0048); lcdWriteData(0x0077);
    lcdWriteReg(0x0049); lcdWriteData(0x0040);
    lcdWriteReg(0x004A); lcdWriteData(0x0004);
    lcdWriteReg(0x004B); lcdWriteData(0x0000);
    lcdWriteReg(0x004C); lcdWriteData(0x0088);
    lcdWriteReg(0x004D); lcdWriteData(0x0088);
    lcdWriteReg(0x004E); lcdWriteData(0x0088);
}


/**
 * @brief   Execute LCD power on sequence and turn on backlight
 */
void lcdOn(void)
{
    lcdWriteReg(0x0028); lcdWriteData(0x0038); //GON=1; DTE=1; D[1:0]=10
    _DelayMS(40);
    lcdWriteReg(0x0028); lcdWriteData(0x003C); //GON=1; DTE=1; D[1:0]=11
    // TODO: Turn on backlight
}


/**
 * @brief   Execute LCD power off sequence and turn off backlight
 */
void lcdOff(void)
{
    // TODO: Turn off backlight
    lcdWriteReg(0x0028); lcdWriteData(0x0038); //GON=1; DTE=1; D[1:0]=10
    _DelayMS(40);
    lcdWriteReg(0x0028); lcdWriteData(0x0030); //GON=1; DTE=1; D[1:0]=00
}
