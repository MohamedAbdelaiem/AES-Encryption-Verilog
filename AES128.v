module Cipher128(output wire [127:0] out1,input clk);
    wire [127:0] state;
    reg [127:0] state0;
    reg [127:0]temp;
    wire [127:0] key;
    wire [127:0] out;
    wire [127:0] out_lastround;
    integer i=-1;
    assign state = 128'h00112233445566778899aabbccddeeff;
    assign key = 128'h000102030405060708090a0b0c0d0e0f;
    wire [0:1407] w;
    KeyExpansion128 uut(key, w);
    round x(state0, w[((i+1)*128)+:128],out);   
 always@ (posedge clk) 
    begin 
        if(i==-1)
        begin
            state0<=state^w[0:127];
             temp<=out;
            i=i+1;
        end
        else if(i<10)
        begin
        state0<=out;  
        temp<=out;
        i=i+1;
        end
        else if(i==10)
        begin
            temp<=out_lastround;
        end
    end
    assign out1=temp;
    last_round xs(state0,w[((i+1)*128)+:128],out_lastround);
    assign temp=out_lastround;
endmodule

module InvCipher128(output [127:0] out);
    wire [127:0] state;
    wire [127:0] key;

    assign state = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
    assign key = 128'h000102030405060708090a0b0c0d0e0f;

    wire [127:0] states [39:0] ;

    
    wire [0:1407] w;

    KeyExpansion128 uut(key, w);
 

    AddRoundKey ak1(state, w[1280+:128], states[0]);
    
    genvar i;
    generate
        for(i = 0; i < 9; i = i + 1) begin: round
            
            InvShiftRows sr(states[(i*4)], states[(i*4)+1]);
            InvSubBytes sb(states[(i*4)+1], states[(i*4)+2]);
            AddRoundKey ak(states[(i*4)+2], w[((10-i-1)*128)+:128], states[(i*4)+3]);
            InvMixColumns mc(states[(i*4)+3], states[(i*4)+4]);
            
        end
    endgenerate


    InvShiftRows sr2(states[(8*4)+4], states[(8*4)+5]);
    InvSubBytes sb2(states[(8*4)+5], states[(8*4)+6]);
    
    AddRoundKey ak2(states[(8*4)+6], w[0:127], states[(8*4)+7]);
    
    
    assign out = states[(8*4)+7];

endmodule

module Cipher128_tb();//must be run in modelsim( run 1200 )

    reg clk; // Define clock signal
    wire [127:0] outer;

    // Instantiate the module under test
    Cipher128 uut(outer, clk);

    // Clock generation
    initial begin
        clk = 0; // Initialize clock
        #50;
        repeat (10) begin // Repeat for 10 positive edges
            #50 clk = 1; // Set clock high after 50 time units
            #50 clk = 0; // Set clock low after another 50 time units
        end
        #50; // Wait for final stabilization
        $display("out = %h", outer); // Display the output
        //$finish; // End the simulation
    end

endmodule




module InvCipher128_tb();
    wire [127:0] out;
    InvCipher128 uut(out);
    initial begin
        #10;
        $display("out = %h", out);
    end

endmodule