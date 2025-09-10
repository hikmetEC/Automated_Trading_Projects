//+------------------------------------------------------------------+
//|                                    LowRiskEA_Debug.mq5           |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

input double LotSize        = 0.01;
input int    StopLoss       = 200;
input int    TakeProfit     = 400;
input int    RSIPeriod      = 14;
input double RSIOverbought  = 70.0;
input double RSIOversold    = 30.0;
input int    MAPeriod       = 50;
input ENUM_MA_METHOD MAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE MAPrice  = PRICE_CLOSE;

int rsiHandle, maHandle;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   rsiHandle = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE);
   maHandle  = iMA(_Symbol, _Period, MAPeriod, 0, MAMethod, MAPrice);
   if(rsiHandle == INVALID_HANDLE || maHandle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles");
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
   if(maHandle  != INVALID_HANDLE) IndicatorRelease(maHandle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   datetime currentBar = iTime(_Symbol, _Period, 0);
   if(currentBar == lastBarTime) return; // only act once per bar
   lastBarTime = currentBar;

   double rsiBuf[2], maBuf[2];
   if(CopyBuffer(rsiHandle, 0, 1, 1, rsiBuf) < 1) return;
   if(CopyBuffer(maHandle,  0, 1, 1, maBuf)  < 1) return;

   double rsiValue = rsiBuf[0];
   double maValue  = maBuf[0];
   double lastClose = iClose(_Symbol, _Period, 1);

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // --- Print debug info
   PrintFormat("DEBUG: Bar=%s RSI=%.2f MA=%.5f Close=%.5f",
               TimeToString(currentBar), rsiValue, maValue, lastClose);

   if(PositionSelect(_Symbol)) return;

   // --- BUY
   if(rsiValue < RSIOversold && lastClose < maValue)
   {
      double sl = ask - StopLoss * _Point;
      double tp = ask + TakeProfit * _Point;
      if(trade.Buy(LotSize, _Symbol, ask, sl, tp))
         Print("BUY opened at ", ask);
      else
         Print("BUY failed: ", _LastError);
   }

   // --- SELL
   if(rsiValue > RSIOverbought && lastClose > maValue)
   {
      double sl = bid + StopLoss * _Point;
      double tp = bid - TakeProfit * _Point;
      if(trade.Sell(LotSize, _Symbol, bid, sl, tp))
         Print("SELL opened at ", bid);
      else
         Print("SELL failed: ", _LastError);
   }
}
//+------------------------------------------------------------------+
