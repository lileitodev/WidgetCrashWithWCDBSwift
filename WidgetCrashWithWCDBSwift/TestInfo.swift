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
        database?.setConfig(named: "demo", withInvocation: { handle in
            do {
                if let salt = Self.getSavedSalt(), !salt.isEmpty {
                    let mark: String = "open plaintext db again:"
                    try handle.exec(StatementPragma().pragma(.key).to("test"))
                    print("\(mark) set key done")
                    try handle.exec(StatementPragma().pragma(.cipherSalt).to("x'\(salt)'"))
                    print("\(mark) read saved salt: set salt done")
                    try handle.exec(StatementPragma().pragma(.cipherPlainTextHeaderSize).to(32))
                    print("\(mark) set cipherPlainTextHeaderSize done")

                } else {
                    let mark: String = "set plain text for db:"
                    try handle.exec(StatementPragma().pragma(.key).to("test"))
                    print("\(mark) set key done")
                    try handle.exec(StatementSelect().select(Column.all).from("sqlite_master"))
                    print("\(mark) fetch sqlite_master done")
                    try handle.exec(StatementPragma().pragma(.cipherSalt))
                    print("\(mark) get salt done")
                    if let salt = Self.getDBSalt() {
                        try handle.exec(StatementPragma().pragma(.cipherSalt).to("x'\(salt)'"))
                        print("\(mark) set salt done")
                        try handle.exec(StatementPragma().pragma(.cipherPlainTextHeaderSize).to(32))
                        print("\(mark) set cipherPlainTextHeaderSize done")
                        //force write cipherPlainTextHeaderSize
                        try handle.exec(StatementPragma().pragma(.userVersion).to(1))
                        print("\(mark) set userVersion done")
                    }
                }
                
            } catch  {
                print(error)
            }
        }, withPriority: .highest)
        
        print(dbPath)
        do {
            try database?.create(table: testTable, of: TestInfo.self)
        } catch  {
            print(error)
        }
    }
    
    class func getDBSalt() -> String? {
        //get salt from db.
        if let dbURL = URL(string: databasePath()) {
            do {
                let saltLength = 16
                let handle = try FileHandle(forReadingFrom:dbURL)
                let first16Bytes: Data? = try handle.read(upToCount: saltLength)
                try handle.close()
                let salt = first16Bytes?.hexEncodedString()
                if let salt = salt {
                    print("save salt:\(salt) done")
                    save(salt: salt)
                    return salt
                }
            } catch  {
                print(error)
            }
        }
        return nil
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
