
from math import gcd
import sys

def getE(phi):
    for i in range( 2000, phi ):
    	if gcd( i, phi ) == 1:
		    return i

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m


p = 3571 # 質數
q = 2377 # 質數
N = p * q 
r = (p - 1) * (q - 1)
E = getE(r) # 跟 r 互質
D = modinv(E, r) # E * D % r = 1

publickey = (E, N)
privatekey = (D, N)

plain_text = int(input("input your plain_text(int): "))

# 加密方式 
# 密文 = 明文^e % n
cipher_text = pow(plain_text, publickey[0], publickey[1])

# 明文 = 密文^d % n
value = pow(cipher_text, privatekey[0], privatekey[1])

print("p: ", p)
print("q: ", q)
print("N: ", N)
print("r: ", r)
print("E: ", E)
print("D: ", D)

print("明文: ", plain_text)
print("密文: ", cipher_text)
print("解密後明文: ", value)
