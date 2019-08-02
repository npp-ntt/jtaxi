//////////////////////////////////////////////////////////////////////////////////
//
// Project        : interface 4G
// Function       : general purpose ramb block (inferred)
// Engineer       : Victor Lee
// Created        : 25.03.2011
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps
/*
ramb_infer
    #(
        .LATENCY      (             1 ), // mem latency, e.g. for Virtex2 = 1, for Virtex5 in registered mode = 2, max latency = 3!
        .WIDTH        (            36 ), // ram width
        .DEPTH        (            10 ), // address width
        .WRITE_MODE_A ( "WRITE_FIRST" ), // PortA WRITE_MODE (WRITE_FIRST,NO_CHANGE,READ_FIRST)
        .WRITE_MODE_B ( "WRITE_FIRST" ), // PortB WRITE_MODE (WRITE_FIRST,NO_CHANGE,READ_FIRST)
        .INIT_FILE    ( "ramb_init.h" )  // init filename
    )
    ramb_infer_inst
    (
        .ENA   (  ), // in,  u[    1], PortA enable
        .CLKA  (  ), // in,  u[    1], PortA clk
        .WEA   (  ), // in,  u[    1], PortA write enable
        .ADDRA (  ), // in,  u[DEPTH], PortA address
        .DIA   (  ), // in,  u[WIDTH], Write data for PortA
        .DOA   (  ), // out, u[WIDTH], Read data from PortA
    
        .ENB   (  ), // in,  u[    1], PortB enable
        .CLKB  (  ), // in,  u[    1], PortB clk
        .WEB   (  ), // in,  u[    1], PortB write enable
        .ADDRB (  ), // in,  u[DEPTH], PortB address
        .DIB   (  ), // in,  u[WIDTH], Write data for PortB
        .DOB   (  )  // out, u[WIDTH], Read data from PortB
    );
*/

module ramb_infer
#(
    parameter integer       LATENCY = 1,
    parameter integer       WIDTH = 36,
    parameter integer       DEPTH = 9,
    parameter               WRITE_MODE_A = "WRITE_FIRST",
    parameter               WRITE_MODE_B = "WRITE_FIRST",
    parameter               INIT_FILE    = ""
)
(
    input  wire                     ENA,
    input  wire                     CLKA,
    input  wire                     WEA,
    input  wire [ DEPTH - 1 :  0 ]  ADDRA,
    input  wire [ WIDTH - 1 :  0 ]  DIA,
    output wire [ WIDTH - 1 :  0 ]  DOA,

    input  wire                     ENB,
    input  wire                     CLKB,
    input  wire                     WEB,
    input  wire [ DEPTH - 1 :  0 ]  ADDRB,
    input  wire [ WIDTH - 1 :  0 ]  DIB,
    output wire [ WIDTH - 1 :  0 ]  DOB
);

integer i;
(* RAM_STYLE = "BLOCK" *)
reg     [ WIDTH-1 : 0 ] r_ramb_infer [(2**DEPTH)-1:0];
reg     [ WIDTH-1 : 0 ] r_ramb_douta_0 = 0;
reg     [ WIDTH-1 : 0 ] r_ramb_douta_1 = 0;
reg     [ WIDTH-1 : 0 ] r_ramb_douta_2 = 0;
reg     [ WIDTH-1 : 0 ] r_ramb_doutb_0 = 0;
reg     [ WIDTH-1 : 0 ] r_ramb_doutb_1 = 0;
reg     [ WIDTH-1 : 0 ] r_ramb_doutb_2 = 0;

wire    [ WIDTH-1 : 0 ] w_ramb_douta [2:0];
wire    [ WIDTH-1 : 0 ] w_ramb_doutb [2:0];

assign w_ramb_douta [0] = r_ramb_douta_0;
assign w_ramb_douta [1] = r_ramb_douta_1;
assign w_ramb_douta [2] = r_ramb_douta_2;

assign w_ramb_doutb [0] = r_ramb_doutb_0;
assign w_ramb_doutb [1] = r_ramb_doutb_1;
assign w_ramb_doutb [2] = r_ramb_doutb_2;

assign DOA = w_ramb_douta[LATENCY-1];
assign DOB = w_ramb_doutb[LATENCY-1];

initial
begin
    if (INIT_FILE != "")
        $readmemh(INIT_FILE, r_ramb_infer, 0, ((2**DEPTH) - 1));
    else
    begin
        for (i = 0; i < (2**DEPTH); i = i + 1)
            r_ramb_infer[i] = 0;
    end
end

always @(posedge CLKA)
begin
    if ( ENA == 1'b1 )
    begin
        if ( WEA == 1'b1 )
        begin
            r_ramb_infer[ADDRA] <=#1 DIA;
        end

        if ( WEA == 1'b1 )
        begin
            case ( WRITE_MODE_A )
            "WRITE_FIRST":
                begin
                    r_ramb_douta_0 <=#1 DIA;
                end
            "NO_CHANGE":
                begin
                    r_ramb_douta_0 <=#1 r_ramb_douta_0;
                end
            "READ_FIRST":
                begin
                    r_ramb_douta_0 <=#1 r_ramb_infer[ADDRA];
                end
            default:
                begin
                    r_ramb_douta_0 <=#1 DIA;
                end
            endcase
        end
        else
            r_ramb_douta_0 <=#1 r_ramb_infer[ADDRA];

        r_ramb_douta_1 <=#1 r_ramb_douta_0;
        r_ramb_douta_2 <=#1 r_ramb_douta_1;
    end
end

always @(posedge CLKB)
begin
    if ( ENB == 1'b1 )
    begin
        if ( WEB == 1'b1 )
        begin
            r_ramb_infer[ADDRB] <=#1 DIB;
        end

        if ( WEB == 1'b1 )
        begin
            case ( WRITE_MODE_B )
            "WRITE_FIRST":
                begin
                    r_ramb_doutb_0 <=#1 DIB;
                end
            "NO_CHANGE":
                begin
                    r_ramb_doutb_0 <=#1 r_ramb_doutb_0;
                end
            "READ_FIRST":
                begin
                    r_ramb_doutb_0 <=#1 r_ramb_infer[ADDRB];
                end
            default:
                begin
                    r_ramb_doutb_0 <=#1 DIB;
                end
            endcase
        end
        else
            r_ramb_doutb_0 <=#1 r_ramb_infer[ADDRB];

        r_ramb_doutb_1 <=#1 r_ramb_doutb_0;
        r_ramb_doutb_2 <=#1 r_ramb_doutb_1;
    end
end
endmodule