/* 
* Systolic Array Module
* Created By: Jordi Marcial Cruz
* Updated: February 25th, 2025
*
* Description:
* This module implements a Systolic Array of Processing Elements (PEs). 
* The array performs matrix multiplication in a parallel and pipelined manner, allowing for efficient computation. 
* The systolic array processes data inputs in a wave-like manner across the array of PEs, enabling effective data reuse and high throughput.
*
*/
`timescale 1 ps / 1 ps

module Systolic_Array #(parameter WIDTH = 8, SIZE = 32) (
  	input logic clk,
  	input logic reset_n, 
    input logic sa_load,            // Systolic Array load enable
    input logic sa_clear,           // Systolic Array clear enable
  	input logic sa_carry_en [SIZE-1:0],
  	input logic [WIDTH-1:0] ib_data_out [SIZE-1:0],  // Input Buffer data output
  	input logic [WIDTH-1:0] wb_data_out [SIZE-1:0],  // Weight Buffer data output
	 
  	output logic [WIDTH-1:0] sa_data_out [SIZE-1:0]  // Systolic Array data output
	);
  
    logic [WIDTH-1:0] weight_down [SIZE:0] [SIZE-1:0];
    logic [WIDTH-1:0] data_in_across [SIZE-1:0] [SIZE:0];
    logic [WIDTH-1:0] result_across [SIZE-1:0] [SIZE:0];

    genvar i, j;
    generate
        for (i = 0; i < SIZE; i++) begin : PE_ROWS
            for (j = 0; j < SIZE; j++) begin : PE_COLUMNS
                PE #(WIDTH) PE_inst
                    (.clk             (clk),           // Clock signal
                     .reset_n         (reset_n),         // Asynchronous reset signal (active low)
                     .load            (sa_load),         // Load signal for PE accumulator
                     .clear           (sa_clear),        // Clear signal to reset PE
                     .carry_enable    (sa_carry_en[j]),  // Carry enable signal for chaining PEs
                     .data_in         (data_in_across[i][j]), // Data input to the PE
                     .weight          (weight_down[i][j]),   // Weight input to the PE
                     .result_carry    (result_across[i][j]), // Carry result output from the PE
                     .result          (result_across[i][j+1]), // Result output from the PE to next column
                     .weight_carry    (weight_down[i+1][j]),  // Weight carry to the next row PE
                     .data_in_carry   (data_in_across[i][j+1])); // Data input carry to the next column PE
            end

            // Assign initial values for the first row and column of the array
            always_comb begin
                weight_down[0][i] = wb_data_out[i];      // Initial weight input for row i
                data_in_across[i][0] = ib_data_out[i];   // Initial data input for column i
                sa_data_out[i] = result_across[i][SIZE]; // Output result for row i after processing
            end
        end
    endgenerate

endmodule : Systolic_Array
