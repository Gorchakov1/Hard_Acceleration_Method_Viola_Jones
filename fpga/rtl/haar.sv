`include "defs.vh"
module haar #(
  parameter WINDOW_SIZE = 21

)
(
  
  input               clk_i,
  input               rst_i,

  // avalon-mm slave
  input  [3:0]        avs_address,
  input  [31:0]       avs_writedata,
  input               avs_read,
  input               avs_write,

  output logic [31:0] avs_readdata,
  output logic        avs_waitrequest
);

localparam WINDOW_SIZE_WIDTH = $clog2( WINDOW_SIZE );
localparam II_ADDR_WIDTH     = $clog2( WINDOW_SIZE * WINDOW_SIZE );

localparam CTRL_REG  = 16;

logic ii_wr;
assign ii_wr = ( avs_address == `AVS_II_ADDR ) && avs_write;

logic [WINDOW_SIZE_WIDTH-1:0] num_row;
logic [WINDOW_SIZE_WIDTH-1:0] num_col;
logic [II_ADDR_WIDTH-1:0] ii_addr;

logic row_end;
assign row_end = ( num_row == WINDOW_SIZE - 1 ); 


always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      num_row <= '0;
    else
      begin
        if( row_end )
          num_row <= '0;
        else
          num_row <= num_row + ii_wr;
      end
  end

logic col_end;
assign col_end = ( num_col == WINDOW_SIZE - 1) && row_end;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      num_col <= '0;
    else
      begin
        if( col_end )
          num_col <= '0;
        else
          num_col <= num_col + row_end;
      end
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      ii_addr <= '0;
    else
      begin
        if( col_end )
          ii_addr <= '0;
        else
          ii_addr <= ii_addr + ii_wr;
      end
  end

// Offset addr Itegral Image
logic [II_ADDR_WIDTH-1:0] ii_addr_offset;

logic [31:0] flags;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      ii_addr_offset <= '0;
    else
      begin
        if( flags[`FLAG_NEW_COL] )
          ii_addr_offset <= '0;
        else
          ii_addr_offset <= row_end ? ii_addr_offset + 21 : ii_addr_offset;
      end
  end

// Variance norm factor
logic [31:0] variance_norm_factor;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      variance_norm_factor <= '0;
    else
      begin
        if( ( avs_address == `AVS_VARIANCE_NORM_FACTOR_ADDR ) && avs_write ) 
          variance_norm_factor <= avs_writedata;
      end
  end

// FLAGS
logic wr_flags;
assign wr_flags = ( avs_address == `AVS_FLAGS_ADDR ) & avs_write;


logic done;
logic start;
logic result;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      flags <= 32'h8000_0000; 
    else
      begin
        if( wr_flags )
          flags[CTRL_REG-1:0] <= avs_writedata[CTRL_REG-1:0];

        // READY FLAG
        if( start )
          flags[`FLAG_READY] <= 1'b0;
        else
          begin
            if( done )
              flags[`FLAG_READY] <= 1'b1;
          end
       
       // RESULT FLAG
       if( done )
         flags[`FLAG_RESULT] <= result;
      end
  end

assign avs_readdata = flags;
assign avs_waitrequest = 1'b0; 
// Other
assign start = ( flags[`FLAG_NEW_COL] && col_end ) || ( !flags[`FLAG_NEW_COL] && row_end );
run_haar_classifier_cascade_sum #(
  .LENGHT_LINE_II       ( 21                      ),
  //.NUM_WORDS_ROM        ( 10697                   ),
  .ADDR_WIDTH_II        ( II_ADDR_WIDTH           ),
  //.ADDR_WIDTH_ROM       ( $clog2( NUM_WORDS_ROM ) ),
  .STAGE_CLASSIFIER_CNT ( 22                      ) 
) haar (
  .clk_i                   ( clk_i                ),
  .rst_i                   ( rst_i                ),
  
  .start_i                 ( start                ),

  .offset_i                ( ii_addr_offset       ),

  .ii_addr_wr_i            ( ii_addr              ),
  .ii_data_wr_i            ( avs_writedata        ),
  .ii_val_wr_i             ( ii_wr                ),
  
  .variance_norm_factor_i  ( variance_norm_factor ),
  
  .done_o                  ( done                 ),
  .result_o                ( result               )
);

endmodule
