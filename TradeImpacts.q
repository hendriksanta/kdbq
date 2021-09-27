/// Trade Impact Analytics


// #################################
// In this script we look to analyse market parameters around the point of trade. Such analysis is particularly useful
// if one wants to extract specific patters related to for example market impact or liquidity provision.

// To kick off, we put together some dummy data and define some helper functions. Our dummy data consists of trade data
// as well market (price) tick data in the format one would usually expect to see in the context of a trading business.
// #################################

// Dummy Data:

// Two helper functions:

// Box Muller: (to generate random normals from q's uniform pseudo-random number generator
bm:{[n;mu;sig]
    pi: acos -1;
    u1:(c:ceiling[n%2])?1.0;
    u2:c?1.0;
    mu+sig*n#(sqrt[-2*log u1]*cos 2*pi*u2), sqrt[-2*log u2]*sin 2*pi*u1
    };

// Pivot function to reformat our data:
.util.pivot:{[c;g;d;t] /c: column to pivot by |g:column to group by | d: column being pivoted | t: table being pivoted
            u:`$distinct string asc t c; / create distinct list of ids. Needed in case not every id is represented at every date.
            pf:{x#(`$string y)!z}; /pivot function
            p:?[t;();g!g,:();(pf;`u;c;d)]; /exec u#(id!price)by date:date from t -> if more than one d by c,g -> then first is taken; not a list
            p}


// Dummy tick data:
// We generate some dummy tick pricing data. Note we don't pay attention to the stochastic process here but simply generate
// some random process using our box muller function:
getTickData:{[n]
    time: 2021.01.01T00:00:00.000 + sums 1e-7*"j"$1+n?10;
    price: 1.0 + sums 1e-5*"j"$-10+n?20;
    price: 1.0 + sums 1e-5*"j"$bm[n;0;2];
    sym: `EURUSD;
    tickdata: update time:"p"$time from (flip(`time`sym`price!(time;sym;price)));
    tickdata
    }


// Dummy trade data:
// We generate some dummy trade data. For simplicity, assume standard clip size of 1mio here:
getTradeData:{[n]
    tradeId:1+til n;
    time:2021.01.01T00:00:00.000 + sums 1e-5*"j"$1+n?10;
    side: (0 1!-1 1)[n?2];
    sym: `EURUSD;
    size: 1000000;
    trades:update time: "p"$time from flip(`time`tradeId`sym`side`size!(time;tradeId;sym;side;size));
    trades: `time`tradeId`sym`side`size`tradedPrice xcol aj [`sym`time;trades;tickdata];
    trades
    }


// We now focus on the evolution of price paths around trade time. That is we use q's 'as of join' to retrieve pricing ticks
// at specific times pre and post trade, for each trade:

pre_post_tradeImpact:{[trades]
    // define the intervals to look at (here in seconds, pre (-1) and post(1) trade):
    postTradeImpactPeriods:1e9*asc 1_raze(-1 1)*\:0 0.1 0.5 1 2 3 4 5 6 7 8 9 10 15 20 25 30 40 50 60;
    // add a row for each trade and each time step:
    trades: ungroup update time:time+\:"j"$postTradeImpactPeriods,rowId:count[i]#enlist postTradeImpactPeriods%1e9 from trades;
    // as of join with tickdata
    tradeImpact: aj[`sym`time;trades;select`g#sym,time,price from tickdata];
    tradeImpact
    }


// Using our price paths around trade time, we can now aggregate them and weight them by trade size (in our dummy data
// we chose unit size so not important, but generally want to weight it). The aggregation allows us to reveal specific
// patterns: for instance, assume we look at informed flow or flow with high market impact: in such instances we will
// observe persistent, non-random signature curves emerge that are a direct, convenient reflection of average trade
// profitablity.

signature:{[tradeImpact]
    ti:select from tradeImpact;
    ti:0!.util.pivot[`rowId;`tradeId`side`size`tradedPrice;`price;] ti;
    ti: ti where all each not null ti;
    px:`tradeId`side`size`tradedPrice _ ti;
    px:(neg log ti[`tradedPrice])+'log px;
    px:(ti[`side]*ti[`size])*'px;
    px:10000 * sum px % sum ti[`size];
    px
    }

// Run all functions:

// 5000 price ticks:
tickdata:getTickData[5000]

// 20 trades:
trades:getTradeData[20]

// get trade impacts table:
tradeImpact:pre_post_tradeImpact[trades]

// get aggregated trade impacts across all trades:
signature[tradeImpact]