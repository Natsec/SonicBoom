# Sonic Boom

Batch audio dynamic range compression for mkv files.

## Pre-requisites

### MKVToolNix

Download and install MKVToolNix from https://mkvtoolnix.org.

### FFmpeg

Download and install FFmpeg from https://ffmpeg.org.

You can get the Windows build directly at https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z. Don't forget to add the `bin` folder to your `Path` environment variable.

An easier way is to install it in a powershell terminal:
```powershell
winget install ffmpeg
```

## Usage

Copy your mkv files in the `inputs` folder.

Then execute the `SonicBoom.ps1` script:
```powershell
powershell SonicBoom.ps1
```

You can also right-click and "Execute with PowerShell".
