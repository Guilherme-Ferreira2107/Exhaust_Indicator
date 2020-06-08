//+------------------------------------------------------------------+
//|                                                Quebra Broker.mq5 |
//|                                               Guilherme Ferreira |
//|                                  guilhermeferreira2107@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Guilherme Ferreira"
#property link      "guilhermeferreira2107@gmail.com"
#property version   "1.0"      
#property description "How to use:"
#property description "When there are GREEN arrows, open BUY orders for the NEXT candle."
#property description "When there are RED arrows, open SELL orders for the NEXT candle."
#property description "Exclusive for: Mini Índice and Forex"
#property description "Recommended Graphic Time: 5 MINUTES"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Plot BUY
#property indicator_label1  "ARROW_BUY"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- Plot SELL
#property indicator_label2  "ARROW_SELL"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

//--- Plot RSI
#property indicator_label3  "RSI"
#property indicator_type3   DRAW_NONE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- Buffers
double         RSI_Buffer[];
double         Buy_Buffer[];
double         Sell_Buffer[];

//--- Parameter
input int   RSI_Period = 3;   // Período RSI
input int   RSI_Max = 92;     // Sensibilidade Máxima
input int   RSI_Min = 8;      // Sensibilidade Mínima

int OnInit(){  
   SetIndexBuffer(0,Buy_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Sell_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,RSI_Buffer,INDICATOR_DATA);
   
   PlotIndexSetInteger(0,PLOT_ARROW,225);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,25);
   PlotIndexSetInteger(1,PLOT_ARROW,226);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-25);
     
//--- Design
   long colorHigh = C'0,172,80';
   long colorLow = C'224,71,56';
   long colorBackground = C'0,0,25';
   long colorCandleDoji = clrLightSlateGray;
   long colorASK = C'224,71,56';
   long colorForeground = clrDimGray;
   
   long handler=ChartID();
     
   if(handler>0) {
      ChartSetInteger(handler,CHART_AUTOSCROLL,true);
      ChartSetInteger(handler,CHART_SHIFT,true);
      ChartSetInteger(handler,CHART_MODE,CHART_CANDLES);
      ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,colorBackground);
      ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,0,colorHigh);
      ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,0,colorLow);
      ChartSetInteger(0,CHART_COLOR_CHART_UP,0,colorHigh);
      ChartSetInteger(0,CHART_COLOR_CHART_DOWN,0,colorLow);
      ChartSetInteger(0,CHART_COLOR_CHART_LINE,0,colorCandleDoji);
      ChartSetInteger(0,CHART_COLOR_FOREGROUND,0,colorForeground);
      ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,colorForeground);
      ChartSetInteger(0,CHART_COLOR_BID,0,clrDarkOrange);
      ChartSetInteger(0,CHART_COLOR_ASK,0,colorHigh);
      ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,0,colorLow);
      ChartSetInteger(0,CHART_COLOR_LAST,0,clrDarkOrange);
   }
   
   return(INIT_SUCCEEDED);
}
   
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
                 
//--- Copy RSI
   CopyBuffer(iRSI(_Symbol,_Period,RSI_Period,PRICE_CLOSE),0,0,rates_total,RSI_Buffer); 
 
   for(int i=MathMax(5,prev_calculated-1); i<rates_total; i++) {   
      bool superCall = RSI_Buffer[i] < RSI_Min && RSI_Buffer[i-1] > RSI_Min;
      bool superSell = RSI_Buffer[i] > RSI_Max && RSI_Buffer[i-1] < RSI_Max;   
      
      Buy_Buffer[i] = superCall ? low[i] : 0;
      
      Sell_Buffer[i] = superSell ? high[i] : 0;   
   }

   return(rates_total);
}