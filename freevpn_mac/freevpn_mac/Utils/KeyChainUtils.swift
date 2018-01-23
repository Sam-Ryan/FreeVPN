//
//  KeyChainUtils.swift
//  freevpn
//
//  Created by ligulfzhou on 7/10/16.
//  Copyright © 2016 ligulfzhou. All rights reserved.
//

import Foundation

let service = Bundle.main.bundleIdentifier!
let userAccount = "freevpn"
let accessGroup = "freevpn"

class KeyChainUtil{

    class func store(_ key: String, value: String){
        let valueData = value.data(using: String.Encoding.utf8)
        let keychainQuery:[String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: key as AnyObject,
            kSecAttrAccount as String: key as AnyObject,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleAlwaysThisDeviceOnly,
            kSecValueData as String: valueData! as AnyObject
        ]
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if errSecSuccess != status{
            NSLog("keychain store error")
        }
        NSLog("\(key)   keychain store success")
    }
    
    class func get(_ key: String) -> Data?{
        let keychainQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: key,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAlwaysThisDeviceOnly,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnPersistentRef as String: kCFBooleanTrue
        ] as [String : Any]
        var dataTypeRef: AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        if status != errSecSuccess{
            return nil
        }
         NSLog("\(key)   keychain get success")
        return dataTypeRef as! Data?
    }
    
    class func getStringValue(_ key: String) -> String {
        
        let keychainQuery: [NSString: NSObject] = [
            kSecClass as String as String as NSString: kSecClassGenericPassword,
            kSecAttrService as String as String as NSString: service as NSObject,
            kSecAttrGeneric as String as String as NSString: key as NSObject,
            kSecAttrAccount: key as NSObject,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne]
        
        var rawResult: AnyObject?
        let keychain_get_status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &rawResult)
        if (keychain_get_status == errSecSuccess) {
            let retrievedData = rawResult as? Data
            let pass = NSString(data: retrievedData!, encoding: String.Encoding.utf8.rawValue)
            return pass as! String
        } else {
            return ""
        }
    }
    
    fileprivate func saveStringValue(_ service: String, data: String){
        let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // Instantiate a new default keychain query
//        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects:[kSecClassGenericPassword as String, service, userAccount, dataFromString], forKeys: [kSecClass as String, kSecAttrService as String, kSecAttrAccount as String, kSecValueData as String])
        
        let keychainQuery: [NSString: NSObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: userAccount as NSObject,
            kSecAttrService: service as NSObject,
            kSecValueData: dataFromString as NSObject]

        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        NSLog("save result: \(status)")
    }
    
}
