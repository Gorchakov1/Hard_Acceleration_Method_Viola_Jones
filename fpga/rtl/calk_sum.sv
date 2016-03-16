module calk_sum(
  input               clk_i,
  input               rst_i,
  
  input               ii_val_i,
  input [31:0]        ii_data_i,
  
  input [3:0]         weight_i,

  input [3:0]         num_point_i,

  output logic [31:0] sum_cascade_o,
  output logic        sum_cascade_val_o
);


 
logic [3:0] weight [2:0];
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        weight[0] <= 2'b01;
        weight[1] <= '0;
        weight[2] <= '0;
      end
    else
      begin
        if( ii_val_i )
          begin
            weight[1] <= weight_i[3:2];
            weight[2] <= weight_i[1:0];
          end
      end
  end
logic [1:0] point_rect;
logic [1:0] num_rect;

logic val;
delay_signal #(
  .DATA_WIDTH  ( 1 ),
  .CLOCK_CNT   ( 11 )
) delay_sum_cascade (
  .clk_i      ( clk_i                    ),
  .rst_i      ( rst_i                    ),  

  .signal_i   ( ( num_point_i == 11 ) & ii_val_i ), 
  .signal_o   ( val                              )
);

logic [1:0] num_rect_d1;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        point_rect  <= '0;
        num_rect    <= '0;
        num_rect_d1 <= '0;
      end
    else
      begin
        point_rect  <= num_point_i[1:0];
        num_rect    <= num_point_i[3:2];
        num_rect_d1 <= num_rect;
      end
  end

integer point [3:0];
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      for( int i = 0; i < 4; i++)
        point[i] <= '0;
    else
      point[point_rect] <= ii_data_i;
  end


integer signed sum_rect [2:0];
integer signed sum_rect_weight [2:0];
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect[i] <= '0;
      end
    else
      begin
        sum_rect[num_rect_d1] <= ( point[0] - point[1] + point[2] - point[3] );
      end
  end
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect[i] <= '0;
      end
    else
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect_weight[i] <= sum_rect[i] * weight[i];
      end
  end




logic [31:0] sum_cascade;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      sum_cascade <= '0;
    else
      sum_cascade <= sum_rect_weight[2] + sum_rect_weight[1] - sum_rect_weight[0];
  end

int2float i2f(
  .clock  ( clk_i         ),
  .aclr   ( rst_i         ),
  .dataa  ( sum_cascade   ),
  .result ( sum_cascade_o )
);

assign sum_cascade_val_o = val;

///////////////////////////////
/*
always_ff @( posedge clk_i )
  begin
    if( val )
      begin
        $display("!!!!!!!!!!!!!!!!!");
        $display(" SUM CASCADE : %f", $bitstoshortreal( sum_cascade_o ), $time );
      end 
 end
*/
///////////////////////////////
endmodule
