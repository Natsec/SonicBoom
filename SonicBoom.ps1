$inputs = Get-ChildItem inputs/*.mkv
foreach ($filepath in $inputs){
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($filepath)

    $deco = "=" * $filename.length + "="
    Write-Host "$deco`n$filename`n$deco" -ForegroundColor green

    $json_metadata = mkvmerge -J $filepath
    # $json_metadata
    $metadata = $json_metadata | ConvertFrom-Json

    Write-Host "Audio tracks :" -ForegroundColor green
    $metadata.tracks | ForEach-Object{
        if ($_.type -eq "audio"){
            $id = $_.id
            $lang = $_.properties.language
            $track_name = $_.properties.track_name
            Write-Host "$id`:$track_name ($lang)" -ForegroundColor green
        }
    }

    $tracklist = ""
    $metadata.tracks | ForEach-Object{
        if ($_.type -eq "audio"){
            $id = $_.id
            $lang = $_.properties.language
            $track_name = $_.properties.track_name
            $codec = $_.codec

            ""
            # Extracting audio track
            Write-Host "Extracting audio track $id`:$track_name ($lang)" -ForegroundColor green
            mkvextract $filepath tracks ${id}:"tmp/$filename-$id-$lang-$track_name.$codec"
            # Compressing audio track
            Write-Host "Compressing audio track $id`:$track_name ($lang)" -ForegroundColor green
            ffmpeg -hide_banner -y -i "tmp/$filename-$id-$lang-$track_name.$codec" -filter 'compand=0:1:-90/-900|-70/-70|-30/-9|0/-3:6:0:0:0' "tmp/$filename-$id-$lang-$track_name.compressed.mp3"

            # Building tracklist
            $tracklist += "--language 0:$lang --track-name 0:`"Compressed $track_name`" `"tmp/$filename-$id-$lang-$track_name.compressed.mp3`" "
        }
    }

    ""
    # Merging audio tracks to output file
    Write-Host "Merging audio tracks in `"output/Compressed audio - $filename.mkv`"" -ForegroundColor green
    Invoke-Expression "mkvmerge `"$filepath`" $tracklist -o `"output/Compressed audio - $filename.mkv`" --flush-on-close"
    ""
    ""

    # pause
}
