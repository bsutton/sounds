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

import Flutter
import Foundation

class Track: NSObject {
    var path: String?
    var title: String?
    var artist: String?
    var albumArtUrl: String?
    var albumArtAsset: String?
    var albumArtFile: String?
    var dataBuffer: FlutterStandardTypedData?

    convenience init(fromJson jsonString: String?) {
        let jsonData = jsonString?.data(using: .utf8)

        var error: Error? = nil
        var responseObj: [AnyHashable : Any]? = nil
        do {
            if let jsonData = jsonData {
                responseObj = try JSONSerialization.jsonObject(
                    with: jsonData,
                    options: []) as? [AnyHashable : Any]
            }
        } catch {
        }

        if error == nil {
            let pathString = responseObj?["path"] as? String
            path = pathString

            let titleString = responseObj?["title"] as? String
            title = titleString

            let artistString = responseObj?["artist"] as? String
            artist = artistString

            let albumArtUrlString = responseObj?["albumArtUrl"] as? String
            albumArtUrl = albumArtUrlString

            let albumArtAssetString = responseObj?["albumArtAsset"] as? String
            albumArtAsset = albumArtAssetString

            let albumArtFileString = responseObj?["albumArtFile"] as? String
            albumArtFile = albumArtFileString


            let dataBufferJson = responseObj?["dataBuffer"] as? FlutterStandardTypedData
            dataBuffer = dataBufferJson
        } else {
            print("Error in parsing JSON")
            return nil
        }
    }

    convenience init(fromDictionary jsonData: [AnyHashable : Any]?) {
        let pathString = jsonData?["path"] as? String
        path = pathString

        let titleString = jsonData?["title"] as? String
        title = titleString

        let artistString = jsonData?["artist"] as? String
        artist = artistString

        let albumArtUrlString = jsonData?["albumArtUrl"] as? String
        albumArtUrl = albumArtUrlString

        let albumArtAssetString = jsonData?["albumArtAsset"] as? String
        albumArtAsset = albumArtAssetString

        let albumArtFileString = jsonData?["albumArtFile"] as? String
        albumArtFile = albumArtFileString


        let dataBufferJson = jsonData?["dataBuffer"] as? FlutterStandardTypedData
        dataBuffer = dataBufferJson
    }

    // Returns true if the audio file is stored as a path represented by a string, false if
    // it is stored as a buffer.
    func isUsingPath() -> Bool {
        return NSString.self != NSNull.self
    }
}