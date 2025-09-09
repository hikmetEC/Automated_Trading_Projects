#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>


CTrade trade;

input double LOT_SIZE = 0.01;
input int RSI_PERIOD = 14;
input int FAST_MA_PERIOD = 20;
input int SLOW_MA_PERIOD = 200;
input int TP_PIPS = 500;
input int SL_PIPS = 500;


int RSI_func(double &rsi_array[]){
   int x = 0;
   if(rsi_array[0] < 30) x = 1;
   else if(rsi_array[0] > 70) x = 2;

   
   return x;
}

int MA_func(double &fastMA_array[], double &slowMA_array[]){
   int x = 0;
   if(fastMA_array[0] < slowMA_array[0] && fastMA_array[1] > slowMA_array[1]) //buy
   {
      x= 1;
   }
   
   else if(fastMA_array[0] > slowMA_array[0] && fastMA_array[1] < slowMA_array[1]) //sell 
   {
      x= 2;
   }
   
   return x;
}

int OnInit()
  {
   Print("Hello World!");
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   Print("Closed.");
  }

void OnTick(){
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT, 0);
   
   if(timestamp != time) {
      timestamp = time;
      
      // RSI
      static int handleRSI = iRSI(_Symbol,PERIOD_CURRENT, RSI_PERIOD, PRICE_CLOSE);
      double RSI_array[];
      CopyBuffer(handleRSI, 0,0,1,RSI_array);
      ArraySetAsSeries(RSI_array,true);
      
      //Slow MA(period = 200)
      static int handleSlowMA = iMA(_Symbol,PERIOD_CURRENT, SLOW_MA_PERIOD, 0, MODE_SMA, PRICE_CLOSE);
      double slowMA_array[];
      CopyBuffer(handleSlowMA,0,1,2,slowMA_array);
      ArraySetAsSeries(slowMA_array,true);
      
      //Fast MA(period = 20)
      static int handleFastMA = iMA(_Symbol,PERIOD_CURRENT, FAST_MA_PERIOD, 0, MODE_SMA, PRICE_CLOSE);
      double FastMA_array[];
      CopyBuffer(handleFastMA,0,1,2,FastMA_array);
      ArraySetAsSeries(FastMA_array,true);
      /*
      //Momentum
      static int handleMomentum = iMomentum(_Symbol,PERIOD_CURRENT,20,PRICE_CLOSE);
      double Momentum_array[];
      CopyBuffer(handleMomentum, 0,0,2,Momentum_array);
      ArraySetAsSeries(Momentum_array,true);
      */
      //Volumes
      //no code now
      
      if(RSI_func(RSI_array) == 1 && MA_func(FastMA_array, slowMA_array) == 1 ) { //buy
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double sl = ask - SL_PIPS*point;
         double tp  = ask + TP_PIPS*point;
         trade.Buy(LOT_SIZE,_Symbol, ask, sl, tp, "Bought!");
      }
      else if(RSI_func(RSI_array) == 2 && MA_func(FastMA_array, slowMA_array) == 2 ){ //sell
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double sl = bid + SL_PIPS*point;
         double tp  = bid - TP_PIPS*point;
         trade.Sell(LOT_SIZE,_Symbol, bid, sl, tp, "Sold!");
      }
      
   }


}

