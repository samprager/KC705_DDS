`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:58:09 02/02/2012 
// Design Name: 
// Module Name:    gtxe2_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gtxe2_top(
    input user_clock_p,
    input user_clock_n,
    output si5324_out_p,
    output si5324_out_n,
    input si5324_in_p,
    input si5324_in_n,
    output SMA_out_p,
    output SMA_out_n
    );


   wire clk_out;
wire clock_bufg;

reg q;

IBUFDS IBUFDS_inst_user_clock(
	.O(clock_out), // Buffer output
	.I(user_clock_p), // Diff_p buffer input (connect directly to top-level port)
	.IB(user_clock_n) // Diff_n buffer input (connect directly to top-level port)
);

BUFG BUFG_inst_user_clock (
      .O(clock_bufg), // 1-bit output: Clock output
      .I(clock_out)
		);


 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_out_clock_inst_user_clock (
      .Q(clock_out_ddr),   // 1-bit DDR output
      .C(clock_bufg),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b1), // 1-bit data input (positive edge)
      .D2(1'b0), // 1-bit data input (negative edge)
      .R(),   // 1-bit reset
      .S()    // 1-bit set
   );

	
OBUFDS OBUFDS_inst_user_clock (
      .O (si5324_out_p),     // Diff_p output (connect directly to top-level port)
      .OB(si5324_out_n),   // Diff_n output (connect directly to top-level port)
      .I (clock_out_ddr)      // Buffer input 
   );
  
  
IBUFDS_GTE2 IBUFDS_GTE2_inst_si5324(
	.O (clock_out_si5324), // Buffer output
	.I (si5324_in_p), // Diff_p buffer input (connect directly to top-level port)
	.IB(si5324_in_n) // Diff_n buffer input (connect directly to top-level port)
);


BUFG BUFG_inst_si5324 (
      .O(clock_bufg_si5324), // 1-bit output: Clock output
      .I(clock_out_si5324)
		);


 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_out_clock_si5324 (
      .Q(clock_out_ddr_si5324),   // 1-bit DDR output
      .C(clock_bufg_si5324),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b1), // 1-bit data input (positive edge)
      .D2(1'b0), // 1-bit data input (negative edge)
      .R(),   // 1-bit reset
      .S()    // 1-bit set
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_inst_si5324 (
      .O (SMA_out_p),     // Diff_p output (connect directly to top-level port)
      .OB(SMA_out_n),   // Diff_n output (connect directly to top-level port)
      .I (clock_out_ddr_si5324)      // Buffer input 
   );
  
  

endmodule
