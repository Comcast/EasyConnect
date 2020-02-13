/**
*  @file  TextLog.swift
*  @brief Logs file to store for all logs which is handled the in the app.
*/

import Foundation

struct TextLog: TextOutputStream {

    /**
    * @brief  Logs file creation and write actions.
    * @param String Appends the given string to the stream
    */
    mutating func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        
        let log = documentDirectoryPath.appendingPathComponent("log.txt")
        
        GlobalData.sharedManager.archiveUrl = log

        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /**
    * @brief Read the logs from log.txt file
    * @param String Return the result as string array.
    */
    func readTextLog() -> [String] {
        let namesTogether = try! String(contentsOf: GlobalData.sharedManager.archiveUrl!, encoding: .utf8)
        let namesPool = namesTogether.components(separatedBy: "\n")
        return namesPool
    }
    
    /**
    * @brief Remove the logs from the file.
    */
    func removeAllLogs() {
        let text = ""
        do {
            try text.write(to: GlobalData.sharedManager.archiveUrl!, atomically: false, encoding: .utf8)
           } catch {
             print(error)
           }
     }
}
