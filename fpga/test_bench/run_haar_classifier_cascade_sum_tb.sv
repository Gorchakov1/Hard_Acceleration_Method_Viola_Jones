`timescale 1 ps / 1 ps
module run_haar_classifier_cascade_sum_tb;
parameter ADDR_WIDTH_II        = $clog2( 21 * 21 );
parameter ADDR_WIDTH_ROM       = $clog2( NUM_WORDS_ROM );
parameter NUM_WORDS_ROM        = 10697;
parameter STAGE_CLASSIFIER_CNT = 22;
logic clk;
logic rst;

logic start;
logic done;
logic result;




initial
 begin
   clk = 1'b0;
   forever
     begin
       #10.0 clk = ~clk;
     end
 end

initial
  begin
    rst = 1'b1;
    #11.0 rst = 1'b0;
    $display( "RST DONE" );
  end

initial 
  begin
    start = 1'b0;
    #60 
    start = ~start;
    @( posedge clk );
    start = ~start;
    wait( done );
      begin
        for(int i = 0; i < 500; i ++)
          begin
            @( posedge clk );
          end
        @( posedge clk );
        start = 1'b1;
        @( posedge clk );
        start = 1'b0;
      end
  end
logic [31:0]              variance_norm_factor;
logic [ADDR_WIDTH_II-1:0] ii_addr_wr;
logic [31:0]              ii_data_wr;
assign variance_norm_factor = 32'b01000101100100011101000001000000;  

assign ii_addr_wr           = '0;
assign ii_data_wr           = '0;   
assign ii_val_wr            = 1'b0;
run_haar_classifier_cascade_sum
run(
  .clk_i                  ( clk                  ),
  .rst_i                  ( rst                  ),
                                                 
  .start_i                ( start                ),
                                                 
  .ii_addr_wr_i           ( ii_addr_wr           ),
  .ii_data_wr_i           ( ii_data_wr           ),
  .ii_val_wr_i            ( ii_val_wr            ),

  .variance_norm_factor_i ( variance_norm_factor ),

  .done_o                 ( done                 ),
  .result_o               ( result               )
);

always_comb
  begin
    if( done )
      $display("Done ! Result %d ", result);
  end


endmodule 
