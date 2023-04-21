//
//  TestInfo.swift
//  WidgetCrashWithWCDBSwift
//
//  Created by Lei Li on 18/04/2023.
//

import Foundation
import WCDBSwift

final class TestInfo: TableCodable {
    var uuid: String?
    enum CodingKeys: String, CodingTableKey {
        typealias Root = TestInfo
        case uuid
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(uuid, isPrimary: true)
        }
        
    }
}

class TestManager: NSObject {
    let testTable = "testTable"
    static var manager = TestManager()
    var database: Database? = nil
    override init() {
        super.init()
        let dbPath = Self.databasePath()
        database = Database(at: dbPath)
        if let pwdData = "$b)PGhvRtpjnQDqc".data(using: .utf8)  {
            database?.setCipher(key: pwdData)
            database?.setConfig(named: "demo", withInvocation: { handle in
                //The call back only be called when the app first be install.According to the sqlciper doc. I need to run this on every open database.
                if let salt = Self.getSalt(), !salt.isEmpty {
                    do {
                        #warning("need set Pragma.init(named name: String) to public first")
                        let headerSizePragma = Pragma(named: "cipher_plaintext_header_size")
                        try handle.exec(StatementPragma().pragma(headerSizePragma).to(32))
                        let saltPragma = Pragma(named: "cipher_salt")
                        try handle.exec(StatementPragma().pragma(saltPragma).to(salt))
                    } catch  {
                        print(error)
                    }
                    
                    
                }
                
            }, withPriority: .high)
            
            
            
        }
        print(dbPath)
        do {
            try database?.create(table: testTable, of: TestInfo.self)
        } catch  {
            print(error)
        }
    }
    
    class func getSalt() -> String? {
        if let dbURL = URL(string: databasePath()) {
            do {
                let saltLength = 16
                let handle = try FileHandle(forReadingFrom:dbURL)
                let first16Bytes: Data? = try handle.read(upToCount: saltLength)
                try handle.close()
                let salt = first16Bytes?.hexEncodedString()
                if let salt = salt {
                    print(salt)
                    save(salt: salt)
                }
                return salt
            } catch  {
                print(error)
            }
        }
        return getSavedSalt()
    }
    
    class func databasePath() -> String {
        let pathPrefix = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ai.daypop.imdev")?.path)!
        return NSString(string: pathPrefix + "/DataBase/Test").appendingPathExtension("sqlite")!
    }
    
    func saveInfo(info: TestInfo) {
        do {
            try database?.insertOrReplace(info, intoTable: testTable)
        } catch  {
            print(error)
        }
    }
    
    class func save(salt: String) {
        UserDefaults.standard.set(salt, forKey: "salt")
    }
    
    class func getSavedSalt() -> String? {
        if let salt =  UserDefaults.standard.string(forKey: "salt") {
            print(salt)
            return salt
        }
        
        return nil
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
