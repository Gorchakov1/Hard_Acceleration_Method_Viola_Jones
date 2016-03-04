
import struct
def float32_bit_pattern(value):
    return sum(ord(b) << 8*i for i,b in enumerate(struct.pack('f', value)))


def int_to_binary(value, bits):
    return bin(value).replace('0b', '').rjust(bits, '0')

def float2binary( value ):
 return int_to_binary(float32_bit_pattern( value ), 32)


