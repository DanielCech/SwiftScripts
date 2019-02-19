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


struct Season: Decodable {
    var episodes: [Episode]
    var season: Int
    var title: String
    var totalSeasons: Int

    enum CodingKeys: String, CodingKey {
        case episodes = "Episodes"
        case season = "Season"
        case title = "Title"
        case totalSeasons
    }

    init(episodes: [Episode], season: Int, title: String, totalSeasons: Int) {
        self.episodes = episodes
        self.season = season
        self.title = title
        self.totalSeasons = totalSeasons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let episodes: [Episode] = try container.decode([Episode].self, forKey: .episodes)
        let season: Int = Int(try container.decode(String.self, forKey: .season)) ?? 0
        let title: String = try container.decode(String.self, forKey: .title)
        let totalSeasons: Int = Int(try container.decode(String.self, forKey: .totalSeasons)) ?? 0

        self.init(episodes: episodes, season: season, title: title, totalSeasons: totalSeasons)
    }
}

struct Episode: Decodable {
    var episode: Int
    var title: String

    enum CodingKeys: String, CodingKey {
        case episode = "Episode"
        case title = "Title"
    }

    init(episode: Int, title: String) {
        self.episode = episode
        self.title = title
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let episode: Int = Int(try container.decode(String.self, forKey: .episode)) ?? 0
        let title: String = try container.decode(String.self, forKey: .title)
        self.init(episode: episode, title: title)
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

var seriesInfo = [Int: Season]()

extension File {
    func renameEpisode(season: String?, episode: String?) -> Bool {
        guard
            let unwrappedSeason = season,
            let seasonInt = Int(unwrappedSeason),
            let unwrappedEpisode = episode,
            let episodeInt = Int(unwrappedEpisode)
            else { return false }

        guard seasonInt <= seriesInfo.keys.count else { return false }
        guard let season = seriesInfo[seasonInt] else { return false }
        guard episodeInt <= season.episodes.count else { return false }

        let episodeName = season.episodes[episodeInt - 1].title
        let newName = String(format: "S%02dE%02d %@.%@", seasonInt, episodeInt, episodeName, self.extension ?? "")
        print("  -> \(newName)")
        return true
    }
}

func performRenames(inputDir: String) throws {
    let inputFolder = try Folder(path: inputDir)

    for file in inputFolder.files {
        print("\(file.name):")
        let fileName = file.nameExcludingExtension

        if let descriptor = matches(for: "[sS]\\d\\d[eE]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...2])
            let episodeNumber = String(descriptor[4...5])
            if file.renameEpisode(season: seasonNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...4])
            if file.renameEpisode(season: seasonNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...3])
            if file.renameEpisode(season: seasonNumber, episode: episodeNumber) {
                continue
            }
        }

        if let descriptor = matches(for: "\\d\\d[xX]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[0...1])
            let episodeNumber = String(descriptor[3...4])
            if file.renameEpisode(season: seasonNumber, episode: episodeNumber) {
                continue
            }
        }

        print("  Unable to rename file")
    }
}

func renameSeries(name seriesName: String, season: Int, inputDir: String) {
    print("🔦 Downloading info about season \(season)")

    let url = "http://www.omdbapi.com/?apikey=d1b21f08&type=series&t=\(seriesName)&Season=\(season)"

    Alamofire.request(url).response { response in
        if let data = response.data {
            let seasonInfo = try! JSONDecoder().decode(Season.self, from: data)

            seriesInfo[season] = seasonInfo
            try? performRenames(inputDir: inputDir)

            if season < seasonInfo.totalSeasons {
                renameSeries(name: seriesName, season: season + 1, inputDir: inputDir)
            }
        }
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

    renameSeries(name: seriesName, season: 1, inputDir: unwrappedInputDir)

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
