module mux_3 
  #(
   parameter integer DATA_W = 32
   )(
      input  wire [DATA_W-1:0] input_0,
      input  wire [DATA_W-1:0] input_1,
      input  wire [DATA_W-1:0] input_2,

      input  wire[1:0]        select,
      output reg  [DATA_W-1:0] mux_out
   );

   always@(*)begin
      case(select)
         2'b00:begin
            mux_out = input_0;
         end
 
         2'b01:begin
            mux_out = input_1;
         end
         
         2'b10:begin
            mux_out = input_2;
         end
         default:begin
            mux_out = 0;
         end
      endcase
   end
endmodule

