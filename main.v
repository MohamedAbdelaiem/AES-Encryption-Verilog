 module main(input[3:0]SW,input [1:0] KEY,output wire[6:0] HEX0,output wire[6:0] HEX1,output wire[6:0] HEX2,output wire [1:0] LEDR); 

////////////////////////////////////////////////////// new main  ////////////////////////////////////////////////////////////////
/*
SW[0] = 128 bit
SW[1] = 192 bit
SW[2] = 256 bit
SW[3] = reset
*/

localparam nk_128 =4 ;
localparam nr_128 =10 ;
localparam nk_192 =6 ;
localparam nr_192 =12 ;
localparam nk_256 =8 ;
localparam nr_256 =14 ;
integer counter=-1;

wire [127:0]out_128;
wire [127:0]out_192;
wire [127:0]out_256;
wire [127:0]out_desipher_128;
wire [127:0]out_desipher_192;
wire [127:0]out_desipher_256;
wire [11:0] out_encoder;

//////////////////////////////////////main output///////////////////////////////////////////////////
wire[127:0]  out_main; 
wire [127:0] out_main_128;
wire [127:0] out_main_192;
wire [127:0] out_main_256;
//////////////////////////////////////states&&keys///////////////////////////////////////////////////
wire [127:0]key_128;
wire [191:0]key_192;
wire [255:0]key_256;
wire [127:0]state;
assign state = 128'h00112233445566778899aabbccddeeff;
assign key_128 = 128'h000102030405060708090a0b0c0d0e0f;
assign key_192 = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;
assign key_256 = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
//////////////////////////////////////keys expantions///////////////////////////////////////////////////
wire[(nr_128+1)*128-1:0]expansion_128;
wire[((nr_192+1)*128)-1:0]expansion_192;
wire[((nr_256+1)*128)-1:0]expansion_256;

////////////////////////////////////// expantions///////////////////////////////////////////////////
keyExpansion#(nk_128,nr_128) k128(key_128,expansion_128);
keyExpansion#(nk_192,nr_192) k192(key_192,expansion_192);
keyExpansion#(nk_256,nr_256) k256(key_256,expansion_256);
///////////////////////////////////////////////Encipher///////////////////////////////////////////////
Encrypt #(nk_128, nr_128) e128(key_128,KEY[0], SW[3], state,expansion_128, out_128);
Encrypt #(nk_192, nr_192) e192(key_192,KEY[0], SW[3], state,expansion_192, out_192);
Encrypt #(nk_256, nr_256) e256(key_256,KEY[0], SW[3], state,expansion_256, out_256);
/////////////////////////////////////////////Decipher///////////////////////////////////////////////
Decrypt #(nk_128, nr_128) d128(key_128,KEY[0], SW[3],out_main_128,expansion_128,out_desipher_128);
Decrypt #(nk_192, nr_192) d192(key_192,KEY[0], SW[3],out_main_192,expansion_192,out_desipher_192);
Decrypt #(nk_256, nr_256) d256(key_256,KEY[0], SW[3],out_main_256,expansion_256,out_desipher_256);
always@(posedge KEY[0] or posedge SW[3])
begin
    if(SW[3]==1) // reset
    begin
      counter<=0;
    end
    else
      counter<=counter+1;
end
assign out_main_128 = counter <= nr_128+1 ? out_128 : out_desipher_128;
assign out_main_192 = counter <= nr_192+1 ? out_192 : out_desipher_192;
assign out_main_256 = counter <= nr_256+1 ? out_256 : out_desipher_256;
assign out_main = SW[3] == 1'b1 ? 'b0 : SW[0] == 1'b1 ? out_main_128 : SW[1] == 1'b1 ? out_main_192 : SW[2] == 1'b1 ? out_main_256 : 0;

/////////////////////////////////////////////Encorder && decoder ///////////////////////////////////////////////

Encoder en1 (out_main[7:0],out_encoder);
Decoder de1 (out_encoder,HEX0,HEX1,HEX2);




///////////////////////////////////////////////////////flag check///////////////////////////////////////////////////

reg ledr;
always @(*)
begin
     if(state==out_main&&counter>nr_128)
          ledr<=1;
     else 
          ledr<=0;  
end
assign LEDR[0]=ledr;

endmodule

///////////////////////////////////////////////////////end main////////////////////////////////////////////////