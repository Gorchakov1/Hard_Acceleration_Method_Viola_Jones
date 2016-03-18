/*

  Модуль преобразует из данных точках прямоугольника 
  в адреса в памяти интегрального изображения ( ram_ii ) и находит 
  веса пямоугольников.

  Т.к. у памяти всего 1 порт для чтения то требуется задержка, чтобы
  новые прямоугольники не появились раньше, чем прочитались старые. 
*/

`include "defs.vh"
module rect_parser #(
  parameter ADDR_WIDTH  = 30,
  parameter LENGHT_LINE = 21 

)
(
  input                            clk_i,
  input                            rst_i,

  input                            rect_val_i,
  input                            type_rect_i,
  input [31:0]                     rect_i,     

  output logic [ADDR_WIDTH-1:0]    addr_o,
  output logic                     val_o,

  output logic [3:0]               weight_o,

  output logic [3:0]               num_point_o,
  output logic                     wait_o
);

// Максимум 3 прямоугольника => 12 точек ( адресов )
localparam POINT_CNT = 12;

rect1_t rect_1;
rect2_t rect_2;

// Парсим с помощью структур
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i)
     begin
       rect_1 <= '0;
       rect_2 <= '0;
     end
    else
      begin
        if( rect_val_i  & type_rect_i )
          rect_2 <= rect_i;
        if( rect_val_i  & ~type_rect_i )
          rect_1 <= rect_i;
      end
  end


// Расчитываем точки ( адреса ) прямоугольика
localparam CALC_0 = 2'b00;
localparam CALC_1 = 2'b01;
localparam CALC_2 = 2'b10;
localparam CALC_3 = 2'b11;

logic rect_val_d1;
logic rect_val_d2;
logic start_cnt_addr;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        rect_val_d1     <= 1'b0;
        rect_val_d2     <= 1'b0;
        start_cnt_addr  <= 1'b0;
      end
    else
      begin
        rect_val_d1    <= rect_val_i;
        rect_val_d2    <= rect_val_d1;
        start_cnt_addr <= ~rect_val_d1 & rect_val_d2;
      end
  end


logic [1:0] state, last_state;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      state <= 2'b00;
    else
      begin
        if( ( state != 0 ) || rect_val_d2 )
          state <= state + 1'b1;
        else
          state <= '0;
      end
  end

assign last_state = state - 1'b1;

logic [4:0] x[2:0];
logic [4:0] y[2:0];

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        for( int i = 0; i < 3; i++ )
          begin
            x[i] <= '0;
            y[i] <= '0;
          end
      end
    else
      begin
        case( state )
          CALC_0 :
            begin
              if( rect_val_d1 )
                begin
                  x[0] <= rect_1.x;
                  y[0] <= rect_1.y;
 
                  x[1] <= rect_1.x1;
                  y[1] <= rect_1.y1;
                  
                  x[2] <= rect_2.x2;
                  y[2] <= rect_2.y2;
                end
            end
          
          CALC_1 :
            begin
              y[0] <= rect_1.y + rect_1.h;
 
              y[1] <= rect_1.y1 + rect_2.h1;

              y[2] <= rect_2.y2 + rect_2.h2;
            end
          
          CALC_2 :
            begin
              x[0] <= rect_1.x + rect_1.w;
              
              x[1] <= rect_1.x1 + { rect_1.w1, rect_2.w1};

              x[2] <= rect_2.x2 + rect_2.w2;
            end

          CALC_3 :
            begin
              y[0] <= rect_1.y;
 
              y[1] <= rect_1.y1;
 
              y[2] <= rect_2.y2;
            end
          default :
            begin
              x[0] <= rect_1.x;
              y[0] <= rect_1.y;
																
              x[1] <= rect_1.x1;
              y[1] <= rect_1.y1;
																
              x[2] <= rect_2.x2;
              y[2] <= rect_2.y2;
            end
        endcase
      end
  end

logic [ADDR_WIDTH-1:0] addr [2:0][3:0];  

always_ff @( posedge clk_i or posedge rst_i)
  begin
    for( int i = 0 ; i < 3; i++)
      begin
        if( rst_i )
          for( int j = 0; i < 4; i ++ )
            addr[i][j] <= '0;
        else
          addr[i][last_state] <= ( LENGHT_LINE * y[i] ) + x[i];
      end 
  end

logic [3:0]cnt_addr;
// Начинаем считать как только появился 1 адрес
// Заканиваем как только адреса закончились
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      cnt_addr <= '0;
    else
      begin
        if( cnt_addr != '0 || start_cnt_addr )
          cnt_addr = cnt_addr + 1'b1;
        if( cnt_addr == POINT_CNT )
          cnt_addr = 0;
      end
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      wait_o <= 1'b0;
    else
      begin
        if( rect_val_i )
          wait_o <= 1'b1;
        if( cnt_addr == ( POINT_CNT - 1 ) )
          wait_o <= 1'b0;
      end
  end

assign num_point_o = cnt_addr;
assign addr_o      = addr[cnt_addr[3:2]][cnt_addr[1:0]];
assign val_o       = ( cnt_addr != '0 ) || start_cnt_addr;
assign weight_o    = { rect_2.weight1, rect_2.weight2 };


endmodule
