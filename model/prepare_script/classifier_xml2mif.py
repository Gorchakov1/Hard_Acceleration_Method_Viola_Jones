import cv2

from float2bin import *

def get_rect( rect_line, key ):
  if( key == 0 ):
    rect = [ int( rect_line[0][3:] ), int( rect_line[1] ), int( rect_line[2] ), int( rect_line[3] ) ]
  else:
    rect = [ int( rect_line[0][3:] ), int( rect_line[1] ), int( rect_line[2] ), int( rect_line[3] ) , int( rect_line[4][0] ) ]
  return rect

def get_treshold( line, key ):
  line = str( line[0]) 
  if( key == 0 ):
     treshold = float( line[11:len( line ) - 12 ] )
  else:
     treshold = float( line[17:len( line ) - 18 ] ) 
  return treshold

def get_left( line ):
  line = str( line[0]) 
  return float( line[10:len( line ) - 11 ]  )

def get_right( line ):
  line = str( line[0])
  if( len(line) > 49 ):
    right = float( line[11:len( line ) - 35 ]  )
  else:
    right = float( line[11:len( line ) - 20 ]  )
  return right

def int2bin( num, key ):
   if( key == True ):
     form = '02b'
   else:
     form = '05b'
   return format( num, form )


treshold_addr = list()
str_mif = list()
addr = list()
f = open("../../tools_cv/haarcascade_frontalface_alt.xml", 'r' )
xml_lines = f.readlines()

for i, line in enumerate(xml_lines):
  line = line.split()
  if( len(line) > 1):
    if( line[1] == "stage" ):
      addr.append( i )
addr.append( len( xml_lines ) )

for stage in range( len( addr ) ):
  if (stage == len(addr) - 1 ):
     break
  for num_line in range(addr[stage], addr[stage + 1]):
     line = xml_lines[num_line].split()
     
     if( line[0] == "<rects>" ):
       rect_line = xml_lines[num_line + 1].split()
       rect1 = get_rect( rect_line,0 )  
       
       rect_line = xml_lines[num_line + 2].split()
       rect2 = get_rect( rect_line, 1 )  
       if( len( rect_line[4] ) != 14 ):
         offset = 5
         rect3 = get_rect( xml_lines[num_line + 3 ].split(),1 )
       else: 
         offset = 4
         rect3 = [ 0, 0, 0, 0, 0 ]

       feature_treshold = get_treshold( xml_lines[num_line + offset].split(), 0 )
       left             = get_left( xml_lines[num_line + offset + 1].split() ) 
       right            = get_right( xml_lines[num_line + offset + 2].split() )
       
       rects = [ rect1, rect2, rect3 ]
       rect_str = str()
       for rect in rects:
         for i,var in enumerate( rect ):
             rect_str = rect_str + int2bin( var, i > 3  )
       str_mif.append( rect_str[:32]  )
       str_mif.append( rect_str[32:]  )
       str_mif.append( float2binary( feature_treshold ) )
       str_mif.append( float2binary( left )  )
       str_mif.append( float2binary( right ) )

     if( line[0][:7] == "<stage_"):
       stage_treshold = get_treshold( line, 1 )
       str_mif.append( float2binary( stage_treshold ) )
       treshold_addr.append( len( str_mif ) )

f.close()

f = open('classifier.mif', 'w' )
f.write( 'WIDTH = 32;\n' )
f.write( 'DEPTH = %d;\n' %( len( str_mif ) ) );
f.write( 'ADDRESS_RADIX = HEX;\n')
f.write( 'DATA_RADIX = BIN;\n ' )
f.write( 'CONTENT BEGIN\n' )
for addr, string in enumerate( str_mif ):
  f.write('%s : %s;\n' %( hex(addr)[2:], string ) ) 
f.write('END\n')
f.close()

f = open('treshold_addr', 'w' )
for data in treshold_addr:
  f.write('%i\n'% ( data ) )
f.close()


