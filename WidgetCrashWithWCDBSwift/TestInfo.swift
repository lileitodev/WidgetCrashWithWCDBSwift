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
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                uuid: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
}

class TestManager: NSObject {
    let testTable = "testTable"
    static var manager = TestManager()
    var database: Database? = nil
    override init() {
        super.init()
        let dbPath = databasePath()
        database = Database(withPath: dbPath)
        if let pwdData = "$b)PGhvRtpjnQDqc".data(using: .utf8)  {
            database?.setConfig(named: "demo", with: { (handle: Handle) throws in
                try handle.exec(StatementPragma().pragma(Pragma(named: "cipher_plaintext_header_size"), to: 32))
            }, orderBy: 0)
            database?.setCipher(key: pwdData)
        }
        print(dbPath)
        do {
            try database?.create(table: testTable, of: TestInfo.self)
        } catch  {
            print(error)
        }
    }
    
    func databasePath() -> String {
        let pathPrefix = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ai.daypop.imdev")?.path)!
        return NSString(string: pathPrefix + "/DataBase/Test").appendingPathExtension("sqlite")!
    }
    
    func saveInfo(info: TestInfo) {
        do {
            try database?.insertOrReplace(objects: info, intoTable: testTable)
        } catch  {
            print(error)
        }
    }
    
}
