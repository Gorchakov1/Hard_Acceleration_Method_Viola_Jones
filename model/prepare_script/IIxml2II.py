import cv2

img = cv2.cv.Load("II.xml")
II = list()

x = 105
y = 57
offset = 21

for i in range(img.rows ):
  if( i >= y and i < y + offset ):
    for j in range( img.cols):
    #if( 836486 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
    #  print 'p0 ',i,j
    #if( 1018943 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
    #  print 'p1 ', i,j
    #if( 885326 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
    #  print 'p2 ', i,j
    #if( 1080009 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
    #  print 'p3 ', i,j

      if( j>= x and j < x + offset ):
#        print i,j
        II.append( [ int ( cv2.cv.Get2D( img,i,j )[0] ), i , j ] )





f = open('II', 'w')
for data in II:
  f.write( "%i\n" % data[0] )
  print data
f.close()
  
