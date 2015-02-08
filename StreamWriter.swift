import Foundation

public class StreamWriter{
    let encoding:UInt!
    var fileHandle:NSFileHandle!
    let delimData:NSData!
    
    init?(path:String, delimiter:String="\n", encoding:UInt=NSUTF8StringEncoding){
        self.encoding = encoding
        
        //file handle
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path){
            fileManager.createFileAtPath(path,contents:nil,attributes:nil)
        }
        if let fileHandle = NSFileHandle(forWritingAtPath:path){
            self.fileHandle = fileHandle
        }else{
            return nil
        }
        
        //delimiter
        if let delimData = delimiter.dataUsingEncoding(encoding){
            self.delimData = delimData
        }else{
            return nil
        }
    }
    
    deinit{
        self.close()
    }
    
    public func println(data:String)->Bool{
        if let nsData = data.dataUsingEncoding(encoding){
            fileHandle.writeData(nsData)
            fileHandle.writeData(delimData)
            return true
        }
        return false
    }
    public func print(data:String)->Bool{
        if let nsData = data.dataUsingEncoding(encoding){
            fileHandle.writeData(nsData)
            return true
        }
        return false
    }
    
    public func close(){
        if fileHandle != nil{
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
}