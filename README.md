# SwiftScripts

Set of macOS shell scripts written in Swift. Scripts can help with simple repeptitive tasks mainly in iOS development.
Please install these free tools for proper use of scripts:
* Image Magick - https://www.imagemagick.org
* EXIFtool - https://www.sno.phy.queensu.ca/~phil/exiftool/

## General Purpose Scripts

### tag
<p align="center">
    <img src="https://i.ibb.co/Mh479Pz/Tag.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Tag file or directory with timestamp (YYYY-MM-DDc) based on last modification date

Usage: tag <params> <file or dir>
  -c,--copy:
      Tags copy of the file
```

-----------------------------------------------------------

### flatten
<p align="center">
    <img src="https://i.ibb.co/LvcH7Zk/Flatten.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Flatten directory structure and make long file names.

Usage: flatten <params>
  -m,--move:
      Move files from source folder
  --input <Input directory>:
      Input directory for processing
  --output <Output directory>:
      Output directory for result
```

-----------------------------------------------------------

### removeEmptyDirs
```
Removes empty dirs in directory and its subdirectories

Usage: removeEmptyDirs <params>
  --input <Input directory>:
      Input directory for processing

```

-----------------------------------------------------------

### sortPhotos
<p align="center">
    <img src="https://i.ibb.co/FwqVskk/sort-Photos.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos <params>
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

Sort photos uses EXIFtool for sorting photos based on date or camera type. Currently different formats have different EXIFtool information - DateTimeOrigina, DateCreated, ContentCreateDate, CreationDate, ... M4V files often contain no EXIF info and script tries to sort those files to folders based on the file name.

-----------------------------------------------------------

### renameEpisodes
<p align="center">
    <img src="https://i.ibb.co/BcbB2nF/Rename-Episodes.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Rename seriers episodes using names from OMDb.

Usage: renameepisodes
  --input <Input directory>:
      Input directory for processing
  --series <Name of series>:
      Try http://www.omdbapi.com first if needed.
  -r,--rename:
      Perform renames of files. Otherwise result is just preview of changes
```

RenameEpisodes script uses free Open Movie Database (OMDb) for obtaining the names of episodes.

## iOS Development

### prepareAppIcon
<p align="center">
    <img src="https://i.ibb.co/MC5MDM6/Prepare-App-Icon.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos <params>
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

### versionIcon
<p align="center">
    <img src="https://i.ibb.co/xzBqYkH/App-Icon60x60-3x.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
VersionIcon prepares iOS icon with ribbon, text and version info

Usage: versionicon
  --ribbon <Icon ribbon color>:
      Icon ribbon color
  --title <Icon ribbon title>:
      Icon ribbon title
  --script <VersionIcon script path>:
      VersionIcon script path
  --iphone:
      Generate iPhone icons
  --ipad:
      Generate iPad icons
 ```


-----------------------------------------------------------

### resize
```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos <params> <files>
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

