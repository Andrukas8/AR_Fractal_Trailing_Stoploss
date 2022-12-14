// Inspired by tutorials of René Balke
// https://www.youtube.com/watch?v=3l8RyeQNmNo&ab_channel=Ren%C3%A9Balke

#include <Trade/Trade.mqh>

input int TslOffsetPoints = 30; // Points above/below Fractal candle offset
input ENUM_TIMEFRAMES TimeFrame = 5; // Timeframe
int handle;  //--- for fractal handle
int barsTotal;
double mainUpper = 0;
double mainLower = 0;

// ------------------------
int OnInit()
  {   
   handle = iFractals(_Symbol, TimeFrame);    
   return(INIT_SUCCEEDED);
  }

// -------------------------
void OnDeinit(const int reason)
  {

   
  }
// ------------------------
void OnTick()
  { 
  int bars = iBars(_Symbol,TimeFrame);
  int totalPos = PositionsTotal();
   
  if(barsTotal != bars && totalPos > 0) // New bar appeared on the chart
      {     
      barsTotal = bars;     
         
      double fracUpper[];
      double fracLower[];
            
      CopyBuffer(handle,UPPER_LINE,3,1,fracUpper);
      CopyBuffer(handle,LOWER_LINE,3,1,fracLower);
      
      if(fracUpper[0] != EMPTY_VALUE)
        {      
         mainUpper = NormalizeDouble(fracUpper[0] + TslOffsetPoints * _Point,4);
        }
      
      if(fracLower[0] != EMPTY_VALUE)
        {         
          mainLower = NormalizeDouble(fracLower[0]  - TslOffsetPoints * _Point,4);
        }               
                
        string text;
        text += "\n";
        text += " FRACTAL TRAILING STOPLOSS EA parameters\n";
        text += " EA TIMEFRAME => " + TimeFrame + "\n";
        text += " Offset points => " + TslOffsetPoints + "\n";        
        text += " Current Upper Fractal => " + mainUpper + "\n";
        text += " Current Lower Fractal => " + mainLower + "\n";
        text += " Positions total => " + totalPos;        
                
   // Changing the SL based on the Fractal
    for(int i=0;i<totalPos;i++)
        {
               ulong posTicket = PositionGetTicket(i);                               
               
               if(PositionSelectByTicket(posTicket)) // Selecting the position
                 {           
                  
                  if(PositionGetString(POSITION_SYMBOL) == _Symbol) // checking if the position is of the same tick
                    {
                     CTrade trade;
                     // getting data about the open position            
                     double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                     double posSl = PositionGetDouble(POSITION_SL);
                     double posTp = PositionGetDouble(POSITION_TP);
                     
                     double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                     double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);                                                              
                              
                     // --------------------
                     // --- BUY POSITION ---
                     // --------------------
                     
                     if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) // checking if the open position if has type BUY
                       {
                        // ---
                                         
                        if(posSl < mainLower && bid > mainLower)
                          {                 
                           double sl = mainLower;    
                                                           
                           if(sl > posSl)
                             {
                              
                              if(trade.PositionModify(posTicket,sl,posTp));
                                {
                                 Print(__FUNCTION__," > Position #",posTicket," was modified by regular tsl.");
                                }
                              }
                        }
                       }
                                                                                    
                       // ---------------------
                       // --- SELL POSITION ---
                       // ---------------------
                          
                       else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                                {
                        //---
                        if(posSl > mainUpper && ask < mainUpper)
                          {
                           double sl = mainUpper;
                           
                           if(sl < posSl || posSl == 0) //&& sl > mainUpper                     
                             {                      
                              if(trade.PositionModify(posTicket,sl,posTp));
                                {
                                 Print(__FUNCTION__," > Position #",posTicket," was modified.");
                                }
                             }
                         }                           
                       }
                    }
                 } // end of if PositionSelectByTicket
                                     
    } // end of for loop
    
         Comment(text);
         
   } // end of if(barstotal)
   
 } // end of OnTick function

   
  // --
