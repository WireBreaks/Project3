module PE 
	#(parameter WIDTH = 32)(
	input logic clk, reset_n, load, clear, carry_enable,
	input logic [WIDTH-1:0] data_in, weight, result_carry,
	output logic [WIDTH-1:0] result, weight_carry, data_in_carry);
	
	logic [WIDTH-1:0] mult_result, accumulator;
  
	DSP_MULTIPLIER #(WIDTH, WIDTH*2) Mult (
			.dataa(data_in),
			.datab(weight),
			.result(mult_result));

	always_ff @(posedge clk or negedge reset_n) begin 
		if (!reset_n) 					accumulator <= '0;
		else if (!load && !clear) 		accumulator <= accumulator + mult_result;
		else if (load && !clear) 		accumulator <= accumulator;
		else if (clear)  			  	accumulator <= '0;
	end
	
	assign result = (carry_enable) ? result_carry : accumulator;
	assign weight_carry = weight;
	assign data_in_carry = data_in;

endmodule : PE
