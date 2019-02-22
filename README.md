# SwiftScripts

Set of macOS shell scripts written in Swift. Scripts can help with simple repeptitive tasks mainly in iOS development.

## General Purpose Scripts

### $ tag README.md
<p align="center">
    <img src="https://i.ibb.co/Mh479Pz/Tag.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Tag file or directory with timestamp (YYYY-MM-DDc) based on last modification date

Usage: tag
  -c,--copy:
      Tags copy of the file
```

-----------------------------------------------------------

### $ flatten -m --input ~/Dir1 --output ~/Dir2
<p align="center">
    <img src="https://i.ibb.co/LvcH7Zk/Flatten.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Flatten directory structure and make long file names.

Usage: flatten
  -m,--move:
      Move files from source folder
  --input <Input directory>:
      Input directory for processing
  --output <Output directory>:
      Output directory for result
```

-----------------------------------------------------------

### $ removeEmptyDirs --input ~/Dir
```
Removes empty dirs in directory and its subdirectories

Usage: removeEmptyDirs
  --input <Input directory>:
      Input directory for processing

```

-----------------------------------------------------------

### sortPhotos
```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

-----------------------------------------------------------

### renameEpisodes
<p align="center">
    <img src="https://i.ibb.co/BcbB2nF/Rename-Episodes.png" width="480" max-width="90%" alt="Marathon" />
</p>

## iOS Development

### prepareAppIcon
<p align="center">
    <img src="https://i.ibb.co/MC5MDM6/Prepare-App-Icon.png" width="480" max-width="90%" alt="Marathon" />
</p>

```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

-----------------------------------------------------------

### resize
```
Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.

Usage: sortPhotos
  -n,--noexif:
      Do not use exiftool. Just organize files to existing folders.
  -c,--camera:
      Sort by camera model
  -m,--m4v:
      Sort M4V by name
  --input <Input directory>:
      Input directory for processing
```

## Practise the Music Instrument
