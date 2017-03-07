//
//  Crypto.swift
//  MySampleApp
//
//  Created by piyushMac on 07/03/17.
//
//


//class Crypto {
//    func getMD5(src: String) -> String {
//        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//        if let data = src.dataUsingEncoding(NSUTF8StringEncoding) {
//            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
//        }
//        
//        var digestHex = ""
//        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
//            digestHex += String(format: "%02x", digest[index])
//        }
//        
//        return digestHex
//    }
//}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}
