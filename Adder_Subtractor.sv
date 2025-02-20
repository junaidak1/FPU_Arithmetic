`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 02:29:34 PM
// Design Name: 
// Module Name: Adder_Subtractor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Adder_Subtractor(
    input [31:0] float_A, float_B,
    input op,
    output exception,
    output [31:0] result
    );
    timeunit 1ns;
    timeprecision 1ns;
    
    // Intermdediate variables for computation
    logic [31:0] large_exp_num;
    logic [31:0] small_exp_num;
    logic [31:0] tmp_resultA, tmp_resultS;
    logic [7:0] shift_count = 0;
    logic coutA, coutS = 0;
    logic [22:0] subtrahend;
    logic exception_A, exception_S;
    logic identify_bit = 0;
    logic [4:0] bit_position = 0;;
    
    // Aligining the radix point for both fractions
    always_comb begin
     // Identify the number with the smaller exponent    
            if (float_A[30:0] >= float_B[30:0]) begin
                large_exp_num = float_A;
                small_exp_num = float_B;
            end
            else begin
                large_exp_num = float_B;
                small_exp_num = float_A;
            end
                   
            // Find the amount of shifts to be done 
            shift_count = large_exp_num[30:23] - small_exp_num[30:23];
            
            // Right shift the mantissa of smaller number by shift_count 
            // Add 1 to exponent on each shift
            for (integer i = 0; i < shift_count; i++) begin                
                small_exp_num[22:0] = small_exp_num[22:0] >> 1;
                small_exp_num[30:23] =  small_exp_num[30:23] + 1;

                // Add the implicit 1 in the shift    
                if (i == 0)
                    small_exp_num[22] = 1'b1;
            end   
    end
   
   
    // Floating point addition, op = 0
    always_comb begin
        if (op == 1'b0) begin
            
            // Add mantissa's of two numbers together and construct the number
            {coutA, tmp_resultA[22:0]} = large_exp_num[22:0] + small_exp_num[22:0];
            tmp_resultA[30:23] = large_exp_num[30:23];
            tmp_resultA[31] = large_exp_num[31]; 
           
            if (coutA || !shift_count) begin
                tmp_resultA[22:0]  =  tmp_resultA[22:0] >> 1;
                tmp_resultA[30:23] =  tmp_resultA[30:23] + 1;
                
                // If exp of two numbers match
                if (shift_count == 0 && coutA)
                    tmp_resultA[22] = 1'b1;
            end
            // Check for overflow
            exception_A = (tmp_resultA[30:23] == 8'd255 || tmp_resultA[30:23] == 8'd0) ? 1'b1 : 1'b0;
      
        end
    end
    
    // Floating point subtraction, op = 1
    always_comb begin
        if (op == 1'b1) begin
            // Convert the subtrahend mantissa to 2's complement form
            subtrahend[22:0] = ~small_exp_num[22:0] + 1;
            
            // Simply add the mantissa's of two numbers together
            {coutS, tmp_resultS[22:0]} = large_exp_num[22:0] +  subtrahend[22:0];
            
            // Exponent Calculation
            tmp_resultS[30:23] = large_exp_num[30:23];
            
            // Sign bit calculation
            tmp_resultS[31] = float_A[30:0] < float_B[30:0] ? 1 : 0;
            
            // Normalize the result of subtraction, shift the mantissa left if non-zero
            if (large_exp_num == small_exp_num) begin
                  tmp_resultS[30:23] =  tmp_resultS[30:23] - tmp_resultS[30:23];
            end
            else if (!coutS || shift_count == 0) begin
                   for (int i = 0; i < 23; i++) begin                  
                        if (identify_bit != 1) begin
                            if (tmp_resultS[22-i] == 1'b1) begin
                                identify_bit = 1;
                                bit_position++;  
                            end
                        else
                             bit_position++;  
                        end        
                   end
                   
                   for (int i = 0; i < bit_position; i++) begin
                        tmp_resultS[22:0]  =  tmp_resultS[22:0] << 1;
                        tmp_resultS[30:23] =  tmp_resultS[30:23] - 1;
                   end   
            end
       
            // Check for exception
            exception_S = (tmp_resultS[30:23] == 8'd255 || tmp_resultS[30:23] == 8'd0) ? 1'b1 : 1'b0;
        end
    end
    
    assign exception = (op == 1'b1) ? exception_S: exception_A;
    
    // Assembling final result
    assign result = (exception == 1'b0) ? ((op == 1'b1) ? tmp_resultS : tmp_resultA)  : 32'b0;
    
endmodule
