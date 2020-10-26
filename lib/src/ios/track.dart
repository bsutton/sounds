//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
/*
 * This file is part of Sounds .
 *
 *   Sounds  is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds  is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds .  If not, see <https://www.gnu.org/licenses/>.
 */


import 'dart:core';

import 'package:dart_native/dart_native.dart';

class Track extends NSObject {
     String path;
    var title: String?
    var artist: String?
    var albumArtUrl: String?
    var albumArtAsset: String?
    var albumArtFile: String?
    var dataBuffer: FlutterStandardTypedData?

    init(path: String?, title: String?, artist: String?, albumArtUrl: String?, albumArtAsset: String? ,albumArtFile: String?,dataBuffer: FlutterStandardTypedData?){
        self.path = path
        self.title = title
        self.artist = artist
        self.albumArtUrl = albumArtUrl
        self.albumArtAsset = albumArtAsset
        self.albumArtFile = albumArtFile
        self.dataBuffer = dataBuffer
        
    }
    
    convenience init?(fromJson jsonString: String?) {
        let jsonData = jsonString?.data(using: .utf8)

        var responseObj: [AnyHashable : Any]? = nil
        do {
            if let jsonData = jsonData {
                responseObj = try JSONSerialization.jsonObject(
                    with: jsonData,
                    options: []) as? [AnyHashable : Any]
            }
        }
        catch{
            print("Error in parsing JSON of Track")
            return nil
        }
        
                 // let args = responseObj as! Dictionary<String, Any>
               //   assert(init)
                  let pathString = responseObj?["path"] as? String
                  let titleString = responseObj?["title"] as? String
                  let artistString = responseObj?["artist"] as? String
                  let albumArtUrlString = responseObj?["albumArtUrl"] as? String
                  let albumArtAssetString = responseObj?["albumArtAsset"] as? String
                  let albumArtFileString = responseObj?["albumArtFile"] as? String
                  let dataBufferJson = responseObj?["dataBuffer"] as? FlutterStandardTypedData
        
        self.init(path: pathString, title: titleString, artist: artistString, albumArtUrl: albumArtUrlString, albumArtAsset: albumArtAssetString, albumArtFile: albumArtFileString, dataBuffer: dataBufferJson)
        
    }

    convenience init(fromDictionary jsonData: [AnyHashable : Any]?) {
        let pathString = jsonData?["path"] as? String
        let titleString = jsonData?["title"] as? String
        let artistString = jsonData?["artist"] as? String
        let albumArtUrlString = jsonData?["albumArtUrl"] as? String
        let albumArtAssetString = jsonData?["albumArtAsset"] as? String
        let albumArtFileString = jsonData?["albumArtFile"] as? String
        let dataBufferJson = jsonData?["dataBuffer"] as? FlutterStandardTypedData
        
         self.init(path: pathString, title: titleString, artist: artistString, albumArtUrl: albumArtUrlString, albumArtAsset: albumArtAssetString, albumArtFile: albumArtFileString, dataBuffer: dataBufferJson)    }

    // Returns true if the audio file is stored as a path represented by a string, false if
    // it is stored as a buffer.
    func isUsingPath() -> Bool {
        return NSString.self != NSNull.self
    }
}
