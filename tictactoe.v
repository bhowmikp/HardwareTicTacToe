`timescale 1ns / 1ns // `timescale time_unit/time_precision
module test(SW, CLOCK_50, KEY, HEX0, HEX1, HEX2, GPIO);
	input [8:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2;
	output [35:0] GPIO;
	wire [8:0] grd;
	wire [8:0] data_in;
	wire go, ld_x, ld_o;
	wire reset;
	wire reset_sb;
	wire to_menu;
	wire [3:0] win, x_score, o_score;
	
	assign data_in = SW[8:0];  //assign input wire to hardware	
	assign go = KEY[3]; 			//end turn button
	assign reset = KEY[2]; 		//reset match button
	assign reset_sb = KEY[1];  //reset scoreboard
	assign to_menu = KEY[0]; 
	
	control C0(
		.clk(CLOCK_50),
		.reset(reset),

		.go(go),

		.ld_x(ld_x),
		.ld_o(ld_o)
	);

	datapath D0(
		.clk(CLOCK_50),
		.reset(reset),

		.ld_x(ld_x),
		.ld_o(ld_o),

		.data_in(data_in),
		.x_score(x_score),
		.o_score(o_score),
		.win(win),
		.reset_sb(reset_sb),
		.LED_1({GPIO[0], GPIO[2], GPIO[4], GPIO[6], GPIO[8], GPIO[10], GPIO[12], GPIO[14], GPIO[16]}),
		.LED_2({GPIO[18], GPIO[20], GPIO[22], GPIO[24], GPIO[26], GPIO[28], GPIO[30], GPIO[32], GPIO[34]}),
		.grd(grd[8:0])
	);
	
	hex_decoder H0(
        .hex_digit(o_score),
        .segments(HEX0)
	);
	hex_decoder H1(
        .hex_digit(x_score),
        .segments(HEX1)
	);	
	hex_decoder H2(
        .hex_digit(win),
        .segments(HEX2)
	);	
endmodule

module singleledtest(l1);
	output l1;
	assign l1=1;
endmodule

module control(
	input clk,
   input reset,
   input go,
   output reg  ld_x, ld_o
   );
	
	reg [3:0] current_state, next_state; 
    
	localparam  S_LOAD_X      = 5'd0,
				 S_LOAD_X_WAIT   = 5'd1,
				 S_LOAD_O        = 5'd2,
				 S_LOAD_O_WAIT   = 5'd3;
				 /*S_CHOOSE_MODE   = 5'd4,
				 S_CHOOSE_MODE_WAIT = 5'd5;*/

	// Next state logic aka our state table
	always@(*)
	begin: state_table 
			case (current_state)
				 S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
				 S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_O; // Loop in current state until go signal goes low
				 S_LOAD_O: next_state = go ? S_LOAD_O_WAIT : S_LOAD_O; // Loop in current state until value is input
				 S_LOAD_O_WAIT: next_state = go ? S_LOAD_O_WAIT : S_LOAD_X; // Loop in current state until go signal goes low
			default:     next_state = S_LOAD_X;
	  endcase
	end // state_table


	// Output logic aka all of our datapath control signals
	always @(*)
	begin: enable_signals
		// By default make all our signals 0
		ld_x = 1'b0;
		ld_o = 1'b0;

		case (current_state)
			S_LOAD_X: begin
				ld_x = 1'b1;
			end
			S_LOAD_O: begin
				ld_o = 1'b1;
			end8:0
			/*S_CHOOSE_MODE: begin
				
			end
			default: //choose mode*/
		endcase
	end // enable_signals

	// current_state registers
	always@(posedge clk)
	begin: state_FFs
	  if(!reset)
			current_state <= S_LOAD_O_WAIT;
	  else
			current_state <= next_state;
	end 

endmodule

module datapath(
    clk,
     reset,
    data_in,
	 ld_x, ld_o,
    ld_r,
	 x_score, o_score, win,
	LED_1, LED_2, reset_sb,
	 grd
    );
	input clk;
	input reset, reset_sb;
	input [8:0] data_in;
	input ld_x, ld_o;
	input ld_r;
	output reg [0:8] LED_1, LED_2;
	output reg [8:0] grd;
    
	reg [8:0] x, o; // input registers
	output [3:0] x_score, o_score, win;
	reg [3:0] x_score, o_score, win;
	
	initial begin //init grids to 0
		grd = 9'b0_0000_0000;
		x = 9'b0_0000_0000;
		o = 9'b0_0000_0000;
		x_score = 4'h0;
		o_score = 4'h0;
		win = 4'h0;
	end
    
   // Registers x,o with respective input logic
	always@(posedge clk) begin
		if(!reset_sb) begin
			x_score = 4'h0;
			o_score = 4'h0;
		end
		if(!reset) begin
			grd = 9'b0_0000_0000; 
			x = 9'b0_0000_0000;
			o = 9'b0_0000_0000;
			win = 4'h0;
			LED_1 = 9'b0_0000_0000;
			LED_2 = 9'b0_0000_0000;	
		end
		else begin
			if (ld_x && !win) begin
			integer i;
			reg mult_input;
			mult_input = 0;		
				for (i=0; i<9; i=i+1) begin
					if(!mult_input) begin
						if (data_in[i]) begin //input x is 1
							if (grd[i] == 1'b0 && o[i] == 1'b0 && x[i] == 1'b0) begin //grid at input x is empty and not multiple input
								grd[i] = 1'b1;  //set grid val to filled
								x[i] = 1'b1;  //set x val to 1
								mult_input = 1;
							end
						end
					end
				end
				if(x[0] && x[3] && x[6]) //col 1
					win = 4'h1;
				else if(x[1] && x[4] && x[7]) //col 2
					win = 4'h1;
				else if(x[2] && x[5] && x[8]) //col 3
					win = 4'h1;
				else if(x[0] && x[1] && x[2]) //row 1
					win = 4'h1;
				else if(x[3] && x[4] && x[5]) //row 2
					win = 4'h1;
				else if(x[6] && x[7] && x[8]) //row 3
					win = 4'h1;
				else if(x[0] && x[4] && x[8]) //diag (\)
					win = 4'h1;
				else if(x[2] && x[4] && x[6]) //diag (/)
					win = 4'h1;
				else
					win = 4'h0;
				LED_1 = x;
				if (win == 4'h1) begin //check win
					x_score = x_score + 4'h1;
				end
				else begin
					reg tie;
					tie = 1'b1;
					for (i=0; i<9; i=i+1) begin
						if(grd[i] == 1'b0) //1 space is not filled yet so not tie
							tie = 1'b0;
					end
					if (tie == 1'b1) begin
						win = 4'he;   //e for tie
					end
				end
			end
			if (ld_o && !win) begin
				integer i;
				reg mult_input;
				mult_input = 0;
				for (i=0; i<9; i=i+1) begin
					if(!mult_input) begin
						if (data_in[i] && mult_input == 0) begin //input o is 1
							if (grd[i] == 1'b0 && o[i] == 1'b0 && x[i] == 1'b0) begin //grid at input o is empty and not multiple input
								grd[i] = 1'b1;  //set grid val to filled
								o[i] = 1'b1;  //set o val to 1
								mult_input = 1;
							end
						end
					end
				end
				if(o[0] && o[3] && o[6]) //col 1
					win = 4'h2;
				else if(o[1] && o[4] && o[7]) //col 2
					win = 4'h2;
				else if(o[2] && o[5] && o[8]) //col 3
					win = 4'h2;
				else if(o[0] && o[1] && o[2]) //row 1
					win = 4'h2;
				else if(o[3] && o[4] && o[5]) //row 2
					win = 4'h2;
				else if(o[6] && o[7] && o[8]) //row 3
					win = 4'h2;
				else if(o[0] && o[4] && o[8]) //diag (\)
					win = 4'h2;
				else if(o[2] && o[4] && o[6]) //diag (/)
					win = 4'h2;
				else
					win = 4'h0;
				LED_2 = o;
				if (win == 4'h2) begin //check win
					o_score = o_score + 4'h1;
				end
				else begin
					reg tie;
					tie = 1'b1;
					for (i=0; i<9; i=i+1) begin
						if(grd[i] == 1'b0) //1 space is not filled yet so not tie
							tie = 1'b0;
					end
					if (tie == 1'b1) begin
						win = 4'he;   //e for tie
					end
				end
			end				
		end
	end	
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;

    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
