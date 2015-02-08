//http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swiftにあったやつ

import Foundation

public class StreamReader{
    let encoding:UInt
    let chunkSize:Int
    var fileHandle:NSFileHandle!
    let buffer:NSMutableData!
    let delimData:NSData!
    var atEof:Bool = false

    init?(path:String, delimiter:String = "\n", encoding:UInt = NSUTF8StringEncoding, chunkSize:Int = 4096){
        self.chunkSize = chunkSize
        self.encoding = encoding

        //ファイルハンドルを取得
        if let fileHandle = NSFileHandle(forReadingAtPath:path){
            self.fileHandle = fileHandle
        }else{
            return nil
        }
        
        //デリミタを取得
        if let delimData = delimiter.dataUsingEncoding(NSUTF8StringEncoding){
            self.delimData = delimData
        }else{
            return nil
        }
        
        //chunkSizeバイト格納できるNSMutableData(NSDataの可変長版)を取得
        if let buffer = NSMutableData(capacity:chunkSize){
            self.buffer = buffer
        }else{
            return nil
        }
    }

    deinit{
        self.close()
    }

    //EOFに達したらnilを返す
    func nextLine()->String?{
        if atEof{
            return nil
        }

        //NSRangeを取得(対象：デリミタ、0からbufferの長さ)
        var range = buffer.rangeOfData(delimData,options:nil,range:NSMakeRange(0,buffer.length))
        //構造体rangeのlocationがNSNotFound、つまりデリミタが発見されるまでやる
        while range.location == NSNotFound {
            //最大chunkSizeバイトのデータを読み込む
            var tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0{
                //何も取得できなかったとき(EOFかエラー)
                atEof = true
                if buffer.length > 0{
                    //バッファがデータを持ってる→空にしてりたーん
                    let line = NSString(data:buffer,encoding:encoding);
                    buffer.length = 0
                    return line
                }
                //おしまい。
                return nil
            }
            buffer.appendData(tmpData)
            //もういちどNSRangeを取得そしてループ
            range = buffer.rangeOfData(delimData,options:nil,range:NSMakeRange(0,buffer.length))
        }

        //NSRangeのながさぶん取得
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
            encoding: encoding)
        //取得したらもういらないので消す
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)

        //取得したやつ返す
        return line
    }

    //ファイルの最初から
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }

    //ファイルクローズ
    func close() -> Void {
        if fileHandle != nil {
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
}

extension StreamReader : SequenceType {
    public func generate() -> GeneratorOf<String> {
        return GeneratorOf<String> {
            return self.nextLine()
        }
    }
}