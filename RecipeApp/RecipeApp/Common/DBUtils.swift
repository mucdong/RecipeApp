//
//  DBUtils.swift
//  RecipeApp
//
//  Created by Nguyen D on 3/7/20.
//  Copyright © 2020 Nguyen D. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

class DBUtils: NSObject {
    static var shared = DBUtils()
    
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    let DATABASE_NAME = "RecipeDB.sqlite"
    
    func databasePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return (paths[0] as NSString).appendingPathComponent(DATABASE_NAME)
    }
    
    func initDBInfo() {
        let fileManager = FileManager.default
        let dbPath = databasePath()
        if !fileManager.fileExists(atPath: dbPath) {
            //non-exists DB file
            let resourcePath = (Bundle.main.resourcePath! as NSString).appendingPathComponent(DATABASE_NAME)
            do {
                try fileManager.copyItem(atPath: resourcePath, toPath: dbPath)
                let url = NSURL(fileURLWithPath: dbPath)
                try url.setResourceValue(NSNumber.init(value: true), forKey: .isExcludedFromBackupKey)
            } catch {
                #if DEBUG
                    print("Copy DB file resource error")
                #endif
            }
        }
        
        let userDefault = UserDefaults.standard
        if userDefault.value(forKey: "RecipeApp_DB") == nil {
            userDefault.set("1", forKey: "RecipeApp_DB")
            userDefault.synchronize()
        }
    }
    
    func openDatabase() -> OpaquePointer? {
        let dbPath = databasePath()
        var db: OpaquePointer? = nil
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            #if DEBUG
                print("Successfully opened connection to database at \(dbPath)")
            #endif
            return db
        } else {
            #if DEBUG
                print("Unable to open database. Verify that you created the directory described " +
                    "in the Getting Started section.")
            #endif
            return nil
        }
    }
    
    func loadRecipe(id: Int) -> Recipe? {
        let query = "SELECT title, photo, content, type FROM Recipe WHERE id = ?"
        var statement: OpaquePointer?
        let db = openDatabase()
        
        if db == nil {
            return nil
        }
        
        var recipe : Recipe?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, (Int32)(id))
            if sqlite3_step(statement) == SQLITE_ROW {
                recipe = Recipe()
                recipe?.id = id
                
                var s = sqlite3_column_text(statement, 0)
                if s != nil {
                    recipe?.title = String(cString: s!)
                }
                
                s = sqlite3_column_text(statement, 1)
                if s != nil {
                    recipe?.photo = String(cString: s!)
                }
                
                s = sqlite3_column_text(statement, 2)
                if s != nil {
                    recipe?.content = String(cString: s!)
                }
                
                recipe?.type = Int(sqlite3_column_int(statement, 3))
                
            } else {
                print("Query returned no results")
            }
            sqlite3_finalize(statement)
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_close(db)
        
        return recipe
    }
    
    func saveRecipe(_ recipe : Recipe) {
        let db = openDatabase()
        if db == nil {
            return
        }
        
        var statement: OpaquePointer?
        
        if recipe.id == 0 {
            // Add new
            let query = "INSERT INTO Recipe(\"title\",\"photo\",\"content\",\"type\")  VALUES(?,?,?,?)"
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                var s = recipe.title as NSString
                sqlite3_bind_text(statement, 1, s.utf8String, -1, SQLITE_TRANSIENT)
                
                s = recipe.photo as NSString
                sqlite3_bind_text(statement, 2, s.utf8String, -1, SQLITE_TRANSIENT)
                
                s = recipe.content as NSString
                sqlite3_bind_text(statement, 3, s.utf8String, -1, SQLITE_TRANSIENT)
                
                sqlite3_bind_int(statement, 4, (Int32)(recipe.type))
                
                sqlite3_step(statement)
                sqlite3_finalize(statement)
            }
        } else {
            // Update
            let query = "UPDATE Recipe SET \"title\" = ?, \"photo\" = ?, \"content\" = ? WHERE id = ?"
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                var s = recipe.title as NSString
                sqlite3_bind_text(statement, 1, s.utf8String, -1, SQLITE_TRANSIENT)
                
                s = recipe.photo as NSString
                sqlite3_bind_text(statement, 2, s.utf8String, -1, SQLITE_TRANSIENT)
                
                s = recipe.content as NSString
                sqlite3_bind_text(statement, 3, s.utf8String, -1, SQLITE_TRANSIENT)
                
                sqlite3_bind_int(statement, 4, (Int32)(recipe.id))
                
                sqlite3_step(statement)
                sqlite3_finalize(statement)
            }
        }
        
        sqlite3_close(db)
    }
    
    func loadListRecipe(byType type: Int) -> [Recipe] {
        var list = [Recipe]()
        let query = "SELECT * FROM Recipe WHERE type = ? ORDER BY title ASC"
        var statement: OpaquePointer?
        let db = openDatabase()
        if db == nil {
            return list
        }
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, (Int32)(type))
            while sqlite3_step(statement) == SQLITE_ROW {
                let recipe = Recipe()
                recipe.id = Int(sqlite3_column_int(statement, 0))
                
                var s = sqlite3_column_text(statement, 1)
                if s != nil {
                    recipe.title = String(cString: s!)
                }
                
                s = sqlite3_column_text(statement, 2)
                if s != nil {
                    recipe.photo = String(cString: s!)
                }
                
                s = sqlite3_column_text(statement, 3)
                if s != nil {
                    recipe.content = String(cString: s!)
                }
                
                recipe.type = type
                
                list.append(recipe)
            }
            
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return list
    }
    
    func deleteRecipe(id : Int) {
        let query = "DELETE FROM Recipe WHERE id = ?"
        var statement: OpaquePointer?
        let db = openDatabase()
        if db == nil {
            return
        }
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, (Int32)(id))
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
    }
}
