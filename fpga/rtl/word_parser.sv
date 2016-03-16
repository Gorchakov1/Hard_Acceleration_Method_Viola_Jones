module word_parser #(
  ADDR_WIDTH = 30  
)
(
  input                         clk_i,
  input                         rst_i,

  input  [31:0]                 rom_data_i,
  input                         last_stage_i,
  input                         stage_threshold_val_i,
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

localparam RECT_P0         = 3'b000;
localparam RECT_P1         = 3'b001;
localparam THRESHOLD       = 3'b010;
localparam LEFT_VAL        = 3'b011;
localparam RIGHT_VAL       = 3'b100;
localparam STAGE_THRESHOLD = 3'b101;

logic [2:0] type_word;
logic rom_val;
logic last_stage;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      last_stage <= 1'b0;
    else
      last_stage <= last_stage_i;
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
          type_word <= ( next_rect_p0 ) ? RECT_P0 : type_word + rom_val;
      end
  end
assign next_rect_p0 = ( ( ( type_word == STAGE_THRESHOLD ) || ( type_word == RIGHT_VAL ) ) && rom_val ) || last_stage;

logic stage_threshold_val;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        stage_threshold_val <= '0;
        rom_val            <= '0;
      end
    else
      begin
        stage_threshold_val <= stage_threshold_val_i;
        rom_val            <= rom_val_i;
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
assign stage_threshold_val_o = stage_threshold_val;

assign thresholds_type_o = type_word - 2'b10;
assign thresholds_o      = rom_data;
assign thresholds_val_o  = ( ( type_word == THRESHOLD ) || ( type_word == RIGHT_VAL ) || ( type_word == LEFT_VAL ) ) & rom_val;

logic        rect_val;
logic        type_rect;
logic [31:0] rect;
assign rect_val  = ( ( type_word == RECT_P0 ) || ( type_word == RECT_P1 ) ) && rom_val;
assign type_rect = ( type_word == RECT_P1 );
assign rect      = rom_data;

rect_parser #(
  .ADDR_WIDTH   ( ADDR_WIDTH )
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
