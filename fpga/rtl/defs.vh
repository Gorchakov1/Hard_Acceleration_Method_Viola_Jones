`ifndef _defs
`define _defs

`define LEFT_VAL  2'b01
`define RIGHT_VAL 2'b10
`define THRESHOLD 2'b00

typedef struct packed{
  logic [4:0] x;
  logic [4:0] y;
  
  logic [4:0] w;
  logic [4:0] h;
 
  logic [4:0] x1;
  logic [4:0] y1;

  logic [1:0] w1;
} rect1_t;

typedef struct packed{
  logic [2:0] w1;
  logic [4:0] h1;
  
  logic [1:0] weight1;
  
  logic [4:0] x2;
  logic [4:0] y2;

  logic [4:0] w2;
  logic [4:0] h2;
 
  logic [1:0] weight2;
 
} rect2_t;

`endif
