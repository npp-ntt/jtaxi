`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Siritsa D.S.
// 
// Create Date:    10:22:29 02/27/2015 
// Design Name: 
// Module Name:    fifo_bram_sync 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: ћодуль fifo_bram_sync максимально повтор€ет поведение макроса FIFO_SYNC_MACRO
//
// Dependencies:  
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////



/*
fifo_bram_sync
#(
    .Z                          ( 0     ),     //   Simulation delay
    .DATA_WIDTH                 ( 64    ),     //   Data width 
    .DEPTH                      ( 9     ),     //   Words count in FIFO, 2**DEPTH 
    .AFULL_OFFSET               ( 2     ),     //   Sets almost full threshold. How many DIN_WR for FULL flag occurrence 
    .AEMPTY_OFFSET              ( 2     )      //   Sets the almost empty threshold
)       
fifo_bram_sync      
(       
    .CLK                        (   ),     // in , u[1],
    .RST                        (   ),     // in , u[1],
    
    .DIN                        (   ),     // in , u[DATA_WIDTH],
    .DIN_WR                     (   ),     // in , u[1],
    .DIN_FULL                   (   ),     // out, u[1],        full flag
    .DIN_AFULL                  (   ),     // out, u[1],        almost full flag
    
    .DOUT                       (   ),     // out, u[DATA_WIDTH],
    .DOUT_RD                    (   ),     // in , u[1],        read enable
    .DOUT_EMPTY                 (   )      // out, u[1],        empty flag
    .DOUT_AEMPTY                (   )      // out, u[1],        almost empty flag
);
*/



module fifo_bram_sync
#(
    parameter   Z = 0,
    parameter   DATA_WIDTH = 64,
    parameter   DEPTH = 9,
    parameter   AFULL_OFFSET = 2,
    parameter   AEMPTY_OFFSET = 2
)
(
    input   wire                            CLK,
    
    input   wire                            RST,

    input   wire    [ DATA_WIDTH - 1 : 0 ]  DIN,
    input   wire                            DIN_WR,
    output  wire                            DIN_FULL,
    output  wire                            DIN_AFULL,
    
    output  wire    [ DATA_WIDTH - 1 : 0 ]  DOUT,
    input   wire                            DOUT_RD,
    output  wire                            DOUT_EMPTY,
    output  wire                            DOUT_AEMPTY

    );



reg     [ DEPTH - 1 : 0 ]       r_wr_adr = 0, r_rd_adr = 0;
(*KEEP = "TRUE"*)
reg     [ DEPTH     : 0 ]       r_fifo_wrd_cnt = 0; 
(*KEEP = "TRUE"*)
reg     [ DEPTH     : 0 ]       r_fifo_wrd_cnt1 = 0;

reg     [ DEPTH     : 0 ]       r_fifo_wrd_cnt_limit_full,r_fifo_wrd_cnt_limit_afull, r_fifo_wrd_cnt_limit_aempty;

wire                            w_full;
wire                            w_afull;
wire                            w_empty;
reg                             r_aempty = 0;
wire                            w_aempty;

reg                             r_error = 1'b0;

wire                            w_rd_en;

wire    [ DATA_WIDTH - 1 : 0]   w_bram_data;


assign w_rd_en = DOUT_RD;


ramb_infer
#(
    .LATENCY        (             1     ), // mem latency, e.g. for Virtex2 = 1, for Virtex5 in registered mode = 2, max latency = 3!
    .WIDTH          (     DATA_WIDTH    ), // ram width
    .DEPTH          (     DEPTH         ), // address width
    .WRITE_MODE_A   ( "WRITE_FIRST"     ), // PortA WRITE_MODE (WRITE_FIRST,NO_CHANGE,READ_FIRST)
    .WRITE_MODE_B   ( "WRITE_FIRST"     ), // PortB WRITE_MODE (WRITE_FIRST,NO_CHANGE,READ_FIRST)
    .INIT_FILE      ( ""                )  // init filename
)
ramb_infer_fifo_bram_sync
(
    .ENA            ( DIN_WR            ), // in,  u[    1], PortA enable
    .CLKA           ( CLK               ), // in,  u[    1], PortA clk
    .WEA            ( DIN_WR            ), // in,  u[    1], PortA write enable
    .ADDRA          ( r_wr_adr          ), // in,  u[DEPTH], PortA address
    .DIA            ( DIN               ), // in,  u[WIDTH], Write data for PortA
    .DOA            (                   ), // out, u[WIDTH], Read data from PortA

    .ENB            ( w_rd_en           ), // in,  u[    1], PortB enable
    .CLKB           ( CLK               ), // in,  u[    1], PortB clk
    .WEB            ( 1'b0              ), // in,  u[    1], PortB write enable
    .ADDRB          ( r_rd_adr          ), // in,  u[DEPTH], PortB address
    .DIB            (                   ), // in,  u[WIDTH], Write data for PortB
    .DOB            ( w_bram_data       )  // out, u[WIDTH], Read data from PortB
);


always @(posedge CLK)
if(RST == 1'b1)
begin
    r_wr_adr <=#Z 0;
end
else
begin
    if(DIN_WR == 1'b1)
        r_wr_adr <=#Z r_wr_adr + 1'b1;
end




always @(posedge CLK)
if(RST == 1'b1)
begin
    r_rd_adr <=#Z 0;
end
else
begin
    if(DOUT_RD == 1'b1)
        r_rd_adr <=#Z r_rd_adr + 1'b1;
    
end



always @(posedge CLK)
if(RST == 1'b1)
    r_fifo_wrd_cnt <=#Z 0;
else
    if((DIN_WR & ~DOUT_RD) && (w_full == 1'b0) )
        r_fifo_wrd_cnt <=#Z r_fifo_wrd_cnt + 1'b1;
    else
        if((~DIN_WR & DOUT_RD) && (|r_fifo_wrd_cnt == 1'b1))
            r_fifo_wrd_cnt <=#Z r_fifo_wrd_cnt - 1'b1;
            
            
always @(posedge CLK)
if(RST == 1'b1)
    r_fifo_wrd_cnt1 <=#Z 0;
else
    if((DIN_WR & ~DOUT_RD) && ~(r_fifo_wrd_cnt1 == r_fifo_wrd_cnt_limit_full) )
        r_fifo_wrd_cnt1 <=#Z r_fifo_wrd_cnt1 + 1'b1;
    else
        if((~DIN_WR & DOUT_RD) && (|r_fifo_wrd_cnt1 == 1'b1))
            r_fifo_wrd_cnt1 <=#Z r_fifo_wrd_cnt1 - 1'b1;            


  

always @(posedge CLK)
begin
    r_fifo_wrd_cnt_limit_afull      <=#Z {1'b0,{DEPTH{1'b1}}} - AFULL_OFFSET;
    r_fifo_wrd_cnt_limit_full       <=#Z {1'b1,{DEPTH{1'b0}}};
    r_fifo_wrd_cnt_limit_aempty     <=#Z AEMPTY_OFFSET;
end    
    
assign w_full =  (r_fifo_wrd_cnt == r_fifo_wrd_cnt_limit_full) ? 1'b1 : 1'b0;
assign w_afull = (r_fifo_wrd_cnt > r_fifo_wrd_cnt_limit_afull) ? 1'b1 : 1'b0;

assign w_empty  = (r_fifo_wrd_cnt1 == 0) ? 1'b1 : 1'b0;

assign w_aempty = (r_fifo_wrd_cnt1 <= r_fifo_wrd_cnt_limit_aempty) ? 1'b1 : 1'b0;

    
always @(posedge CLK)    
begin
    if( ((w_full == 1'b1) && (DIN_WR == 1'b1) && (RST == 1'b0)) || ((w_empty == 1'b1) && (DOUT_RD == 1'b1) && (RST == 1'b0)))
        r_error <=#Z 1'b1;
    else
        r_error <=#Z 1'b0;
end

`ifdef SIM
always @(posedge CLK)
begin
    if(r_error == 1'b1)
    begin
        $display("%m: r_error flag ! stopping");
        $stop();
    end
end
`endif


assign DIN_FULL     = w_full;
assign DIN_AFULL    = w_afull | w_full;


assign DOUT_EMPTY   = w_empty;
assign DOUT_AEMPTY  = w_aempty;

assign DOUT = w_bram_data;

endmodule
