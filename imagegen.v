`timescale 1 ns / 1 ps

`define IMG_OFFSET   16384 //0x00010000
`define KNN_SOURCE   "image_out.bin"
`define COMPARE_SOURCE   "compare_out.bin"
`define COMPARE_SOURCE_V   "compare_out_v.bin"
`define IMG_SIZE 262144
module testbench ();
	integer knn_in, knn_out, knn_txt,c_in,c_out,ver_in,ver_out;
	reg [7:0] bmp_data [0:2000000];
	integer i, cc,dd,vv;     
	
	reg [7:0] knn_data [786432-1: 0];
	reg [7:0] c_data [786432-1: 0];
	reg [7:0] ver_data[786432-1:0];
	initial begin
		// File handlers
		knn_in = $fopen(`KNN_SOURCE, "rb");
		knn_txt = $fopen(`KNN_TXT, "w");
		knn_out = $fopen(`KNN_OUTPUT, "wb");
		
		c_in = $fopen(`COMPARE_SOURCE, "rb");
		c_out = $fopen("compare.bmp", "wb");
		ver_in = $fopen(`COMPARE_SOURCE_V, "rb");
		ver_out = $fopen("compare_v.bmp", "wb");
		
		cc = $fread(knn_data, knn_in);
		dd = $fread(c_data, c_in);
		vv = $fread(ver_data, ver_in);
		for(i = `IMG_ID*`IMG_SIZE; i < (`IMG_ID+1)*`IMG_SIZE; i = i + 1) begin
			$fwrite(knn_txt, "%0d\n", knn_data[i]);
//			$display("%d %d",i,knn_data[i]);
		end  
		$fclose(knn_in);
		$fclose(c_in);
		$fclose(ver_in);
		$fclose(knn_txt);

		//initialize bmp header for a 32*32 image
		for(i = 0; i < 54; i = i + 1) begin
			bmp_data[i] = 0;
		end
		bmp_data[0] = 66; //'B'
		bmp_data[1] = 77; //'M'
		bmp_data[2] = 54;
		bmp_data[4] = 12;

//		{bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]} = 3126; //file size
		{bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]} = 54; //data offset
		{bmp_data[17], bmp_data[16], bmp_data[15], bmp_data[14]} = 40; //info header size
		{bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]} = 512; //width
		{bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]} = 512; //height
		{bmp_data[27], bmp_data[26]} = 1; //number of planes
		{bmp_data[29], bmp_data[28]} = 24; //bits per pixel
		bmp_data[36] = 12;

		bmp_data[38] = 18;
		bmp_data[39] = 11;
		bmp_data[42] = 18;
		bmp_data[43] = 11;
	//	{bmp_data[41], bmp_data[40], bmp_data[39], bmp_data[38]} = 3780; //xresolution
	//	{bmp_data[45], bmp_data[44], bmp_data[43], bmp_data[42]} = 3780; //yresolution
		for(i = 0; i < 54; i = i + 1) begin
			$fwrite(knn_out, "%c", bmp_data[i]);
			$fwrite(c_out, "%c", bmp_data[i]);
			$fwrite(ver_out, "%c", bmp_data[i]);
		end  
		
		for(i = `IMG_ID*`IMG_SIZE; i < (`IMG_ID+1)*`IMG_SIZE; i = i + 1) begin
			$fwrite(knn_out, "%c", knn_data[i]);
			$fwrite(knn_out, "%c", knn_data[i]);
			$fwrite(knn_out, "%c", knn_data[i]);
			
			$fwrite(c_out, "%c", c_data[i]);
			$fwrite(c_out, "%c", c_data[i]);
			$fwrite(c_out, "%c", c_data[i]);
			
			$fwrite(ver_out, "%c", ver_data[i]);
			$fwrite(ver_out, "%c", ver_data[i]);
			$fwrite(ver_out, "%c", ver_data[i]);
		end  
		$fclose(knn_out);
		$fclose(c_out);
		$fclose(ver_out);
		$finish;
	end
	
endmodule
