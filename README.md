# SwiftScripts

Set of macOS shell scripts written in Swift. Scripts can help with simple repeptitive tasks mainly in iOS development.

#### tag
```
Tag file or directory with timestamp (YYYY-MM-DDc) based on last modification date

Usage: tag
  -c,--copy:
      Tags copy of the file
```

#### flatten
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

#### removeEmptyDirs
```
Removes empty dirs in directory and its subdirectories

Usage: removeEmptyDirs
  --input <Input directory>:
      Input directory for processing

```

#### sortPhotos
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
