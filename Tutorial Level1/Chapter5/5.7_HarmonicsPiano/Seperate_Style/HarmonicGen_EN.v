/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			HarmonicGen_EN.v
*- Top Module name: 	HarmonicGen_EN
  - Submodules:		sin_anyfreq, ampAdjust, lookup_tables, SINE_LUT, ampAdjust, DeltaSigma
*- Description:			Generate a digtial data containing fundamental frequency and 2nd harmonics
*- 
*- Example of Usage:
       - This code generates a fundamental frequency and the 2nd harmonics at 25% of the 
	magnitude. The fundamental frequency is controlled by parameter M, which is calculated
	as M = 358*f0. The output HarmOut is 11 bit to leave room for the overflow bit. You can also
	change this to 10-bit but keep in mind that some frequency may get clipped.
	
       - Addional note: this module has a Enable controlled pin
	   
* - Read more details in Chapter 5 (complex piano) of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module HarmonicGen # (parameter M = 93664)
(
	input clk, key, EN_n,
	output wire [10:0] HarmOut
);

wire [9:0] signal1;
wire [9:0] dac_Data1;	
sin_anyfreq # (.M(M)) SIN1 (clk, signal1);						
ampAdjust #(.numerator(256)) ampSIN1 (clk, signal1, dac_Data1);

wire [9:0] signal2;
wire [9:0] dac_Data2;
sin_anyfreq # (.M(M*2)) SIN2 (clk, signal2);						
ampAdjust #(.numerator(64)) ampSIN2 (clk, signal2, dac_Data2);

assign HarmOut = EN_n ?(dac_Data1 + dac_Data2):0;	// only generate output when EN_n is activated
endmodule



/**********************************************************************************************/
/******************  Instantiate this module to generate 10-bit sin data *******************/
module sin_anyfreq # (
    parameter M = 93664				// Tune this value for different frequencies of the SIN wave
									// For M = 93664, you will get f_out = 261.63Hz
)
(
	input clk,               
	output [9:0] sin_digital      
);
	
reg [31:0] 	accumulator;				// Here we used N = 32 thus the phase accumulator has 2^N states!
always @(posedge clk) begin
	accumulator <= accumulator + M;  	
end

lookup_tables u1 (accumulator[31:24],sin_digital);
endmodule


/**************** This module generates a complete cycle of a 10-bit SIN wave **************/
module lookup_tables (
	input  	[7:0] 	phase,
	output 	[9:0] 	sin_out
);
wire    [9:0]   sin_out;
reg   	[5:0] 	address;
wire   	[1:0] 	sel;
wire   	[8:0] 	sine_table_out;
reg     [9:0]   sine_onecycle_amp;
assign sin_out = sine_onecycle_amp[9:0];
assign sel = phase[7:6];
SINE_LUT u1 (address, sine_table_out);
always @(sel or sine_table_out) begin
	case(sel)
	2'b00: 	begin
			sine_onecycle_amp = 9'h1ff + sine_table_out[8:0];
			address = phase[5:0];
	     	end
  	2'b01: 	begin
			sine_onecycle_amp = 9'h1ff + sine_table_out[8:0];
			address = ~phase[5:0];
	     	end
  	2'b10: 	begin
			sine_onecycle_amp = 9'h1ff - sine_table_out[8:0];
			address = phase[5:0];
     		end
  	2'b11: 	begin
			sine_onecycle_amp = 9'h1ff - sine_table_out[8:0];
			address = ~ phase[5:0];
     		end
	endcase
end
endmodule
 
 
/**************** This module is a look-up table for 1/4 data of a 10-bit SIN wave **************/
module SINE_LUT (
	input  [5:0] address,
	output [8:0] sin
);
reg    [8:0] sin;
always @(address) begin
       case(address)	
           6'h0: sin=9'h0;
           6'h1: sin=9'hC;
           6'h2: sin=9'h19;
           6'h3: sin=9'h25;
           6'h4: sin=9'h32;
           6'h5: sin=9'h3E;
           6'h6: sin=9'h4B;
           6'h7: sin=9'h57;
           6'h8: sin=9'h63;
           6'h9: sin=9'h70;
           6'ha: sin=9'h7C;
           6'hb: sin=9'h88;
           6'hc: sin=9'h94;
           6'hd: sin=9'hA0;
           6'he: sin=9'hAC;
           6'hf: sin=9'hB8;
           6'h10: sin=9'hC3;
           6'h11: sin=9'hCF;
           6'h12: sin=9'hDA;
           6'h13: sin=9'hE6;
           6'h14: sin=9'hF1;
           6'h15: sin=9'hFC;
           6'h16: sin=9'h107;
           6'h17: sin=9'h111;
           6'h18: sin=9'h11C;
           6'h19: sin=9'h126;
           6'h1a: sin=9'h130;
           6'h1b: sin=9'h13A;
           6'h1c: sin=9'h144;
           6'h1d: sin=9'h14E;
           6'h1e: sin=9'h157;
           6'h1f: sin=9'h161;
           6'h20: sin=9'h16A;
           6'h21: sin=9'h172;
           6'h22: sin=9'h17B;
           6'h23: sin=9'h183;
           6'h24: sin=9'h18B;
           6'h25: sin=9'h193;
           6'h26: sin=9'h19B;
           6'h27: sin=9'h1A2;
           6'h28: sin=9'h1A9;
           6'h29: sin=9'h1B0;
           6'h2a: sin=9'h1B7;
           6'h2b: sin=9'h1BD;
           6'h2c: sin=9'h1C3;
           6'h2d: sin=9'h1C9;
           6'h2e: sin=9'h1CE;
           6'h2f: sin=9'h1D4;
           6'h30: sin=9'h1D9;
           6'h31: sin=9'h1DD;
           6'h32: sin=9'h1E2;
           6'h33: sin=9'h1E6;
           6'h34: sin=9'h1E9;
           6'h35: sin=9'h1ED;
           6'h36: sin=9'h1F0;
           6'h37: sin=9'h1F3;
           6'h38: sin=9'h1F6;
           6'h39: sin=9'h1F8;
           6'h3a: sin=9'h1FA;
           6'h3b: sin=9'h1FC;
           6'h3c: sin=9'h1FD;
           6'h3d: sin=9'h1FE;
           6'h3e: sin=9'h1FF;
           6'h3f: sin=9'h1FF;
       endcase
	end
endmodule

/**********************************************************************************************/
/********************************  Instantiate ampAdjust module ***************************/
module ampAdjust #(parameter numerator = 256)				
(	
    input clk,
    input [9:0] digitalSignal,
    output[9:0] dac_Data
);

reg [17:0] amp_data;
always @(posedge clk) 
	amp_data = digitalSignal * numerator;	
	
assign dac_Data = amp_data[17:8]; 	
endmodule