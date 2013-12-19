/**
 * @brief A skeleton main.c
 */

#include <stddef.h>
#include <stm32f10x.h>
#include "GUI.h"


/*===========================================================================*/
/* Static Functions                                                          */
/*===========================================================================*/


/**
  * @brief  Configure GPIO Ports
  */
static void _ConfigGPIO()
{
}


/**
  * @brief  Configure NVIC
  */
static void _ConfigNVIC(void)
{
}


/**
  * @brief  Configure Timers
  */
static void _ConfigTimer(void)
{
}


/**
 * @brief   Configure SysTick
 */
void _ConfigSysTick(void)
{
    SysTick_Config(SystemCoreClock / 1000);  // 1ms
}


/*===========================================================================*/
/* Public Functions                                                          */
/*===========================================================================*/


extern void GUIDEMO_Main(void);

int main(void)
{
    // Setup STM32 system (clock, PLL and Flash configuration)
    SystemInit();

    // Configurations
    _ConfigSysTick();
    _ConfigGPIO();
    _ConfigNVIC();
    _ConfigTimer();

    // emWin requires CRC
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_CRC, ENABLE);

    GUI_Init();

    GUIDEMO_Main();

    return 0;
}


#ifdef USE_FULL_ASSERT
void assert_failed(uint8_t* file , uint32_t line)
{
  /* Infinite loop */
  /* Use GDB to find out why we're here */
  while (1);
}

#endif


/*************************** End of file ****************************/
