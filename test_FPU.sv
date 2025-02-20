//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2025 12:02:34 PM
// Design Name: 
// Module Name: test_FPU
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

module test_FPU;
timeunit 1ns;
timeprecision 1ns;

// Decimal fraction will be represented as in Q(m,n) fixed format, where m is magnitude and n is fractional bits
    parameter Q = 16;

// Scaling factor represents the amount by which integral part needs to be shifted in power of 2 
   integer scale = 1 << Q;

// Input decimal fraction to convert
    real decimal_fraction1, decimal_fraction2;

//  Fixed Point Number
    logic [31:0] scaled_fraction1, scaled_fraction2;
    
//  Floating Point Representation
    logic [31:0] ieee_7541 ,ieee_7542;
    
// Intermediate variables
    logic op, exception;
    logic [31:0] result;

//  Module Instantiation
    fixed_float #(Q)convert1 (.fixed_point(scaled_fraction1), .ieee_float(ieee_7541));
    fixed_float #(Q)convert2 (.fixed_point(scaled_fraction2), .ieee_float(ieee_7542));
    Adder_Subtractor adder (ieee_7541, ieee_7542, op, exception, result);
    
    initial begin
    
   // decimal_fraction1 = 100.0;
      
   // decimal_fraction2 =  0.25;
      
 //   decimal_fraction1 =  3.9;
  //  decimal_fraction2 =  2.3; 
 
   decimal_fraction1 =  0.25;
   decimal_fraction2 =  0.05;
      
 //  decimal_fraction1 =  2.9;
 //  decimal_fraction2 =  2.5;
    
    
   // decimal_fraction1 =  1.70;
  //  decimal_fraction2 =  1.65;
      
  //  decimal_fraction1 =  1.76;
  //  decimal_fraction2 =  1.25;
    
 //  decimal_fraction1 =  13.76;
  // decimal_fraction2 =  4.25;
        op = 1'b0;
        
        convert_to_fixed(decimal_fraction1, scale, scaled_fraction1);
        convert_to_fixed(decimal_fraction2, scale, scaled_fraction2);
        #1;
        
        $display("Fixed point for %.2f is: %0d, while IEEE representation is: %b", decimal_fraction1,  scaled_fraction1, ieee_7541);
        $display("Fixed point for %.2f is: %0d, while IEEE representation is: %b", decimal_fraction2,  scaled_fraction2, ieee_7542);
        
    end 

    task convert_to_fixed(input real input_fraction, input integer scale, output logic[31:0] scaled_fr);    
    
        // Move the decimal position to the right by scaling the integral part
        scaled_fr = input_fraction * scale;  
        
    endtask
endmodule
