# SwiftScripts

Set of macOS shell scripts written in Swift. Scripts can help with simple repetitive tasks mainly in iOS development.

## General Purpose Scripts

### tag
<p align="center">
    <img src="https://i.ibb.co/Mh479Pz/Tag.png" width="480" max-width="90%" alt="Marathon" />
</p>

Tag file or directory with timestamp (YYYY-MM-DDc) based on last modification date

```
Usage: tag <params> <file or dir>
  -c,--copy:
      Tags copy of the file
```
Install with `brew install DanielCech/scripts/tag`

-----------------------------------------------------------

### flatten
<p align="center">
    <img src="https://i.ibb.co/LvcH7Zk/Flatten.png" width="480" max-width="90%" alt="Marathon" />
</p>

Flatten directory structure and make long file names.

```
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

Removes empty dirs in directory and its subdirectories

```
Usage: removeEmptyDirs <params>
  --input <Input directory>:
      Input directory for processing

```

-----------------------------------------------------------

### sortPhotos
<p align="center">
    <img src="https://i.ibb.co/FwqVskk/sort-Photos.png" width="480" max-width="90%" alt="Marathon" />
</p>

Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata. Please install utility EXIFtool first. https://www.sno.phy.queensu.ca/~phil/exiftool/

```
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

Install with `brew install DanielCech/scripts/sortphotos`

-----------------------------------------------------------

### renameEpisodes
<p align="center">
    <img src="https://i.ibb.co/BcbB2nF/Rename-Episodes.png" width="480" max-width="90%" alt="Marathon" />
</p>

Rename seriers episodes using names from OMDb.

```
Usage: renameepisodes
  --input <Input directory>:
      Input directory for processing
  --series <Name of series>:
      Try http://www.omdbapi.com first if needed.
  -r,--rename:
      Perform renames of files. Otherwise result is just preview of changes
```

RenameEpisodes script uses free Open Movie Database (OMDb) for obtaining the names of episodes.

Install with `brew install DanielCech/scripts/renameepisodes`

-----------------------------------------------------------

### invoke

Invoke is shell command which is very handy when you need to call some shell script on set of files. It will call the shell script separately for each file. When you call `install.sh`, it will copy the binary to _/usr/local/bin_ and it creates empty script _invoke.sh_ in home folder and make it executable. The script _invoke.sh_ is used for sequence of generated shell calls. The set of files can be easily dragged from Finder or Forklift to the shell.

```
Usage: invoke <params>
  --action <Shell action to run>:
      Use @file@ - original file,
      @absoluteFile@ - file with absolute path
      @absoluteFileNoExt@ - file with absolute path without extension
      @localFile@ - file without path
      @localFileNoExt@ - file without path and extension
      @ext@ - the extension of file
  --file <File with parameter values on each line;
      You can specify files as normal parameters>:
¨
```

*Examples:*

Conversion of audio file do .wav

`$ invoke --action "/usr/local/bin/ffmpeg -i \"@absolutePath@\" \"@absolutePathNoExt@.wav\"" <files>`

Adding 4s of silence at the beginning of selected audio files

`$ invoke --action "ffmpeg -i \"@absolutePath@\" -af \"adelay=4000|4000\" \"@absolutePathNoExt@.out.wav\"" <files>`

Install with `brew install DanielCech/scripts/invoke`

## iOS Development

### prepareAppIcon
<p align="center">
    <img src="https://i.ibb.co/MC5MDM6/Prepare-App-Icon.png" width="480" max-width="90%" alt="Marathon" />
</p>

prepareAppIcon - Prepare all required resolutions of iOS app icon

```
Usage prepareIcon --input <file>
```

-----------------------------------------------------------

### resize

Resize image to particular size in @1x, @2x and @2x

```
Usage: resize <params> <files>
  --size <Size of image in in WIDTHxHEIGHT format>:
      Resulting size in selected resolution
  --output <Output directory>:
      Output directory for generated images Default = './output'.
  -i,--interactive:
      Interactive mode. Script will ask about missing important parameters
```

-----------------------------------------------------------

### colorPalette

Shows hexa codes of colors in Xcode palette. Input dir (or one of its subdirectories) should contain `.xcassets` folder and `App Colors` subfolder with Xcode palette colors. 

```
Usage: colorPalette <params>
  --input <Input directory>:
      Input directory for processing
  -h,--sortByHexa:
      Sort colors by hexa code
```

Output sorted by name:
```
  background:
    #FFFFFF (light)
    #000000 (dark)
  baseBackground:
    #F9F7F4 (light)
  borderGray:
    #000000 (light)
  brigthGreen:
    #008B6D (light)
  dashboardBackground:
    #F9F7F4 (light)
  ...
```

Output sorted by color:
```
  #000000:
    background (dark)
    borderGray (light)
  #008B6D:
    brigthGreen (light)
  #1B1F2B:
    harborBlack (light)
  #28514F:
    greenBackground (light)
  #2F91FF:
    tint (light)
  #333333:
    text (light)
```

Install with `brew install DanielCech/scripts/colorpalette`

## Setup with Forklift
* Script works perfectly with Forklift file manager - https://binarynights.com.
* Open Commands > Manage Tools...
<p align="center">
    <img src="https://i.ibb.co/qBqMkfD/Sn-mek-obrazovky-2019-03-05-v-10-21-38.png" width="480" max-width="90%" alt="Marathon" />
</p>

* FlattenDirs: `/usr/local/bin/flatten --input "$SOURCE_PATH" --output "$TARGET_PATH"`
* Directorize: `/usr/local/bin/directorize --move --output $TARGET_PATH $SOURCE_SELECTION_NAMES`
* SortPhotosByDate: `/usr/local/bin/sortphotos --input "$SOURCE_PATH"`
* SortPhotosByCamera: `/usr/local/bin/sortphotos --input "$SOURCE_PATH" --camera`
* ReduceVideo: `/usr/local/bin/reducevideo --output "$TARGET_PATH" $SOURCE_SELECTION_PATHS`


* Script resize uses a little bit more complicated setup. It uses iTerm2 terminal because it needs also additional parameters in interactive mode. It uses shell_helper.sh and shell_command.sh simple subsidiary scripts.
* Resize: `/Users/dan/Documents/[Development]/[Projects]/SwiftScripts/shell_helper.sh  /usr/local/bin/resize --interactive --output $TARGET_PATH $SOURCE_SELECTION_PATHS`




