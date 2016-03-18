/*
  Модуль рачитывает свертку с учетом весов прямоугольников
  и конвертирует из int во float.
*/
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

// Первый вес всегда равен 1
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

logic [1:0] point_rect_d1;

logic val;

/*
  Требуется 4 такта требуется для вычисления sum_cascade полсе того, как
  пришела последная точка прямоугольника ( всего их 12, поэтому ( num_point_i == 11 ) & ii_val_i  ) )
  6 тактов для конвертации из int во float.
*/

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
logic [1:0] num_rect_d2;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        point_rect_d1 <= '0;
        num_rect_d2   <= '0;
        num_rect_d1   <= '0;
      end
    else
      begin
        point_rect_d1 <= num_point_i[1:0];
        num_rect_d1   <= num_point_i[3:2];
        num_rect_d2   <= num_rect_d1;
      end
  end

logic [31:0] point [3:0];

// Заполняем вершины прямоугольника
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      for( int i = 0; i < 4; i++)
        point[i] <= '0;
    else
      point[point_rect_d1] <= ii_data_i;
  end


logic [31:0] sum_rect [2:0];
logic [31:0] sum_rect_weight [2:0];

// Расчитываем прямоугольник
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect[i] <= '0;
      end
    else
      begin
        sum_rect[num_rect_d2] <= ( ( point[0] + point[2] ) - ( point[1] + point[3] ) );
      end
  end

// Домнажаем на вес
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect_weight[i] <= '0;
      end
    else
      begin
        for( int i = 0; i < 3 ; i++ )
          sum_rect_weight[i] <= sum_rect[i] * weight[i];
      end
  end




logic [31:0] sum_cascade;

// Считаем свертку
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      sum_cascade <= '0;
    else
      sum_cascade <= sum_rect_weight[2] + sum_rect_weight[1] - sum_rect_weight[0];
  end

// Конвертируем
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
