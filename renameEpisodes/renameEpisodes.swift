import Foundation
import Files
import Moderator
import ScriptToolkit
import Alamofire


//
//  String+Substrings.swift
//  Brix
//
//  Created by Dan Cech on 08.11.2018.
//  Copyright © 2018 STRV. All rights reserved.
//

import Foundation

extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound ..< value.upperBound]
    }
}

// MARK: - Subscripts

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        return self[index(at: value.lowerBound) ... index(at: value.upperBound)]
    }

    subscript(value: CountableRange<Int>) -> Substring {
        return self[index(at: value.lowerBound) ..< index(at: value.upperBound)]
    }

    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        return self[..<index(at: value.upperBound)]
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        return self[...index(at: value.upperBound)]
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        return self[index(at: value.lowerBound)...]
    }

    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}

// MARK: - Safe subscripts

extension String {
    subscript(safe value: CountableClosedRange<Int>) -> Substring {
        let lowerBound = max(value.lowerBound, 0)
        let upperBound = min(value.upperBound, max(count - 1, 0))
        return self[index(at: lowerBound) ... index(at: upperBound)]
    }

    subscript(safe value: CountableRange<Int>) -> Substring {
        let lowerBound = max(value.lowerBound, 0)
        let upperBound = min(value.upperBound, max(count, 0))
        return self[index(at: lowerBound) ..< index(at: upperBound)]
    }

    subscript(safe value: PartialRangeUpTo<Int>) -> Substring {
        let upperBound = min(value.upperBound, max(count, 0))
        return self[..<index(at: upperBound)]
    }

    subscript(safe value: PartialRangeThrough<Int>) -> Substring {
        let upperBound: Int
        if value.upperBound >= 0 {
            upperBound = min(value.upperBound, max(count - 1, 0))
        }
        else {
            upperBound = max(0, count - 1 + value.upperBound)
        }

        return self[...index(at: upperBound)]
    }

    subscript(safe value: PartialRangeFrom<Int>) -> Substring {
        let lowerBound = max(value.lowerBound, 0)
        return self[index(at: lowerBound)...]
    }
}


struct Series: Decodable {
    var episodes: [Episode]
    var season: String
    var title: String
    var totalSeasons: String

    enum CodingKeys: String, CodingKey {
        case episodes = "Episodes"
        case season = "Season"
        case title = "Title"
        case totalSeasons
    }

    init(episodes: [Episode], season: String, title: String, totalSeasons: String) {
        self.episodes = episodes
        self.season = season
        self.title = title
        self.totalSeasons = totalSeasons
    }
}

struct Episode: Decodable {
    var episode: String
    var title: String

    enum CodingKeys: String, CodingKey {
        case episode = "Episode"
        case title = "Title"
    }

    init(episode: String, title: String) {
        self.episode = episode
        self.title = title
    }
}

func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

var seriesInfo: Series!

extension File {
    func renameEpisode(series: String?, episode: String?) -> Bool {
        guard
            let unwrappedSeries = series,
            let seriesInt = Int(unwrappedSeries),
            let unwrappedEpisode = episode,
            let episodeInt = Int(unwrappedEpisode)
            else { return false }

//        guard episodeInt <= seriesInfo.totalSeasons else { return false }
        let episodeName = seriesInfo.episodes[episodeInt].title
        print("rename: \(name) -> S\(seriesInt)E\(episodeInt) \(episodeName).\(self.extension ?? "")")

        return true
    }
}

func performRenames(inputDir: String) throws {
    let inputFolder = try Folder(path: inputDir)

    for file in inputFolder.files {
        print("\(file.name):")
        let fileName = file.nameExcludingExtension

        if let descriptor = matches(for: "[sS]\\d\\d[eE]\\d\\d", in: fileName).first {
            let seriesNumber = String(descriptor[1...2])
            let episodeNumber = String(descriptor[4...5])
            if file.renameEpisode(series: seriesNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d\\d", in: fileName).first {
            let seriesNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...4])
            if file.renameEpisode(series: seriesNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d", in: fileName).first {
            let seriesNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...3])
            if file.renameEpisode(series: seriesNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "\\d\\d[xX]\\d\\d", in: fileName).first {
            let seriesNumber = String(descriptor[0...1])
            let episodeNumber = String(descriptor[3...4])
            if file.renameEpisode(series: seriesNumber, episode: episodeNumber) {
                continue
            }
        }

        print("  Unable to rename file")
    }
}


let moderator = Moderator(description: "Rename seriers episodes using names from OMDb. Script will ask for confirmation.")

let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

let name = moderator.add(Argument<String?>
    .optionWithValue("series", name: "Name of series", description: "Try http://www.omdbapi.com first if needed."))

do {
    try moderator.parse(["--input", "/Volumes/HAL9000/[Movies]/[Altered Carbon]", "--series", "Altered Carbon"])
    guard let unwrappedInputDir = inputDir.value, let unwrappedName = name.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    let seriesName = unwrappedName.replacingOccurrences(of: " ", with: "+")
    let url = "http://www.omdbapi.com/?apikey=d1b21f08&type=series&t=\(seriesName)&Season=1"


    Alamofire.request(url).response { response in
        if let data = response.data {
            seriesInfo = try! JSONDecoder().decode(Series.self, from: data)
            try! performRenames(inputDir: unwrappedInputDir)
        }
    }

    RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

    print("✅ Done")
}
catch let error as ArgumentError {
    print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    print("renameEpisodes failed: \(error.localizedDescription)")
    exit(1)
}
