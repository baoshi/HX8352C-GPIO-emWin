/*********************************************************************
*                SEGGER Microcontroller GmbH & Co. KG                *
*        Solutions for real time microcontroller applications        *
**********************************************************************
*                                                                    *
*        (c) 1996 - 2013  SEGGER Microcontroller GmbH & Co. KG       *
*                                                                    *
*        Internet: www.segger.com    Support:  support@segger.com    *
*                                                                    *
**********************************************************************

** emWin V5.20 - Graphical user interface for embedded applications **
All  Intellectual Property rights  in the Software belongs to  SEGGER.
emWin is protected by  international copyright laws.  Knowledge of the
source code may not be used to write a similar product.  This file may
only be used in accordance with the following terms:

The software has been licensed to  ARM LIMITED whose registered office
is situated at  110 Fulbourn Road,  Cambridge CB1 9NJ,  England solely
for  the  purposes  of  creating  libraries  for  ARM7, ARM9, Cortex-M
series,  and   Cortex-R4   processor-based  devices,  sublicensed  and
distributed as part of the  MDK-ARM  Professional  under the terms and
conditions  of  the   End  User  License  supplied  with  the  MDK-ARM
Professional. 
Full source code is available at: www.segger.com

We appreciate your understanding and fairness.
----------------------------------------------------------------------
File        : AA_Text.c
Purpose     : Shows text with different antialiasing qualities
----------------------------------------------------------------------
*/

#include "GUIDEMO.h"

#if (SHOW_GUIDEMO_AATEXT)

#define XSIZE_MAX 320
#define YSIZE_MAX 240
#define BORDER    3

/*********************************************************************
*
*       Static const data
*
**********************************************************************
*/
/*********************************************************************
*
*       Static code
*
**********************************************************************
*/
/*********************************************************************
*
*       _DrawAlphaCircles
*/
static void _DrawAlphaCircles(int mx, int my, int r, int a, int FactorAA) {
  int Index;
  int x;
  int y;
  I32 SinHQ;
  I32 CosHQ;
  U32 a1000;
  U32 i;
  const GUI_COLOR aColor[] = {
    0xC00FFF38,
    0xC000FF8E,
    0xC000FCEA,
    0xC000B4FF,
    0xC0004EFF,
    0xC01304FF,
    0xC06E00FF,
    0xC0D200FF,
    0xC0FF00D2,
    0xC0FF006E,
    0xC0FF0413,
    0xC0FF4E00,
    0xC0FFB400,
    0xC0EAFC00,
    0xC08EFF00,
    0xC038FF0F
  };

  mx    *= FactorAA;
  my    *= FactorAA;
  r     *= FactorAA;
  a1000  = a * -1000;
  GUI_AA_EnableHiRes();
  GUI_AA_SetFactor(FactorAA);
  for (i = 0, Index = 0; i < 360000; i += 22500, Index++) {
    SinHQ = GUI__SinHQ(i + a1000);
    CosHQ = GUI__CosHQ(i + a1000);
    x     = (r * CosHQ) >> 16;
    y     = (r * SinHQ) >> 16;
    GUI_SetColor(aColor[Index % (int)GUI_COUNTOF(aColor)]);
    GUI_AA_FillCircle(mx + x, my + y, r);
  }
  GUI_AA_DisableHiRes();
}

/*********************************************************************
*
*       _DrawSample
*/
static void _DrawSample(GUI_RECT Rect, const GUI_FONT * pFont, const char * pText) {
  GUI_RECT CurrentRect;
  int      yDistDiv3;

  Rect.x0 += BORDER;
  Rect.y0 += BORDER;
  Rect.x1 -= BORDER;
  Rect.y1 -= BORDER;
  yDistDiv3      = (Rect.y1 - Rect.y0) / 3;
  CurrentRect.x0 = Rect.x0;
  CurrentRect.y0 = Rect.y0;
  CurrentRect.x1 = Rect.x0 + 59;
  CurrentRect.y1 = Rect.y0 + 3 * yDistDiv3;
  GUI_SetClipRect(&CurrentRect);
  //
  // Display info text
  //
  GUI_SetFont(GUI_FONT_13_ASCII);
  GUI_SetColor(GUI_WHITE);
  GUI_DispStringInRectWrap(pText, &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER, GUI_WRAPMODE_WORD);
  //
  // Alpha circles
  //
  GUI_MoveRect(&CurrentRect, 63, 0);
  GUI_SetBkColor(GUI_BLACK);
  GUI_Clear();
  _DrawAlphaCircles((CurrentRect.x0 + CurrentRect.x1) / 2, (CurrentRect.y0 + CurrentRect.y1) / 2, 35, 0, 4);
  GUI_SetColor(GUI_WHITE);
  GUI_SetFont(pFont);
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  //
  // Black to white gradient
  //
  CurrentRect.y0 = Rect.y0;
  CurrentRect.y1 = Rect.y0 + 3 * yDistDiv3;
  GUI_MoveRect(&CurrentRect, 63, 0);
  GUI_DrawGradientH(CurrentRect.x0, CurrentRect.y0, CurrentRect.x1, CurrentRect.y1, GUI_BLACK, GUI_WHITE);
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_SetColor(GUI_RED);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_SetColor(GUI_GREEN);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_SetColor(GUI_BLUE);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  //
  // RGB
  //
  CurrentRect.y0 = Rect.y0;
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_MoveRect(&CurrentRect, 63, 0);
  GUI_SetBkColor(GUI_RED);
  GUI_Clear();
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_SetBkColor(GUI_GREEN);
  GUI_Clear();
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_SetBkColor(GUI_BLUE);
  GUI_Clear();
  GUI_SetColor(GUI_WHITE);
  CurrentRect.y0 = Rect.y0;
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  //
  // RGB gradients
  //
  CurrentRect.y0 = Rect.y0;
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_MoveRect(&CurrentRect, 63, 0);
  GUI_DrawGradientV(CurrentRect.x0, CurrentRect.y0, CurrentRect.x1, CurrentRect.y1, GUI_RED,   GUI_BLACK);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DrawGradientV(CurrentRect.x0, CurrentRect.y0, CurrentRect.x1, CurrentRect.y1, GUI_GREEN, GUI_BLACK);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DrawGradientV(CurrentRect.x0, CurrentRect.y0, CurrentRect.x1, CurrentRect.y1, GUI_BLUE,  GUI_BLACK);
  CurrentRect.y0 = Rect.y0;
  CurrentRect.y1 = CurrentRect.y0 + yDistDiv3;
  GUI_SetColor(GUI_WHITE);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  GUI_MoveRect(&CurrentRect, 0, yDistDiv3);
  GUI_DispStringInRect("ABC", &CurrentRect, GUI_TA_HCENTER | GUI_TA_VCENTER);
  //
  // Disable application defined clip rectangle
  //
  GUI_SetClipRect(NULL);
}

/*********************************************************************
*
*       _DrawScreen
*/
static void _DrawScreen(void) {
  GUI_RECT Rect;
  int      TitleSize;
  int      xSize;
  int      ySize;
  int      xOff;
  int      yOff;


  TitleSize = GUIDEMO_GetTitleSize();
  xSize     = LCD_GetXSize();
  ySize     = LCD_GetYSize();
  if ((xSize < XSIZE_MAX) || (ySize < YSIZE_MAX)) {
    //
    // Do not show this demo on displays of too small dimensions.
    //
    return;
  }
  xOff      = (xSize - XSIZE_MAX) / 2;
  yOff      = ((ySize - TitleSize) - (YSIZE_MAX - TitleSize)) / 2;
  //
  // 4 bit anti-aliasing sample
  //
  Rect.x0   = xOff;
  Rect.y0   = TitleSize + yOff;
  Rect.x1   = xSize - xOff;
  Rect.y1   = TitleSize + (ySize - TitleSize) / 2 - 1;
  //_DrawText("Antialiased text\n(4 bpp)", &Rect);
  //GUI_SetFont(&GUI_FontAA4_32);
  _DrawSample(Rect, &GUI_FontAA4_32, "Antialiased text\n(4 bpp)");
  //
  // 2 bit anti-aliasing sample
  //
  Rect.y0   = Rect.y1 + 1;
  Rect.y1   = ySize - yOff;
  //_DrawText("Antialiased text\n(2 bpp)", &Rect);
  //GUI_SetFont(&GUI_FontAA2_32);
  _DrawSample(Rect, &GUI_FontAA2_32, "Antialiased text\n(2 bpp)");
}

/*********************************************************************
*
*       Public code
*
**********************************************************************
*/
/*********************************************************************
*
*       MainTask
*/
void GUIDEMO_AntialiasedText(void) {
  unsigned OldAlphaState;

  GUIDEMO_ShowIntro("Antialiased Text", "Output antialiased text\non different backgrounds.");
  GUIDEMO_DrawBk();
  GUIDEMO_DispTitle("Antialiased text sample");
  OldAlphaState = GUI_EnableAlpha(1);
  _DrawScreen();
  GUIDEMO_Wait(4000);
  GUI_EnableAlpha(OldAlphaState);
}

#else

void GUIDEMO_AntialiasedText(void) {}

#endif /* SHOW_GUIDEMO_AATEXT */

/*************************** End of file ****************************/
