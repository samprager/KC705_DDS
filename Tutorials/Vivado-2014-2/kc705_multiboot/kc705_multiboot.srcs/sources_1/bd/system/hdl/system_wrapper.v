//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.2 (win64) Build 928826 Thu Jun  5 18:17:50 MDT 2014
//Date        : Sat Jun 07 12:57:10 2014
//Host        : XCOJAMESM22 running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (SM_FAN_PWM,
    dip_switches_4bits_tri_i,
    led_8bits_tri_o,
    push_buttons_5bits_tri_i,
    reset,
    rs232_uart_rxd,
    rs232_uart_txd,
    spi_0_io0_io,
    spi_0_io1_io,
    spi_0_io2_io,
    spi_0_io3_io,
    spi_0_ss_io,
    sys_diff_clock_clk_n,
    sys_diff_clock_clk_p);
  output [0:0]SM_FAN_PWM;
  input [3:0]dip_switches_4bits_tri_i;
  output [7:0]led_8bits_tri_o;
  input [4:0]push_buttons_5bits_tri_i;
  input reset;
  input rs232_uart_rxd;
  output rs232_uart_txd;
  inout spi_0_io0_io;
  inout spi_0_io1_io;
  inout spi_0_io2_io;
  inout spi_0_io3_io;
  inout [0:0]spi_0_ss_io;
  input sys_diff_clock_clk_n;
  input sys_diff_clock_clk_p;

  wire [0:0]SM_FAN_PWM;
  wire [3:0]dip_switches_4bits_tri_i;
  wire [7:0]led_8bits_tri_o;
  wire [4:0]push_buttons_5bits_tri_i;
  wire reset;
  wire rs232_uart_rxd;
  wire rs232_uart_txd;
  wire spi_0_io0_i;
  wire spi_0_io0_io;
  wire spi_0_io0_o;
  wire spi_0_io0_t;
  wire spi_0_io1_i;
  wire spi_0_io1_io;
  wire spi_0_io1_o;
  wire spi_0_io1_t;
  wire spi_0_io2_i;
  wire spi_0_io2_io;
  wire spi_0_io2_o;
  wire spi_0_io2_t;
  wire spi_0_io3_i;
  wire spi_0_io3_io;
  wire spi_0_io3_o;
  wire spi_0_io3_t;
  wire [0:0]spi_0_ss_i_0;
  wire [0:0]spi_0_ss_io_0;
  wire [0:0]spi_0_ss_o_0;
  wire spi_0_ss_t;
  wire sys_diff_clock_clk_n;
  wire sys_diff_clock_clk_p;

IOBUF spi_0_io0_iobuf
       (.I(spi_0_io0_o),
        .IO(spi_0_io0_io),
        .O(spi_0_io0_i),
        .T(spi_0_io0_t));
IOBUF spi_0_io1_iobuf
       (.I(spi_0_io1_o),
        .IO(spi_0_io1_io),
        .O(spi_0_io1_i),
        .T(spi_0_io1_t));
IOBUF spi_0_io2_iobuf
       (.I(spi_0_io2_o),
        .IO(spi_0_io2_io),
        .O(spi_0_io2_i),
        .T(spi_0_io2_t));
IOBUF spi_0_io3_iobuf
       (.I(spi_0_io3_o),
        .IO(spi_0_io3_io),
        .O(spi_0_io3_i),
        .T(spi_0_io3_t));
IOBUF spi_0_ss_iobuf_0
       (.I(spi_0_ss_o_0),
        .IO(spi_0_ss_io[0]),
        .O(spi_0_ss_i_0),
        .T(spi_0_ss_t));
system system_i
       (.SM_FAN_PWM(SM_FAN_PWM),
        .SPI_0_io0_i(spi_0_io0_i),
        .SPI_0_io0_o(spi_0_io0_o),
        .SPI_0_io0_t(spi_0_io0_t),
        .SPI_0_io1_i(spi_0_io1_i),
        .SPI_0_io1_o(spi_0_io1_o),
        .SPI_0_io1_t(spi_0_io1_t),
        .SPI_0_io2_i(spi_0_io2_i),
        .SPI_0_io2_o(spi_0_io2_o),
        .SPI_0_io2_t(spi_0_io2_t),
        .SPI_0_io3_i(spi_0_io3_i),
        .SPI_0_io3_o(spi_0_io3_o),
        .SPI_0_io3_t(spi_0_io3_t),
        .SPI_0_ss_i(spi_0_ss_i_0),
        .SPI_0_ss_o(spi_0_ss_o_0),
        .SPI_0_ss_t(spi_0_ss_t),
        .dip_switches_4bits_tri_i(dip_switches_4bits_tri_i),
        .led_8bits_tri_o(led_8bits_tri_o),
        .push_buttons_5bits_tri_i(push_buttons_5bits_tri_i),
        .reset(reset),
        .rs232_uart_rxd(rs232_uart_rxd),
        .rs232_uart_txd(rs232_uart_txd),
        .sys_diff_clock_clk_n(sys_diff_clock_clk_n),
        .sys_diff_clock_clk_p(sys_diff_clock_clk_p));
endmodule
