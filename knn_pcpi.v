`define IMG_OFFSET   16384
`define IMG_SIZE 262144
`define THERHOLD 175
module abs (input[31:0] A,
			input[31:0] B, 
			output[31:0] ans);
	wire[31:0] a = (A[31])?(~A[31:0]+1):A;
	wire[31:0] b = (B[31])?(~B[31:0]+1):B;
	assign ans = a+b;

endmodule
module SOBEL(
input             clk, resetn,
	input             pcpi_valid,
	input      [31:0] pcpi_insn,
	input      [31:0] pcpi_rs1,
	input      [31:0] pcpi_rs2,
	output            pcpi_wr,
	output     [31:0] pcpi_rd,
	output            pcpi_wait,
	output            pcpi_ready,
	//memory interface
	input      [31:0] mem_rdata,
	input             mem_ready,
	output reg            mem_valid,
	output            mem_write,
	output     [31:0] mem_addr,
	output     [31:0] mem_wdata
);


	wire pcpi_insn_valid = pcpi_valid && pcpi_insn[6:0] == 7'b0101011 && pcpi_insn[31:25] == 7'b0000001;


	
	parameter IDLE = 4'b0000, READ_DATA1=4'b0001,READ_DATA2=4'b0010,READ_DATA3=4'b0011,CALC=4'b0100,DONE=4'b0101;
	reg[3:0] state,next_state;
    reg signed[31:0] data[0:8];
	reg signed[31:0] next_data[0:8];
	reg signed[31:0] answer/*,next_answer*/;
	wire [31:0]next_answer;
	reg signed[31:0] edge_detect,next_edge_detect;
	reg signed[31:0] edge_detect_v,next_edge_detect_v;
	reg[31:0] addr,next_addr;
	reg[31:0] counter,next_counter;
	reg[8:0] row,next_row,col,next_col;
	reg out_0;
	reg[31:0] test,next_test;
	parameter signed X1 = 8'hff, X2 = 8'h00, X3 = 8'h01;
	parameter signed X4 = 8'hfe, X5 = 8'h00, X6 = 8'h02;
	parameter signed X7 = 8'hff, X8 = 8'h00, X9 = 8'h01;

	parameter signed Y1 = 8'hff, Y2 = 8'hfe, Y3 = 8'hff;
	parameter signed Y4 = 8'h00, Y5 = 8'h00, Y6 = 8'h00;
	parameter signed Y7 = 8'h01, Y8 = 8'h02, Y9 = 8'h01;	
	
	parameter signed Z1 = 8'hff, Z2 = 8'hff, Z3 = 8'hff;
	parameter signed Z4 = 8'hff, Z5 = 8'h08, Z6 = 8'hff;
	parameter signed Z7 = 8'hff, Z8 = 8'hff, Z9 = 8'hff;
		//TODO: PCPI interface. Modify these values to fit your needs
	assign pcpi_wr = 0;
	assign pcpi_wait = (state == DONE)?0:1;
	assign pcpi_ready = (state == DONE)?pcpi_insn_valid:0;
	assign pcpi_rd = (state == DONE)?answer:0;
	
	//TODO: Memory interface. Modify these values to fit your needs
	assign mem_write = 0;
	assign mem_addr = (mem_valid)?(next_addr+`IMG_OFFSET+next_test*`IMG_SIZE)<<2:0;
	assign mem_wdata = 0;
	integer i;
	integer image_out;
	integer edge_detect_out;
	integer edge_detect_v_out;
	/*initial begin
		image_out = $fopen("image_out.bin", "wb");
		edge_detect_out = $fopen("compare_out.bin", "wb");
	end*/
	/*sqrt #(32) s(clk,
				data[0]*X1+data[1]*X2+data[2]*X3+data[3]*X4+data[4]*X5+data[5]*X6+data[6]*X7+data[7]*X8+data[8]*X9,
				data[0]*Y1+data[1]*Y2+data[2]*Y3+data[3]*Y4+data[4]*Y5+data[5]*Y6+data[6]*Y7+data[7]*Y8+data[8]*Y9,
				next_answer);*/
		abs a(next_edge_detect,
			next_edge_detect_v,
			next_answer);
	always@(posedge clk or negedge resetn)begin
		if(!resetn)begin
			state <= IDLE;
			addr <= 0;
			answer <= 0;
			edge_detect <= 0;
			edge_detect_v <= 0;
			row <= 0;
			col <= 0;
			counter <=0;
			test<=0;
			for(i=0;i<9;i=i+1)begin
				data[i] <= 8'hff;
			end
		end
		else begin
			state <= next_state;
			addr <= next_addr;
			if(!out_0)
				answer <= (next_answer>`THERHOLD)?next_answer:32'd0/*next_answer*/;
			else 
				answer <= 0;
			row <= next_row;
			col <= next_col;
			test <= next_test;
			counter <= next_counter;
			edge_detect <= /*next_edge_detect*/(next_edge_detect>50)?255:0;
			edge_detect_v <= /*next_edge_detect*/(next_edge_detect_v>50)?255:0;
			for(i=0;i<9;i=i+1)begin
				data[i] <= next_data[i];
			end
		end
	end
	
	always@(*)begin
		for(i=0;i<9;i=i+1)begin
			next_data[i] = data[i];
		end
		next_addr = 0;
		//next_answer = answer;
		next_state = state;
		mem_valid = 0;
		next_row = row;
		next_col = col;
		next_counter = counter;
		out_0 = 0;
		next_edge_detect = edge_detect;
		next_edge_detect_v = edge_detect_v;
		next_test = test;
		case(state)
			IDLE:begin
			//$display("IDLE");
				if(pcpi_insn_valid)begin
					next_state = READ_DATA1;
					mem_valid = 1;
					next_test = pcpi_rs1;
					if(pcpi_rs2[8:0] == 0||pcpi_rs2[17:9] == 0)begin
						//next_answer = 0;
						out_0 = 1;
						next_state = DONE;
						next_edge_detect = 0;
						next_edge_detect_v = 0;
					end
					else if(pcpi_rs2[8:0] == 1)begin
						next_row = pcpi_rs2[17:9];
						next_col = pcpi_rs2[8:0] - 1;
						next_addr = {pcpi_rs2[17:9]-9'd1,pcpi_rs2[8:0]-9'd1};
					end
					else begin
						next_row = pcpi_rs2[17:9];
						next_col = pcpi_rs2[8:0] + 1;
						next_addr = {pcpi_rs2[17:9]-9'd1,pcpi_rs2[8:0]+9'd1};
					end
					
				end
			end
			READ_DATA1:begin
			//shift data
				next_data[0] = data[1];
				next_data[1] = data[2];
				next_data[3] = data[4];
				next_data[4] = data[5];
				next_data[6] = data[7];
				next_data[7] = data[8];
			//get the first data
				next_data[2] = mem_rdata;
				mem_valid = 1;
				next_row = row + 9'd1;
				next_addr = {14'd0, row,col};
				next_state = READ_DATA2;
			end
			READ_DATA2:begin
				next_data[5] = mem_rdata;
				mem_valid = 1;
				next_row = row + 9'd1;
				next_addr = {14'd0, row,col};
				next_state = READ_DATA3;
			end
			READ_DATA3:begin
				next_data[8] = mem_rdata;
				mem_valid = 1;
				if(col <=1)begin
					next_row = row - 9'd2;
					next_col = col+1;
					next_addr = {14'd0, row,col};
					next_state = READ_DATA1;
				end
				else begin
					next_state = CALC;
				end
			end
			CALC:begin
				next_edge_detect = data[0]*X1+data[2]+data[3]*X4+data[5]*X6+data[6]*X7+data[8]*X9;/*(~((data[0]+data[1]+data[2]+data[3]+data[5]+data[6]+data[7]+data[8])>>1))+1+(data[4]<<2);*/
				next_edge_detect_v = data[0]*Y1+data[1]*Y2+data[2]*Y3+data[6]*Y7+data[7]*Y8+data[8]*Y9;
				next_state = DONE;
			end
			DONE:begin
			//$display("DONE");
				next_counter = counter + 1;
				if(counter == 0) begin
					image_out = $fopen("image_out.bin", "wb");
					edge_detect_out = $fopen("compare_out.bin", "wb");
					edge_detect_v_out = $fopen("compare_out_v.bin", "wb");
					$fwrite(image_out, "%c", answer);
					$fwrite(edge_detect_out, "%c", edge_detect);
					$fwrite(edge_detect_v_out, "%c", edge_detect_v);
				end
				else if(counter < (`IMG_SIZE<<1)-1)begin
					$fwrite(image_out, "%c", answer);
					$fwrite(edge_detect_out, "%c", edge_detect);
					$fwrite(edge_detect_v_out, "%c", edge_detect_v);
				end
				else begin
					next_counter = 0;
					$fwrite(image_out, "%c", answer);
					$fwrite(edge_detect_out, "%c", edge_detect);
					$fwrite(edge_detect_v_out, "%c", edge_detect_v);
					$fclose(image_out);
					$fclose(edge_detect_out);
					$fclose(edge_detect_v_out);
				end 
				
				next_state = IDLE;
			end
			default:begin
				next_state = IDLE;
			end
		endcase
	
	end
	
endmodule

