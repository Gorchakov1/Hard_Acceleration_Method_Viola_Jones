`include "defs.hv"
module rect_parser #(
  ADDR_WIDTH = 30

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

rect1 rect_1;
rect2 rect_2;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i)
     begin
       rect_1 <= '0;
       rect_2 <= '0;
     end
    else
      begin
        if( type_rect_i )
          begin
            if( rect_val_i )
              rect_2 <= rect_i;
          end
        else
          begin
            if( rect_val_i )
              rect_1 <= rect_i;
          end
      end
  end


logic rect_val;
logic rect_val_d1;
logic start_cnt_addr;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        rect_val        <= 1'b0;
        rect_val_d1     <= 1'b0;
        start_cnt_addr  <= 1'b0;
      end
    else
      begin
        rect_val       <= rect_val_i;
        rect_val_d1    <= rect_val;
        start_cnt_addr <= ~rect_val & rect_val_d1;
      end
  end



enum logic [1:0] { CALK_0 = 2'b00,
                   CALK_1 = 2'b01,
                   CALK_2 = 2'b10,
                   CALK_3 = 2'b11
                 } state, next_state;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      state <= CALK_0;
    else
      state <= next_state;
  end
always_comb
  begin
    next_state = state;
    case( state )
      CALK_0 :
        begin
          if( rect_val_d1 )
            next_state = CALK_1;
        end
      
      CALK_1 :
        begin
          next_state = CALK_2;
        end
      
      CALK_2 :
        begin
          next_state = CALK_3;
        end

      CALK_3 :
        begin
          next_state = CALK_0;
        end
      default :
        begin
          next_state = CALK_0;
        end
    endcase
  end
logic [4:0] x[2:0];
logic [4:0] y[2:0];
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        x[0] <= '0;
        y[0] <= '0;

        x[1] <= '0;
        y[1] <= '0;

        x[2] <= '0;
        y[2] <= '0;
      end
    else
      begin
        case( state )
          CALK_0 :
            begin
              if( rect_val )
                begin
									x[0] <= rect_1.x;
									y[0] <= rect_1.y;
 
									x[1] <= rect_1.x1;
									y[1] <= rect_1.y1;

									x[2] <= rect_2.x2;
									y[2] <= rect_2.y2;
                end
            end
          
          CALK_1 :
            begin
              y[0] <= rect_1.y + rect_1.h;
 
              y[1] <= rect_1.y1 + rect_2.h1;

              y[2] <= rect_2.y2 + rect_2.h2;
            end
          
          CALK_2 :
            begin
              x[0] <= rect_1.x + rect_1.w;
              
              x[1] <= rect_1.x1 + { rect_1.w1, rect_2.w1};

              x[2] <= rect_2.x2 + rect_2.w2;
            end

          CALK_3 :
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
          addr[i][i] <= '0;
        else
          addr[i][state-1'b1] <= ( 21 * y[i] ) + x[i];
      end 
  end

logic [3:0]cnt_addr;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      cnt_addr <= '0;
    else
      begin
        if( cnt_addr != '0 || start_cnt_addr )
          cnt_addr = cnt_addr + 1'b1;
        if( cnt_addr == 12 )
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
        if( cnt_addr == 11 )
          wait_o <= 1'b0;
      end
  end

assign num_point_o = cnt_addr;
assign addr_o      = addr[cnt_addr[3:2]][cnt_addr[1:0]];
assign val_o       = ( cnt_addr != '0 ) || start_cnt_addr;
assign weight_o    = { rect_2.weight1, rect_2.weight2 };
endmodule
