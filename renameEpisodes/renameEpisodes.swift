import Foundation
import Files
import Moderator
import ScriptToolkit
import Alamofire


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

extension File {
    func renameEpisode(season: String?, episode: String?, renameFiles: Bool) throws -> Bool {
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

        if renameFiles {
            try rename(to: newName)
        }

        return true
    }
}

func performRenames(inputDir: String, renameFiles: Bool) throws {
    let inputFolder = try Folder(path: inputDir)

    for file in inputFolder.files {
        print("\(file.name):")
        let fileName = file.nameExcludingExtension

        if let descriptor = matches(for: "[sS]\\d\\d[eE]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...2])
            let episodeNumber = String(descriptor[4...5])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...4])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        if let descriptor = matches(for: "[sS]\\d[eE]\\d", in: fileName).first {
            let seasonNumber = String(descriptor[1...1])
            let episodeNumber = String(descriptor[3...3])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        if let descriptor = matches(for: "\\d\\d[xX]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[0...1])
            let episodeNumber = String(descriptor[3...4])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        if let descriptor = matches(for: "\\d[xX]\\d\\d", in: fileName).first {
            let seasonNumber = String(descriptor[0...0])
            let episodeNumber = String(descriptor[2...3])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        if let descriptor = matches(for: "\\d[xX]\\d", in: fileName).first {
            let seasonNumber = String(descriptor[0...0])
            let episodeNumber = String(descriptor[2...2])
            if try file.renameEpisode(season: seasonNumber, episode: episodeNumber, renameFiles: renameFiles) {
                continue
            }
        }

        print("  Unable to rename file")
    }
}

func renameSeries(name seriesName: String, season: Int, inputDir: String, renameFiles: Bool) {
    print("🔦 Downloading info about season \(season)")

    let url = "http://www.omdbapi.com/?apikey=d1b21f08&type=series&t=\(seriesName)&Season=\(season)"

    Alamofire.request(url).response { response in
        if let data = response.data {
            let seasonInfo = try! JSONDecoder().decode(Season.self, from: data)

            seriesInfo[season] = seasonInfo
            try? performRenames(inputDir: inputDir, renameFiles: renameFiles)

            if season < seasonInfo.totalSeasons {
                renameSeries(name: seriesName, season: season + 1, inputDir: inputDir, renameFiles: renameFiles)
            }
            else {
                print("✅ Done")
                exit(0)
            }
        }
    }
}

var seriesInfo = [Int: Season]()

let moderator = Moderator(description: "Rename seriers episodes using names from OMDb.")
moderator.usageFormText = "renameseries <params> <files>"

let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

let name = moderator.add(Argument<String?>
    .optionWithValue("series", name: "Name of series", description: "Try http://www.omdbapi.com first if needed."))

let rename = moderator.add(.option("r","rename", description: "Perform renames of files. Otherwise result is just preview of changes"))

do {
    try moderator.parse()
    guard let unwrappedInputDir = inputDir.value, let unwrappedName = name.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    let seriesName = unwrappedName.replacingOccurrences(of: " ", with: "+")

    renameSeries(name: seriesName, season: 1, inputDir: unwrappedInputDir, renameFiles: rename.value)

    RunLoop.main.run(until: Date(timeIntervalSinceNow: 20))

    print("✅ Done")
}
catch {
    print(error.localizedDescription)
    exit(Int32(error._code))
}
