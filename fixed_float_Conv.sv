//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2025 03:07:10 PM
// Design Name: 
// Module Name: fixed_float
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

// The parameter Q indicates the fractional bits in the fixed point notation
module fixed_float #(parameter Q = 16)(
    input [31:0] fixed_point,
    output [31:0] ieee_float
    );
    timeunit 1ns;
    timeprecision 1ns;
    
    // Intermediate calculations
    logic sign;
    logic [7:0]  exponent;
    logic [22:0] mantissa;
    logic [31:0] signed_fixed_point, shifted_val;
    logic[31:0] max_shift = 32;
    logic[31:0] shift_count = 0;
    
    // Sign bit computation 
    always_comb begin 
        if (fixed_point[31] == 1'b1) begin // For negative numbers
            // convert back from 2's complement to binary
            signed_fixed_point = ~fixed_point + 1;
            sign = 1'b1;         
        end
        else begin // For positive numbers
            signed_fixed_point = fixed_point;
            sign = 1'b0;
        end
    end
     
    // Represent the fixed point number in 1.xx * 2^exp form
    // The implicit '1' is ignored when 1 is shifted in the MSB
    always_comb begin
        shifted_val = signed_fixed_point;   
        for (integer i = 0; i < max_shift; i++) begin
            if (shifted_val[31] != 1'b1) begin
                shifted_val = shifted_val << 1;
                shift_count++;
            end
        end
    end
    
    // Compute exponent and mantissa if non-zero
    always_comb begin
        if (shifted_val != 0) begin
            exponent = (max_shift -1 - shift_count) + (8'd127 - Q);
            mantissa = shifted_val[30:8];
        end
        else begin
            exponent = 8'b0;
            mantissa = 23'b0;
        end
    end 
    
    // Concatinating Sign ,Exp & Mantissa fields
    assign ieee_float = {sign, exponent, mantissa};
   
endmodule
