//
//  DatabaseManager.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 5.08.2026.
//

import Foundation
import SQLite3

//MARK: - Database Manager Service(SQLite)
/// Manages local SQLite database oprations, tables, user profiles, and exchange rate caching.
/// - Author: Cengizhan Ozyurt
/// - Version: 1.0.0
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
        
        //MARK: - Database Connection & Setup
        
        private func openDatabase(){
            let fileURL = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("SofttechBankDatabase.sqlite")
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error opening database at path: \(fileURL.path)")
            }
            else {
                print("Succesfully opened connection to database at: \(fileURL.path)")
            }
        }
        
        private func createTables() {
            let createUserTableQuery = """
                CREATE TABLE IF NOT EXISTS UserProfile (
                id TEXT PRIMARY KEY,
                name TEXT,
                surname TEXT,
                mail TEXT,
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
                updatedAt Text
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
            
            executeNONQuery(query: createUserTableQuery)
            executeNONQuery(query: createLatestRatesTable)
            executeNONQuery(query: createHistoricalRatesTable)
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
            print("SQL execution failed: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(stmt)
            return false
        }
        
        // MARK: - Authentication & User Operations (Login/Register)
        
        public func registerUser(name: String, surname: String, mail:String, age:Int, passwordHash: String, initialBalance: Double = 10000.0) -> Bool {
            let userId = UUID().uuidString
            let dateString = ISO8601DateFormatter().string(from: Date())
            
            let insertQuery = """
                INSERT INTO UserProfile (id, name, surname, mail, age, passwordHash, balance, defaultBaseCurrency, lastModifiedDate)
                VALUES ('\(userId)', '\(name)', '\(surname)', '\(mail)', \(age), '\(passwordHash)', \(initialBalance), 'TRY', '\(dateString)');
                """
            return executeNONQuery(query: insertQuery)
        }
        

        public func loginUser(mail: String, passwordHash:String) -> (name: String, surname: String, mail: String, balance: Double)? {
            let query = "SELECT name, surname, mail, balance FROM UserProfile WHERE mail = '\(mail)' AND passwordHash = '\(passwordHash)' LIMIT 1;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
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
                let query = "SELECT name, surname, mail, balance FROM UserProfile WHERE mail = ? LIMIT 1;"
                var stmt: OpaquePointer?
                
                if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(stmt, 1, (mail as NSString).utf8String, -1, nil)
                    
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
        public func resetDatabase() {
                let dropUserTable = "DROP TABLE IF EXISTS UserProfile;"
                let dropLatestRates = "DROP TABLE IF EXISTS LatestExchangeRates;"
                let dropHistoricalRates = "DROP TABLE IF EXISTS HistoricalExchangeRates;"
                
                executeNONQuery(query: dropUserTable)
                executeNONQuery(query: dropLatestRates)
                executeNONQuery(query: dropHistoricalRates)
                
                createTables()
                
                UserDefaults.standard.removeObject(forKey: "savedUserEmailForFaceID")
                
                print("Veritabanı ve Face ID ayarları başarıyla sıfırlandı.")
            }
}
