//
//  FileEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on on 31.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxLog

/// Describes a set of data and functions that represent a file entity.
public protocol FileEntity: Entity {
    associatedtype InfoItem: FileInfoEntity

    var id: String { get }
    var info: InfoItem { get }
    var data: Data { get set }
    
    init(id: String, info: InfoItem, data: Data)
}

public protocol FileInfoEntity: Entity {
    associatedtype PathItem: FilePathEntity
    
    var id: String { get }
    var ext: FileExtension { get }
    var name: String { get set }
    var type: FileType { get set }
    var path: PathItem { get set }
    var uid: String { get set }
    
    init(id: String, ext: FileExtension, name: String)
}

extension FileInfoEntity {
    public init(id: String,
                ext: FileExtension,
                name: String,
                path: PathItem,
                uid: String) {
        self.init(id: id, ext: ext, name: name)
        self.name = name
        self.type = ext.type
        self.path = path
        self.uid = uid
    }
}

extension FileEntity {
    public var description: String {
        var details = Log().add("{").nextLine
        Mirror(reflecting: self).children.forEach { child in
            let label = child.label ?? ""
            if let data = child.value as? Data {
                let info = String(describing: data)
                details = details.tab.add(label).colon.add("\(info)").nextLine
            } else {
                details = details.tab.add(label).colon.add("\(child.value)").nextLine
            }
        }
        details = details.add("}")
        return details.value
    }
}

public protocol FilePathEntity: Codable, Hashable {
    var remote: String { get set }
    var local: String { get set }
    init()
}

extension FilePathEntity {
    public init(remote: String = "", local: String = "") {
        self.init()
        self.remote = remote
        self.local = local
    }
}

public enum FileType: String, Codable, Hashable {
    case audio
    case video
    case image
    case file
}

public enum FileExtension: String, Codable, Hashable {

   public var type: FileType {
        switch self {
        // Videos
        case .mp4, .mov, .avi, .mkv, .wmv, .flv, .mpg, .mpeg, .webm, .m4v, .vob,
                .ts, .threeGP, .ogv, .mts, .f4v, .rm, .rmvb, .divx, .asf, .ogg,
                .m2ts, .mxf, .swf, .amv, .drc, .mng, .srt, .gif:
            return .video
        // Audios
        case .mp3, .wav, .aac, .flac, .m4a, .wma, .amr, .aiff, .alac, .opus,
                .au, .pcm, .dsd, .mp2, .m3u, .ra, .mid, .ac3, .eac3, .caf,
                .mp1, .mpa, .m4p, .mpc, .oga, .mp4a:
            return .audio
        // Files
        case .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .csv,
                .xml, .json, .html, .htm, .zip, .rar, .gz, .tar, .dmg, .exe,
                .apk, .iso, .deb, .rpm, .bin, .jar, .app, .bat, .sh, .cmd, .hprof:
            return .file
        // Images
        case .jpeg, .jpg, .png, .bmp, .tiff, .webp, .svg, .ico, .heic, .heif:
            return .image
        
        }
    }
    
    //MARK: Videos cases
    case mp4
    case mov
    case avi
    case mkv
    case wmv
    case flv
    case mpg
    case mpeg
    case webm
    case m4v
    case vob
    case ts
    case threeGP = "3gp"
    case ogv
    case mts
    case f4v
    case rm
    case rmvb
    case divx
    case asf
    case ogg
    case m2ts
    case mxf
    case swf
    case amv
    case drc
    case mng
    case srt
    
    //MARK: Audios cases
    case mp3
    case wav
    case aac
    case flac
    case m4a
    case wma
    case amr
    case aiff
    case alac
    case opus
    case au
    case pcm
    case dsd
    case mp2
    case m3u
    case ra
    case mid
    case ac3
    case eac3
    case caf
    case mp1
    case mpa
    case m4p
    case mpc
    case oga
    case mp4a
    
    //MARK: Files cases
    case pdf
    case doc
    case docx
    case xls
    case xlsx
    case ppt
    case pptx
    case txt
    case rtf
    case csv
    case xml
    case json
    case html
    case htm
    case zip
    case rar
    case gz
    case tar
    case dmg
    case exe
    case apk
    case iso
    case deb
    case rpm
    case bin
    case jar
    case app
    case bat
    case sh
    case cmd
    case hprof
    
    //MARK: Images cases
    case jpeg
    case jpg
    case png
    case gif
    case bmp
    case tiff
    case webp
    case svg
    case ico
    case heic
    case heif
    
    public var mimeType: String {
        switch self {
            //MARK: Videos mimeType
        case .mp4:
            return "video/mp4"
        case .mov:
            return "video/quicktime"
        case .avi:
            return "video/x-msvideo"
        case .mkv:
            return "video/x-matroska"
        case .wmv:
            return "video/x-ms-wmv"
        case .flv:
            return "video/x-flv"
        case .mpg, .mpeg:
            return "video/mpeg"
        case .webm:
            return "video/webm"
        case .m4v:
            return "video/x-m4v"
        case .vob:
            return "video/dvd"
        case .ts:
            return "video/mp2t"
        case .threeGP:
            return "video/3gpp"
        case .ogv:
            return "video/ogg"
        case .mts:
            return "video/mp2t"
        case .f4v:
            return "video/x-f4v"
        case .rm:
            return "application/vnd.rn-realmedia"
        case .rmvb:
            return "application/vnd.rn-realmedia-vbr"
        case .divx:
            return "video/divx"
        case .asf:
            return "video/x-ms-asf"
        case .ogg:
            return "audio/ogg"
        case .m2ts:
            return "video/mp2t"
        case .mxf:
            return "application/mxf"
        case .swf:
            return "application/x-shockwave-flash"
        case .amv:
            return "video/amv"
        case .drc:
            return "application/drc"
        case .mng:
            return "video/x-mng"
        case .srt:
            return "application/x-subrip"
            
            //MARK: Audios mimeType
        case .mp3:
            return "audio/mpeg"
        case .wav:
            return "audio/wav"
        case .aac:
            return "audio/aac"
        case .flac:
            return "audio/flac"
        case .m4a:
            return "audio/mp4"
        case .wma:
            return "audio/x-ms-wma"
        case .amr:
            return "audio/amr"
        case .aiff:
            return "audio/aiff"
        case .alac:
            return "audio/alac"
        case .opus:
            return "audio/opus"
        case .au:
            return "audio/basic"
        case .pcm:
            return "audio/L16"
        case .dsd:
            return "audio/dsd"
        case .mp2:
            return "audio/mpeg"
        case .m3u:
            return "audio/x-mpegurl"
        case .ra:
            return "audio/x-pn-realaudio"
        case .mid:
            return "audio/midi"
        case .ac3:
            return "audio/ac3"
        case .eac3:
            return "audio/eac3"
        case .caf:
            return "audio/x-caf"
        case .mp1:
            return "audio/mpeg"
        case .mpa:
            return "audio/mpeg"
        case .m4p:
            return "audio/mp4"
        case .mpc:
            return "audio/x-musepack"
        case .oga:
            return "audio/ogg"
        case .mp4a:
            return "audio/mp4a"
            
            //MARK: Files mimeType
        case .pdf:
            return "application/pdf"
        case .doc:
            return "application/msword"
        case .docx:
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .xls:
            return "application/vnd.ms-excel"
        case .xlsx:
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .ppt:
            return "application/vnd.ms-powerpoint"
        case .pptx:
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .txt:
            return "text/plain"
        case .rtf:
            return "application/rtf"
        case .csv:
            return "text/csv"
        case .xml:
            return "application/xml"
        case .json:
            return "application/json"
        case .html, .htm:
            return "text/html"
        case .zip:
            return "application/zip"
        case .rar:
            return "application/x-rar-compressed"
        case .gz:
            return "application/gzip"
        case .tar:
            return "application/x-tar"
        case .dmg:
            return "application/x-apple-diskimage"
        case .exe:
            return "application/x-msdownload"
        case .apk:
            return "application/vnd.android.package-archive"
        case .iso:
            return "application/x-iso9660-image"
        case .deb:
            return "application/vnd.debian.binary-package"
        case .rpm:
            return "application/x-rpm"
        case .bin:
            return "application/octet-stream"
        case .jar:
            return "application/java-archive"
        case .app:
            return "application/octet-stream"
        case .bat:
            return "application/x-bat"
        case .sh:
            return "application/x-sh"
        case .cmd:
            return "application/x-msdos-program"
        case .hprof:
            return "application/vnd.java.hprof.text"
            
            //MARK: Images mimeType
        case .jpeg, .jpg:
            return "image/jpeg"
        case .png:
            return "image/png"
        case .gif:
            return "image/gif"
        case .bmp:
            return "image/bmp"
        case .tiff:
            return "image/tiff"
        case .webp:
            return "image/webp"
        case .svg:
            return "image/svg+xml"
        case .ico:
            return "image/vnd.microsoft.icon"
        case .heic:
            return "image/heic"
        case .heif:
            return "image/heif"
            
        }
    }
    
    public init(mimeType: String) {
        switch mimeType.lowercased() {
            //MARK: Videos init mimeType
        case "video/mp4":
            self = .mp4
        case "video/quicktime":
            self = .mov
        case "video/x-msvideo":
            self = .avi
        case "video/x-matroska":
            self = .mkv
        case "video/x-ms-wmv":
            self = .wmv
        case "video/x-flv":
            self = .flv
        case "video/mpeg":
            self = .mpg
        case "video/webm":
            self = .webm
        case "video/x-m4v":
            self = .m4v
        case "video/dvd":
            self = .vob
        case "video/mp2t":
            self = .ts
        case "video/3gpp":
            self = .threeGP
        case "video/ogg":
            self = .ogv
        case "video/x-f4v":
            self = .f4v
        case "application/vnd.rn-realmedia":
            self = .rm
        case "application/vnd.rn-realmedia-vbr":
            self = .rmvb
        case "video/divx":
            self = .divx
        case "video/x-ms-asf":
            self = .asf
        case "audio/ogg":
            self = .ogg
        case "application/mxf":
            self = .mxf
        case "application/x-shockwave-flash":
            self = .swf
        case "video/amv":
            self = .amv
        case "application/drc":
            self = .drc
        case "video/x-mng":
            self = .mng
        case "application/x-subrip":
            self = .srt
            
            //MARK: Audios init mimeType
        case "audio/mpeg", "audio/mp3":
            self = .mp3
        case "audio/wav":
            self = .wav
        case "audio/aac":
            self = .aac
        case "audio/flac":
            self = .flac
        case "audio/mp4", "audio/m4a":
            self = .m4a
        case "audio/x-ms-wma":
            self = .wma
        case "audio/amr":
            self = .amr
        case "audio/aiff":
            self = .aiff
        case "audio/alac":
            self = .alac
        case "audio/opus":
            self = .opus
        case "audio/basic", "audio/au":
            self = .au
        case "audio/L16", "audio/pcm":
            self = .pcm
        case "audio/dsd":
            self = .dsd
        case "audio/x-mpegurl", "audio/m3u":
            self = .m3u
        case "audio/x-pn-realaudio":
            self = .ra
        case "audio/midi", "audio/mid":
            self = .mid
        case "audio/ac3":
            self = .ac3
        case "audio/eac3":
            self = .eac3
        case "audio/x-caf", "audio/caf":
            self = .caf
        case "audio/mp1", "audio/mpa":
            self = .mp1
        case "audio/m4p":
            self = .m4p
        case "audio/x-musepack", "audio/mpc":
            self = .mpc
        case "audio/oga":
            self = .oga
            
            //MARK: Files init mimeType
        case "application/pdf":
            self = .pdf
        case "application/msword":
            self = .doc
        case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            self = .docx
        case "application/vnd.ms-excel":
            self = .xls
        case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
            self = .xlsx
        case "application/vnd.ms-powerpoint":
            self = .ppt
        case "application/vnd.openxmlformats-officedocument.presentationml.presentation":
            self = .pptx
        case "text/plain":
            self = .txt
        case "application/rtf":
            self = .rtf
        case "text/csv":
            self = .csv
        case "application/xml":
            self = .xml
        case "application/json":
            self = .json
        case "text/html":
            self = .html
        case "application/zip":
            self = .zip
        case "application/x-rar-compressed":
            self = .rar
        case "application/gzip":
            self = .gz
        case "application/x-tar":
            self = .tar
        case "application/x-apple-diskimage":
            self = .dmg
        case "application/x-msdownload":
            self = .exe
        case "application/vnd.android.package-archive":
            self = .apk
        case "application/x-iso9660-image":
            self = .iso
        case "application/vnd.debian.binary-package":
            self = .deb
        case "application/x-rpm":
            self = .rpm
        case "application/octet-stream":
            self = .bin
        case "application/java-archive":
            self = .jar
        case "application/x-app":
            self = .app
        case "application/x-bat":
            self = .bat
        case "application/x-sh":
            self = .sh
        case "application/x-msdos-program":
            self = .cmd
            
            //MARK: Images init mimeType
        case "image/jpeg":
            self = .jpeg
        case "image/png":
            self = .png
        case "image/gif":
            self = .gif
        case "image/bmp":
            self = .bmp
        case "image/tiff":
            self = .tiff
        case "image/webp":
            self = .webp
        case "image/svg+xml":
            self = .svg
        case "image/vnd.microsoft.icon":
            self = .ico
        case "image/heic":
            self = .heic
        case "image/heif":
            self = .heif
            
        default:
            do {
                let info = "Warning. Content type \(mimeType) is absent"
                throw RepositoryException.incorrectData(info)
            } catch { prettyLog(error)  }
            
            self = .json
        }
    }
}
