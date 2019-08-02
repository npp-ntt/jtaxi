
`timescale 1 ns / 1 ps

	module JTAG2AXIS #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32,
		parameter integer DEPTH_FIFO_IN			= 5,
		parameter integer DEPTH_FIFO_OUT		= 5
	)
	(
		// Users to add ports here
		input wire  CAPTURE ,
		input wire  DRCK    ,
		input wire  RESET   ,
		input wire  RUNTEST ,
		input wire  SEL     ,
		input wire  SHIFT   ,
		input wire  UPDATE  ,
		input wire  TCK		,	
		input wire  TDI		,	
		input wire  TMS		,
		output wire TDO		,	
		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		input wire  S_AXIS_TREADY_O,
		// Data in
		output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA_O,
		// Byte qualifier
		output wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB_O,
		// Indicates boundary of last packet
		output wire  S_AXIS_TLAST_O,
		// Data is in valid
		output wire  S_AXIS_TVALID_O,
		
////////////////////////////////////
		output wire  S_AXIS_TREADY_I,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA_I,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB_I,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST_I,
		// Data is in valid
		input wire  S_AXIS_TVALID_I,

		output wire	w_empty_i
		
	);

(* srl_style = "register" *) reg [C_S_AXIS_TDATA_WIDTH+2:0] r_shift_regs;
reg [C_S_AXIS_TDATA_WIDTH+1:0] test_cnt;
wire							w_rd;
reg								r_rd;
reg 							r_tvalid_o;
reg 							r_tlast_o;
reg [C_S_AXIS_TDATA_WIDTH-1:0] 	r_tdata_o;

wire 							w_tvalid_o;
wire 							w_tlast_o;
wire [C_S_AXIS_TDATA_WIDTH-1:0]	w_tdata_o;

reg [ 2: 0]						r_sh_update;
wire							w_p_update;
wire							w_n_update;
wire							w_empty_o;
wire							w_full_o;
//wire							w_empty_i;
reg								r_empty_sh;

reg								r_direct_wr;
reg	[ 3: 0]						r_capture;
wire							w_rd_i;
reg	[ 1: 0]						r_update_shift_reg;
wire [C_S_AXIS_TDATA_WIDTH+1:0] w_dout_i;
wire 							w_full_i;
wire							w_n_capture;
reg								r_soft_rst;
reg 							r_rd_block;
	always @( posedge TCK )
		if ( !S_AXIS_ARESETN )
			begin
				r_shift_regs <= {(C_S_AXIS_TDATA_WIDTH+1){1'h0}};
				r_direct_wr <= 1'h0;
			end
		else
			if ( CAPTURE && r_rd_block && SEL )
				r_shift_regs <= {1'h1,w_dout_i};		
			else if ( SHIFT )
				r_shift_regs <= { TDI, r_shift_regs[C_S_AXIS_TDATA_WIDTH+2:1] };
				
assign TDO = r_shift_regs[0];	

// запись
	always @( posedge S_AXIS_ACLK )
		if ( !S_AXIS_ARESETN )
			r_sh_update <= 3'h0;
		else
			r_sh_update <= { r_sh_update[1:0], UPDATE };				
			
assign w_n_update = !r_sh_update[1] & r_sh_update[2]; 		
assign w_p_update = r_sh_update[1] & !r_sh_update[2]; 	
assign w_rd = (!w_empty_o & S_AXIS_TREADY_O);
	always @( posedge S_AXIS_ACLK )
		if ( !S_AXIS_ARESETN )
			r_rd <= 1'h0;
		else
			r_rd <= w_rd;

	always @( posedge S_AXIS_ACLK )
		if ( !S_AXIS_ARESETN )
			r_soft_rst <= 1'h0;
		else 
			if ( w_p_update && !r_shift_regs[C_S_AXIS_TDATA_WIDTH]&&r_shift_regs[C_S_AXIS_TDATA_WIDTH+1] )
				r_soft_rst <= 1'h1;
			else if ( w_n_update )
				r_soft_rst <= 1'h0;
				
			
fifo_bram_sync 
#(
    .Z                          ( 0     					),     //   Simulation delay
    .DATA_WIDTH                 ( C_S_AXIS_TDATA_WIDTH+2    ),     //   Data width 
    .DEPTH                      ( DEPTH_FIFO_OUT			),     //   Words count in FIFO, 2**DEPTH 
    .AFULL_OFFSET               ( 2     					),     //   Sets almost full threshold. How many DIN_WR for FULL flag occurrence 
    .AEMPTY_OFFSET              ( 2     					)      //   Sets the almost empty threshold
)       
fifo_o      
(       
    .CLK                        ( S_AXIS_ACLK  									),     // in , u[1],
    .RST                        ( ~S_AXIS_ARESETN | r_soft_rst					),     // in , u[1],
    
    .DIN                        ( r_shift_regs[C_S_AXIS_TDATA_WIDTH+1:0]  		),     // in , u[DATA_WIDTH],
    .DIN_WR                     ( w_n_update && !r_shift_regs[C_S_AXIS_TDATA_WIDTH+2] && !w_full_o/*r_direct_wr*/						),     // in , u[1],
    .DIN_FULL                   ( w_full_o										),     // out, u[1],        full flag
    .DIN_AFULL                  (   											),     // out, u[1],        almost full flag
    
    .DOUT                       ( {w_tlast_o,w_tvalid_o,w_tdata_o}				),     // out, u[DATA_WIDTH],
    .DOUT_RD                    ( w_rd && !w_empty_o							),     // in , u[1],        read enable
    .DOUT_EMPTY                 ( w_empty_o 									),     // out, u[1],        empty flag
    .DOUT_AEMPTY                (   											)      // out, u[1],        almost empty flag
);				


always @( posedge S_AXIS_ACLK )
	if ( !S_AXIS_ARESETN )
		begin
			r_tvalid_o <= {(C_S_AXIS_TDATA_WIDTH){1'h0}} ;
			r_tlast_o  <= 1'h0;
			r_tdata_o  <= 1'h0;
		end
	else		
		if ( r_rd )
			begin
				r_tvalid_o <= w_tvalid_o ;
				r_tlast_o  <= w_tlast_o  ;
				r_tdata_o  <= w_tdata_o  ;
			end
		else
			begin
				r_tvalid_o <= {(C_S_AXIS_TDATA_WIDTH){1'h0}} ;
				r_tlast_o  <= 1'h0;
				r_tdata_o  <= 1'h0;
			end			
	

assign S_AXIS_TLAST_O		= r_tlast_o;
assign S_AXIS_TVALID_O    	= r_tvalid_o;
assign S_AXIS_TDATA_O		= r_tdata_o;	

//чтение				
always @( posedge S_AXIS_ACLK )
	if ( !S_AXIS_ARESETN )
		r_capture <= 4'h0;
	else
		r_capture <= { r_capture[2:0], CAPTURE };

assign w_n_capture = !r_capture[1] & r_capture[2];		

always @( posedge S_AXIS_ACLK )
	if ( !S_AXIS_ARESETN )
		r_update_shift_reg <= 2'h0;
	else
		r_update_shift_reg <= {r_update_shift_reg[0],w_n_update/*w_rd_i*/};
		
always @( posedge S_AXIS_ACLK )
	if ( !S_AXIS_ARESETN )
		r_empty_sh <= 1'h0;	
	else
		if ( w_empty_i && w_n_update )
			r_empty_sh <= 1'h1;
		else if ( !w_empty_i )
			r_empty_sh <= 1'h0;

always @( posedge S_AXIS_ACLK )
	if ( !S_AXIS_ARESETN )
		r_rd_block <= 0;
	else
		if (w_n_update && r_rd_block)
			r_rd_block<=0;
		else if(w_n_update && (r_shift_regs[C_S_AXIS_TDATA_WIDTH+2]) && !r_empty_sh)
			r_rd_block<=1;				
			
fifo_bram_sync 
#(
    .Z                          ( 0     																			),     //   Simulation delay
    .DATA_WIDTH                 ( C_S_AXIS_TDATA_WIDTH+2    														),     //   Data width 
    .DEPTH                      ( DEPTH_FIFO_IN     																),     //   Words count in FIFO, 2**DEPTH 
    .AFULL_OFFSET               ( 0     																			),     //   Sets almost full threshold. How many DIN_WR for FULL flag occurrence 
    .AEMPTY_OFFSET              ( 0     																			)      //   Sets the almost empty threshold
)       																						                    
fifo_i      																						                
(       																						                    
    .CLK                        ( S_AXIS_ACLK  																		),     // in , u[1],
    .RST                        ( ~S_AXIS_ARESETN | r_soft_rst														),     // in , u[1],
																                                                    
    .DIN                        ( {S_AXIS_TLAST_I,S_AXIS_TVALID_I,S_AXIS_TDATA_I}  									),     // in , u[DATA_WIDTH],
    .DIN_WR                     ( S_AXIS_TVALID_I && !w_full_i														),     // in , u[1],
    .DIN_FULL                   ( w_full_i			  																),     // out, u[1],        full flag
    .DIN_AFULL                  (   																				),     // out, u[1],        almost full flag
																							                        
    .DOUT                       ( w_dout_i																			),     // out, u[DATA_WIDTH],
    .DOUT_RD                    ( w_p_update && !r_rd_block&& (r_shift_regs[C_S_AXIS_TDATA_WIDTH+2]) && !w_empty_i 	),     
    .DOUT_EMPTY                 ( w_empty_i 																		),      // out, u[1],        empty flag
    .DOUT_AEMPTY                (   																				)      // out, u[1],        almost empty flag
);	
assign S_AXIS_TREADY_I = !w_full_i;

	
endmodule
