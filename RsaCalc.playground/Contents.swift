import UIKit

class RsaTest {
    struct RsaKey {
        let n: Int
        let other: Int
    }
    lazy var publicKey: RsaKey = .init(n: 0, other: 0)
    lazy var privateKey: RsaKey = .init(n: 0, other: 0)
    
    init(p: Int, q: Int) {
        let n = p * q
        let r = (p-1)*(q-1)
        let e = getCoprime(with: r)
        let d = modinv(e, r)!
        publicKey = RsaKey.init(n: n, other: e)
        privateKey = RsaKey.init(n: n, other: d)
        print("p: ", p)
        print("q: ", q)
        print("N: ", n)
        print("r: ", r)
        print("E: ", e)
        print("D: ", d)
    }
    
    // Greatest Common Divisor
    private func gcd(_ lhs: Int, _ rhs: Int) -> Int {
        let value = lhs % rhs
        if value == 0 { return rhs }
        return gcd(rhs, value)
    }
    
    private func getCoprime(with vlaue: Int) -> Int {
        for i in 2000 ..< vlaue {
            if gcd(i, vlaue) == 1 {
                return i
            }
        }
        return 65537
    }
    
    private func xgcd (_ a: Int, _ b: Int) -> (Int, Int, Int) {
        switch (a, b) {
        case (_, 0): return (1, 0, a)
        default:
            let (x, y, g) = xgcd(b, a % b)
            return (y, x - (Int)(a/b) * y, g)
        }
    }
    
    private func modinv (_ a: Int, _ m: Int) -> Int? {
        let (x, _, g) = xgcd(a, m)
        if g == 1 {
            return x % m
        }
        return nil
    }
    
    func pow(value: Int, power: Int, mod: Int) -> Int {
        
        if value > mod {
            return pow(value: value % mod, power: power, mod: mod)
        }
        
        let powCount = 2
        
        if power <= powCount {
            
            return Int(Foundation.pow(Double(value), Double(power))) % mod
            
        } else {

            let count = power / powCount
            let modValueWithPower = pow(value: value, power: powCount, mod: mod)
            let powerValue = pow(value: modValueWithPower, power: count, mod: mod)
            
            let modPowerValue = power % powCount
            let otherValue = pow(value: value, power: modPowerValue, mod: mod)
            
            return  powerValue * otherValue % mod
        }
    }

    func encrypt(value: Int) -> Int {
        print("encrypt\n\nv:\t\(value)\npow:\t\(publicKey.other)\nn:\t\(publicKey.n)")
        return pow(value: value, power: publicKey.other, mod: publicKey.n)
    }
    
    func decrypt(value: Int) -> Int {
        print("decrypt\n\nv:\t\(value)\npow:\t\(privateKey.other)\nn:\t\(privateKey.n)")
        return pow(value: value, power: privateKey.other, mod: privateKey.n)
    }
    
}

let rsa = RsaTest(p: 3571, q: 2377)

print("publicKey:\t(\(rsa.publicKey.n), \(rsa.publicKey.other))")
print("privateKey:\t(\(rsa.privateKey.n), \(rsa.privateKey.other))")
print("--------")

let encrypt = rsa.encrypt(value: 22)
print("\t\(encrypt)")
print("--------")
let decrypt = rsa.decrypt(value: encrypt)
print("\t\(decrypt)")
