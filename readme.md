#Custom display driver for SEGGER emWin

This project demonstrates how to write a display driver for SEGGER emWin. The specific distrubition of emWin used is STMicroelectronics' STemWin v1.1.0 (emWin 5.22). The demo runs with STM32F103RCT6 and a 400x240 HX8352C based LCD panel.

Also included in this project is the GPIO 16-bit LCD interface library. Most hardware access code are written in ARM assembly to achieve optimal timing. With 72MHz processor clock 8846000 pixels/second filling rate is measured.

The compiling environment is documented at http://www.ba0sh1.com/opensource-stm32-development/

Descriptions for this project can be found at  http://www.ba0sh1.com/write-a-display-driver-for-emwin/
 