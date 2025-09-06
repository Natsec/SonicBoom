$files = Get-ChildItem inputs/*.mkv
foreach ($filepath in $files){
    $filename = [System.IO.Path]::GetFileName($filepath)

    $deco = "=" * $filename.length + "="
    Write-Host "$deco`n$filename`n$deco" -ForegroundColor green

    $json = mkvmerge -J $filepath -v
    # $json
    $json = $json | ConvertFrom-Json
    $json.tracks | ForEach-Object{
        if ($_.type -eq "audio"){
            $id = $_.id
            $type = $_.type
            $lang = $_.properties.language
            $track_name = $_.properties.track_name.replace(':', '')
            # AC-3 to AC3
            $codec = $_.codec.replace('-', '')

            ""
            # Extracting audio track
            Write-Host "Extracting audio track (id:$id lang:$lang name:`"$track_name`")" -ForegroundColor green
            mkvextract $filepath tracks ${id}:"tmp/$id-$lang-$track_name.$codec"
            ""
            # Compressing audio track
            Write-Host "Compressing audio track" -ForegroundColor green
            ffmpeg -hide_banner -y -i "tmp/$id-$lang-$track_name.$codec" -filter 'compand=0:1:-90/-900|-70/-70|-30/-9|0/-3:6:0:0:0' "tmp/$id-$lang-$track_name-compressed.mp3"
            ""
            # Building tracklist
            $tracklist += "--language 0:$lang --track-name 0:`"_$lang-$track_name`" `"tmp/$id-$lang-$track_name-compressed.mp3`" "
        }
    }
    # Adding audio tracks to output file
    Write-Host "Adding audio tracks to output file `"output/_$filename`"" -ForegroundColor green
    Invoke-Expression "mkvmerge `"$filepath`" $tracklist -o `"output/_$filename`" --flush-on-close"
    ""
}

# pause
