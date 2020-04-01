module mux_3 
  #(
   parameter integer DATA_W = 16
   )(
      input  wire [DATA_W-1:0] input_0,
      input  wire [DATA_W-1:0] input_1,
	  input  wire [DATA_W-1:0] input_2,

      input  wire[1:0]        select,
      output reg  [DATA_W-1:0] mux_out
   );

   always@(*)begin
      case(select)
         2'b0:begin
            mux_out = input_0;
         end
 
         2'b1:begin
            mux_out = input_1;
         end
         
         2'b2:begin
		    mux_out = input_2;
         end
      endcase
   end
endmodule

