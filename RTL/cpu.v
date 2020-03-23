//Module: CPU
//Function: CPU is the top design of the processor
//Inputs:
//	clk: main clock
//	arst_n: reset 
// 	enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// 	ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// 	ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory
//Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[31:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[31:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [31:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[31:0]  rdata_ext_2

   );

wire              zero_flag;
wire [      31:0] branch_pc,branch_pc_MEM,updated_pc,updated_pc_ID,updated_pc_EX,current_pc,jump_pc,jump_pc_MEM,
                  instruction,instruction_ID,instruction_EX;
wire [       1:0] alu_op,alu_op_EX;
wire [       3:0] alu_control;
wire              reg_dst,branch,branch_EX,branch_MEM,mem_read,mem_read_EX,mem_read_MEM,mem_2_reg,mem_2_reg_EX,mem_2_reg_MEM,mem_2_reg_WB,
                  mem_write,mem_write_EX,mem_write_MEM,alu_src, alu_src_EX,reg_write,reg_write_EX,reg_write_MEM,reg_write_WB, jump,jump_EX,jump_MEM;
wire [       4:0] regfile_waddr,regfile_waddr_EX,regfile_waddr_MEM,regfile_waddr_WB;
wire [      31:0] regfile_wdata, dram_data,dram_data_WB,alu_out,alu_out_MEM,alu_out_WB,
                  regfile_data_1,regfile_data_1_EX,regfile_data_2,regfile_data_2_EX,regfile_data_2_MEM,
                  alu_operand_2;
/*
wire [	    15:0] instruction1;
wire [       5:0] instruction2, instruction3;
wire [       4:0] instruction4, instruction5, instruction6, instruction7;	
*/

wire signed [31:0] immediate_extended;

assign immediate_extended = $signed(instruction_EX[15:0]);
/*
assign instruction1 = $signed(instruction[15:0]);
assign instruction2 = $signed(instruction[31:26]);
assign instruction3 = $signed(instruction[5:0]);
assign instruction4 = $signed(instruction[15:11]);
assign instruction5 = $signed(instruction[20:16]);
assign instruction6 = $signed(instruction[25:21]);
assign instruction7 = $signed(instruction[10:6]);

assign immediate_extended = $signed(instruction1_EX);
*/

pc #(
   .DATA_W(32)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc_MEM ),
   .jump_pc   (jump_pc_MEM   ),
   .zero_flag (zero_flag ),
   .branch    (branch_MEM    ),
   .jump      (jump_MEM      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

//pipeline updated_pc
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) updated_pc_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (updated_pc),
.dout (updated_pc_ID)
);

reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) updated_pc_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (updated_pc_ID),
.dout (updated_pc_EX)
);
//

sram #(
   .ADDR_W(9 ),
   .DATA_W(32)
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

//pipeline instruction
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0) ) updated_instruction_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction),
.dout (instruction_ID)
);

reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) updated_instruction_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction_ID),
.dout (instruction_EX)
);

/////////////////////////
/*
// 1-EX [15:0]
reg_arstn_en#(.DATA_W(16), .PRESET_VAL('b0)) updated_instruction1_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction1),
.dout (instruction1_ID)
);

reg_arstn_en#(.DATA_W(16), .PRESET_VAL('b0)) updated_instruction1_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction1_ID),
.dout (instruction1_EX)
);
// 2-ID [31:26]
reg_arstn_en#(.DATA_W(6), .PRESET_VAL('b0)) updated_instruction2_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction2),
.dout (instruction2_ID)
);
//3-EX [5:0]
reg_arstn_en#(.DATA_W(6), .PRESET_VAL('b0)) updated_instruction3_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction3),
.dout (instruction3_ID)
);

reg_arstn_en#(.DATA_W(6), .PRESET_VAL('b0)) updated_instruction3_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction3_ID),
.dout (instruction3_EX)
);
//4-ID [15:11]
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) updated_instruction4_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction4),
.dout (instruction4_ID)
);
//5-ID [20:16]
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) updated_instruction5_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction5),
.dout (instruction5_ID)
);
//6-ID [25:21]
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) updated_instruction6_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction6),
.dout (instruction6_ID)
);
//7-EX [10:6]
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) updated_instruction7_pipe_IF_ID(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction7),
.dout (instruction7_ID)
);
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) updated_instruction7_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (instruction7_ID),
.dout (instruction7_EX)
);
*/
///////////////////////////

//

control_unit control_unit(
   .opcode   (instruction_ID[31:26]),
   //.opcode   (instruction2_ID),
   .reg_dst  (reg_dst           ),
   .branch   (branch            ),
   .mem_read (mem_read          ),
   .mem_2_reg(mem_2_reg         ),
   .alu_op   (alu_op            ),
   .mem_write(mem_write         ),
   .alu_src  (alu_src           ),
   .reg_write(reg_write         ),
   .jump     (jump              ) 
);

//pipeline branch
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) branch_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (branch),
.dout (branch_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) branch_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (branch_EX),
.dout (branch_MEM )
);
//


//pipeline mem_read
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_read_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_read),
.dout (mem_read_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_read_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_read_EX),
.dout (mem_read_MEM )
);
//


//pipeline mem2reg(the register writeback data from ALU or memory)
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_2_reg_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_2_reg),
.dout (mem_2_reg_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_2_reg_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_2_reg_EX),
.dout (mem_2_reg_MEM )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_2_reg_MEM_WB(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_2_reg_MEM),
.dout (mem_2_reg_WB )
);
//

//pipeline alu_op(what type of alu operation)
reg_arstn_en#(.DATA_W(2), .PRESET_VAL('b0)) alu_op_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (alu_op),
.dout (alu_op_EX )
);
//

//pipeline memwrite
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_write_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_write),
.dout (mem_write_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) mem_write_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (mem_write_EX),
.dout (mem_write_MEM )
);

//pipeline alu_src(determine which is the second operand)
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) alu_src_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (alu_src),
.dout (alu_src_EX )
);

//pipeline reg_write
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) reg_write_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (reg_write),
.dout (reg_write_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) reg_write_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (reg_write_EX),
.dout (reg_write_MEM )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) reg_write_MEM_WB(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (reg_write_MEM),
.dout (reg_write_WB )
);
//

//pipeline jump
reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) jump_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (jump),
.dout (jump_EX )
);

reg_arstn_en#(.DATA_W(1), .PRESET_VAL('b0)) jump_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (jump_EX),
.dout (jump_MEM )
);
//

mux_2 #(
   .DATA_W(5)
) regfile_dest_mux (
   .input_a (instruction_ID[15:11]),
   .input_b (instruction_ID[20:16]),
   //.input_a (instruction4_ID),
   //.input_b (instruction5_ID),
   .select_a(reg_dst          ),
   .mux_out (regfile_waddr     )
);

//pipeline register write address
reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) regfile_waddr_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_waddr),
.dout (regfile_waddr_EX )
);

reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) regfile_waddr_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_waddr_EX),
.dout (regfile_waddr_MEM )
);

reg_arstn_en#(.DATA_W(5), .PRESET_VAL('b0)) regfile_waddr_MEM_WB(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_waddr_MEM),
.dout (regfile_waddr_WB )
);
//

register_file #(
   .DATA_W(32)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write_WB         ),
   .raddr_1  (instruction_ID[25:21]),
   .raddr_2  (instruction_ID[20:16]),
   //.raddr_1  (instruction6_ID),
   //.raddr_2  (instruction5_ID),
   .waddr    (regfile_waddr_WB  ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_data_1    ),
   .rdata_2  (regfile_data_2    )
);

//pipeline register outputs
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) regfile_data_1_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_data_1),
.dout (regfile_data_1_EX )
);

reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) regfile_data_2_pipe_ID_EX(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_data_2),
.dout (regfile_data_2_EX )
);

reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) regfile_data_2_pipe_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (regfile_data_2_EX),
.dout (regfile_data_2_MEM )
);
//

alu_control alu_ctrl(
   .function_field (instruction_EX[5:0]),
   //.function_field (instruction3_EX),
   .alu_op         (alu_op_EX          ),
   .alu_control    (alu_control     )
);

mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
   .input_a (immediate_extended),
   .input_b (regfile_data_2_EX    ),
   .select_a(alu_src_EX           ),
   .mux_out (alu_operand_2     )
);


alu#(
   .DATA_W(32)
) alu(
   .alu_in_0 (regfile_data_1_EX),
   .alu_in_1 (alu_operand_2 ),
   .alu_ctrl (alu_control   ),
   .alu_out  (alu_out       ),
   .shft_amnt(instruction_EX[10:6]),
   //.shft_amnt(instruction7_EX),
   .zero_flag(zero_flag     ),
   .overflow (              )
);

//pipeline alu_out
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) alu_out_pipe_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (alu_out),
.dout (alu_out_MEM )
);

reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) alu_out_pipe_MEM_WB(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (alu_out_MEM),
.dout (alu_out_WB )
);
//

sram #(
   .ADDR_W(10),
   .DATA_W(32)
) data_memory(
   .clk      (clk           ),
   .addr     (alu_out_MEM   ),
   .wen      (mem_write_MEM ),
   .ren      (mem_read_MEM  ),
   .wdata    (regfile_data_2_MEM),
   .rdata    (dram_data     ),   
   .addr_ext (addr_ext_2    ),
   .wen_ext  (wen_ext_2     ),
   .ren_ext  (ren_ext_2     ),
   .wdata_ext(wdata_ext_2   ),
   .rdata_ext(rdata_ext_2   )
);

//pipeline data memory output
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) rdata_pipe_MEM_WB(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (dram_data),
.dout (dram_data_WB )
);
//


mux_2 #(
   .DATA_W(32)
) regfile_data_mux (
   .input_a  (dram_data_WB    ),
   .input_b  (alu_out_WB      ),
   .select_a (mem_2_reg_WB     ),
   .mux_out  (regfile_wdata)
);


branch_unit#(
   .DATA_W(32)
)branch_unit(
   .updated_pc   (updated_pc_EX        ),
   .instruction  (instruction_EX       ),
   .branch_offset(immediate_extended),
   .branch_pc    (branch_pc         ),
   .jump_pc      (jump_pc         )
);

//pipeline branch_pc
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) branch_pc_pipe_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (branch_pc),
.dout (branch_pc_MEM )
);

//pipeline jump_pc
reg_arstn_en#(.DATA_W(32), .PRESET_VAL('b0)) jump_pc_pipe_EX_MEM(
.clk (clk),
.arst_n (arst_n),
.en (enable),
.din (jump_pc),
.dout (jump_pc_MEM )
);

endmodule


