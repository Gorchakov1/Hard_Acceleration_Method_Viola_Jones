/*
  Модуль определяет какие данные приходят с ROM.
  В зависимости от типа данных отправляет в разные выходы.

  rect_parser преобразует из данных точках прямоугольника 
  в адреса в памяти интегрального изображения ( ram_ii ) и находит 
  веса пямоугольников.

  Т.к. у памяти всего 1 порт для чтения то требуется задержка, чтобы
  новые прямоугольники не появились раньше, чем прочитались старые. 

*/
module word_parser #(
  parameter ADDR_WIDTH     = 30,
  parameter LENGHT_LINE_II = 21  
)
(
  input                         clk_i,
  input                         rst_i,

  input                         stage_threshold_val_i,
  input                         last_stage_i,
  
  input  [31:0]                 rom_data_i,
  input                         rom_val_i,

  output logic [31:0]           stage_threshold_o,
  output logic                  stage_threshold_val_o,

  output logic [31:0]           thresholds_o,
  output logic [1:0]            thresholds_type_o,
  output logic                  thresholds_val_o,
  
  output logic [ADDR_WIDTH-1:0] addr_ii_o,
  output logic                  val_ii_o,
  output logic [3:0]            weight_o,

  output logic [3:0]            num_point_o,

  output logic                  wait_o
);

// Вся информация о прямоугольникаx помещается 
// в 2 слова, поэтому P0 и P1
localparam RECT_P0         = 3'b000;
localparam RECT_P1         = 3'b001;
localparam THRESHOLD       = 3'b010;
localparam LEFT_VAL        = 3'b011;
localparam RIGHT_VAL       = 3'b100;
localparam STAGE_THRESHOLD = 3'b101;

logic [2:0] type_word;
logic       rom_val_d1;
logic       last_stage_d1;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      last_stage_d1 <= 1'b0;
    else
      last_stage_d1 <= last_stage_i;
  end

logic next_rect_p0;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      type_word <= RECT_P0;
    else
      begin
        if( stage_threshold_val_i )
          type_word <= STAGE_THRESHOLD;
        else
          type_word <= ( next_rect_p0 ) ? RECT_P0 : type_word + rom_val_d1;
      end
  end

// Определяем когда будет первый прямоугольник, т.к. он появляется при разных условиях
assign next_rect_p0 = ( ( ( type_word == STAGE_THRESHOLD ) || ( type_word == RIGHT_VAL ) ) && rom_val_d1 ) || last_stage_d1;

logic stage_threshold_val_d1;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        stage_threshold_val_d1 <= '0;
        rom_val_d1             <= '0;
      end
    else
      begin
        stage_threshold_val_d1 <= stage_threshold_val_i;
        rom_val_d1             <= rom_val_i;
      end
  end

logic [31:0] rom_data;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      rom_data <= '0;
    else
      begin
        if( rom_val_i )
          rom_data <= rom_data_i;
      end
  end

logic [31:0] stage_threshold;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      stage_threshold <= '0;
    else
      begin
        if( stage_threshold_val_i )
          stage_threshold <= rom_data_i;
      end
  end

assign stage_threshold_o     = stage_threshold;
assign stage_threshold_val_o = stage_threshold_val_d1;

//Вычитаем 2'b10 чтобы не передовать 3 битную переменную
assign thresholds_type_o = type_word - 2'b10;
assign thresholds_o      = rom_data;
assign thresholds_val_o  = ( ( type_word == THRESHOLD ) || ( type_word == RIGHT_VAL ) || ( type_word == LEFT_VAL ) ) & rom_val_d1;

logic        rect_val;
logic        type_rect;
logic [31:0] rect;

assign rect_val  = ( ( type_word == RECT_P0 ) || ( type_word == RECT_P1 ) ) && rom_val_d1;
assign type_rect = ( type_word == RECT_P1 );
assign rect      = rom_data;

rect_parser #(
  .ADDR_WIDTH     ( ADDR_WIDTH     ),
  .LENGHT_LINE    ( LENGHT_LINE_II )
) rect_p (
  .clk_i        ( clk_i       ),
  .rst_i        ( rst_i       ),
  
  .rect_val_i   ( rect_val    ),
  .type_rect_i  ( type_rect   ),
  .rect_i       ( rect        ),
 
  .addr_o       ( addr_ii_o   ),
  .val_o        ( val_ii_o    ),

  .weight_o     ( weight_o    ),

  .num_point_o  ( num_point_o ),
  .wait_o       ( wait_o      )
);

endmodule
