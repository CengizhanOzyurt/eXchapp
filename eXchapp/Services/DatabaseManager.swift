//
//  DatabaseManager.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 5.08.2026.
//

import Foundation
import SQLite3

public final class DatabaseManager {
    public static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private init () {
        openDatabase()
        createTables()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - Database Connection & Setup
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("SofttechBank_v3.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database at path: \(fileURL.path)")
        } else {
            print("Succesfully opened connection to database at: \(fileURL.path)")
        }
    }
    
    private func createTables() {
        let createUserTableQuery = """
            CREATE TABLE IF NOT EXISTS UserProfile (
            id TEXT PRIMARY KEY,
            name TEXT,
            surname TEXT,
            mail TEXT COLLATE NOCASE,
            age INTEGER,
            passwordHash TEXT,
            balance REAL,
            defaultBaseCurrency TEXT,
            lastModifiedDate TEXT
            );
            """
        
        let createLatestRatesTable = """
            CREATE TABLE IF NOT EXISTS LatestExchangeRates (
            currencyCode TEXT PRIMARY KEY,
            rateValue REAL,
            updatedAt TEXT
            );
            """
        
        let createHistoricalRatesTable = """
            CREATE TABLE IF NOT EXISTS HistoricalExchangeRates (
            id TEXT PRIMARY KEY,
            rateDate TEXT,
            rateValue REAL,
            archivedAt TEXT
            );
            """
        
        let createHoldingsTable = """
            CREATE TABLE IF NOT EXISTS UserHoldings (
            mail TEXT COLLATE NOCASE,
            currencyCode TEXT,
            amount REAL,
            PRIMARY KEY (mail, currencyCode)
            );
            """
        
        executeNONQuery(query: createUserTableQuery)
        executeNONQuery(query: createLatestRatesTable)
        executeNONQuery(query: createHistoricalRatesTable)
        executeNONQuery(query: createHoldingsTable)
    }
    
    @discardableResult
    private func executeNONQuery(query: String) -> Bool {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                return true
            }
        }
        print("SQL execution failed: \(String(cString: sqlite3_errmsg(db))) | Query: \(query)")
        sqlite3_finalize(stmt)
        return false
    }
    
    // MARK: - Authentication & User Operations
        public func registerUser(name: String, surname: String, mail: String, age: Int, passwordHash: String, initialBalance: Double = 17500.0) -> Bool {
            let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let userId = UUID().uuidString
            let dateString = ISO8601DateFormatter().string(from: Date())
            
            let query = """
                INSERT INTO UserProfile (id, name, surname, mail, age, passwordHash, balance, defaultBaseCurrency, lastModifiedDate)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
            
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (userId as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 3, (surname as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 4, (cleanMail as NSString).utf8String, -1, nil)
                sqlite3_bind_int(stmt, 5, Int32(age))
                sqlite3_bind_text(stmt, 6, (passwordHash as NSString).utf8String, -1, nil)
                sqlite3_bind_double(stmt, 7, initialBalance)
                sqlite3_bind_text(stmt, 8, ("TRY" as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 9, (dateString as NSString).utf8String, -1, nil)
                
                if sqlite3_step(stmt) == SQLITE_DONE {
                    sqlite3_finalize(stmt)
                    return true
                } else {
                    let errorMsg = String(cString: sqlite3_errmsg(db))
                    print("HATA: Kullanıcı SQLite'a kaydedilemedi - \(errorMsg)")
                }
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(db))
                print("HATA: Kayıt sorgusu hazırlanamadı - \(errorMsg)")
            }
            
            sqlite3_finalize(stmt)
            return false
        }
    
    public func loginUser(mail: String, passwordHash: String) -> (name: String, surname: String, mail: String, balance: Double)? {
        let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let query = "SELECT name, surname, mail, balance FROM UserProfile WHERE mail = ? AND passwordHash = ? LIMIT 1;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (cleanMail as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (passwordHash as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(stmt, 0))
                let surname = String(cString: sqlite3_column_text(stmt, 1))
                let retrievedMail = String(cString: sqlite3_column_text(stmt, 2))
                let balance = sqlite3_column_double(stmt, 3)
                sqlite3_finalize(stmt)
                return (name, surname, retrievedMail, balance)
            }
        }
        sqlite3_finalize(stmt)
        return nil
    }

    public func getUser(byEmail mail: String) -> (name: String, surname: String, mail: String, balance: Double)? {
        let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let query = "SELECT name, surname, mail, balance FROM UserProfile WHERE mail = ? LIMIT 1;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (cleanMail as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(stmt, 0))
                let surname = String(cString: sqlite3_column_text(stmt, 1))
                let retrievedMail = String(cString: sqlite3_column_text(stmt, 2))
                let balance = sqlite3_column_double(stmt, 3)
                sqlite3_finalize(stmt)
                return (name, surname, retrievedMail, balance)
            }
        }
        sqlite3_finalize(stmt)
        return nil
    }

    // MARK: - Balance & Holdings Operations

    public func updateUserBalance(mail: String, newBalance: Double) {
        let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let query = "UPDATE UserProfile SET balance = ? WHERE mail = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_double(stmt, 1, newBalance)
            sqlite3_bind_text(stmt, 2, (cleanMail as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("HATA: Bakiye güncellenemedi!")
            }
        } else {
            print("HATA: Bakiye güncelleme sorgusu hazırlanamadı!")
        }
        sqlite3_finalize(stmt)
    }

    public func updateUserHolding(mail: String, currencyCode: String, amount: Double) {
        let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let query = "INSERT OR REPLACE INTO UserHoldings (mail, currencyCode, amount) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (cleanMail as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (currencyCode as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 3, amount)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("HATA: \(currencyCode) veritabanına kaydedilemedi!")
            }
        }
        sqlite3_finalize(stmt)
    }

    public func getUserHoldings(mail: String) -> [String: Double] {
        let cleanMail = mail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var holdings: [String: Double] = [:]
        let query = "SELECT currencyCode, amount FROM UserHoldings WHERE mail = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (cleanMail as NSString).utf8String, -1, nil)
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let cString = sqlite3_column_text(stmt, 0) {
                    let currencyCode = String(cString: cString)
                    let amount = sqlite3_column_double(stmt, 1)
                    if amount > 0 {
                        holdings[currencyCode] = amount
                    }
                }
            }
        }
        sqlite3_finalize(stmt)
        return holdings
    }
}
