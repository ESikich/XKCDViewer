class XkcdViewer {
	[string] $ColorBorder = "White"
	[string] $ColorTitle = "Cyan"
	[string] $ColorURL = "Blue"
	[string] $ColorTranscript = "Green"
	[string] $ColorAltText = "Yellow"
	[string] $ColorScene = "DarkGray"
	[string] $ColorDefault = "White"
	[hashtable] $SpeakerColors = @{}
	[string[]] $Palette = @(
    	"Magenta", "Cyan", "Green", "Yellow", "Blue",
    	"DarkYellow", "DarkCyan", "DarkMagenta", "DarkGreen"
	)
	[int] $TextWidth = 76  # 1 space pad + 76 + 1 right = 78 + 2 borders = 80
	[int] $BoxWidth
	[string] $TopBorder
	[string] $BottomBorder
	[string] $Divider

	XkcdViewer() {
    	$this.BoxWidth 	= $this.TextWidth + 1
    	$this.TopBorder	= "╔" + ("═" * $this.BoxWidth) + "╗"
    	$this.BottomBorder = "╚" + ("═" * $this.BoxWidth) + "╝"
    	$this.Divider  	= "╠" + ("═" * $this.BoxWidth) + "╣"
	}

	[string[]] WrapText([string] $text) {
    	return $this.WrapTextWithPrefix($text, 0)
	}

	[string[]] WrapTextWithPrefix([string] $text, [int] $prefixLen) {
    	$out = @(); $line = ""
    	$max = $this.TextWidth - 3
    	$firstMax = $max - $prefixLen
    	$isFirst = $true

    	foreach ($word in ($text -split '\s+')) {
        	[int] $limit = 0
        	if ($isFirst) {
            	$limit = $firstMax
        	} else {
            	$limit = $max
        	}

        	if (($line.Length + $word.Length + 1) -le $limit) {
            	$line = if ($line) { "$line $word" } else { $word }
        	} else {
            	$out += $line
            	$line = $word
            	$isFirst = $false
        	}
    	}
    	if ($line) { $out += $line }
    	return $out
	}

	[void] FormatLine([string] $content) {
    	$this.FormatLine($content, $this.ColorDefault)
	}

	[void] FormatLine([string] $content, [ConsoleColor] $color) {
    	$text = $content.Substring(0, [Math]::Min($content.Length, $this.TextWidth)).PadRight($this.TextWidth)
    	Write-Host "║" -NoNewline -ForegroundColor $this.ColorBorder
    	Write-Host " $text" -NoNewline -ForegroundColor $color
    	Write-Host "║" -ForegroundColor $this.ColorBorder
	}

	[string] GetColor([string] $name) {
    	if (-not $this.SpeakerColors.ContainsKey($name)) {
        	$this.SpeakerColors[$name] = $this.Palette[$this.SpeakerColors.Count % $this.Palette.Count]
    	}
    	return $this.SpeakerColors[$name]
	}

	[void] ShowComic() {
    	try {
        	[int]	$num	= 0
        	[object] $comic  = $null
        	[object] $latest = Invoke-RestMethod "https://xkcd.com/info.0.json"

        	do {
            	$num = Get-Random -Minimum 1 -Maximum ($latest.num + 1)
        	} while ($num -eq 404)

        	$comic = Invoke-RestMethod "https://xkcd.com/$num/info.0.json?nocache=$(New-Guid)"
        	$title = "XKCD #$($comic.num): $($comic.title)"
        	$url = "https://xkcd.com/$($comic.num)"
        	$altWrap = $this.WrapText($comic.alt)

        	$transcriptLines = @()
        	if ($comic.transcript) {
            	$lines = $comic.transcript -replace '\\n', "`n" -split "`n"
            	foreach ($line in $lines) {
                	$clean = $line.Trim() -replace ' +', ' '
                	if (
                    	$clean -and
                    	(-not ($clean -like '{*Title text:*')) -and
                    	(-not ($clean -imatch '^\{\{\s*alt\s*:.*\}\}$'))
                	) {
                    	$transcriptLines += $clean
                	}
            	}
        	}

        	Write-Host ""
        	Write-Host $this.TopBorder -ForegroundColor $this.ColorBorder
        	$this.FormatLine($title.PadLeft(([math]::Floor(($this.TextWidth + $title.Length) / 2))), $this.ColorTitle)
        	$this.FormatLine($url.PadLeft(([math]::Floor(($this.TextWidth + $url.Length) / 2))), $this.ColorURL)
        	Write-Host $this.Divider -ForegroundColor $this.ColorBorder

        	$this.FormatLine("Transcript:", $this.ColorTranscript)
        	$this.FormatLine("")

        	if ($transcriptLines.Count -gt 0) {
            	$currentSpeaker = $null
            	foreach ($raw in $transcriptLines) {
                	$line = $raw `
                    	-replace '[\u200B-\u200F\uFEFF]', '' `
                    	-replace '\*', '`*' `
                    	-replace '^\[\[(.*)\]\]$', '[$1]'

                	if (
                    	$line -match '^(?<spk>[^:]+):\s*(?<txt>.*)' -and
                    	($line -notmatch '^\s*[\[\{\(].*:\s*.*[\]\}\)]\s*$')
                	) {
                    	$name = $matches.spk.Trim()
                    	$label = "${name}:"
                    	$text = $matches.txt
                    	$color = $this.GetColor($name)
                    	$wrapped = $this.WrapTextWithPrefix("$label $text", 2)
                    	$first = $true
                    	foreach ($w in $wrapped) {
                        	if ($first) {
                            	$this.FormatLine("→ $w", $color)
                            	$first = $false
                        	} else {
                            	$this.FormatLine("  $w", $color)
                        	}
                    	}
                    	$currentSpeaker = $name
                	} elseif ($line -match '^\[.*\]$') {
                    	$currentSpeaker = $null
                    	foreach ($scene in $this.WrapText("• $line")) {
                        	$this.FormatLine($scene, $this.ColorScene)
                    	}
                	} elseif ($currentSpeaker) {
                    	$color = $this.GetColor($currentSpeaker)
                    	foreach ($sub in $this.WrapText("  $line")) {
                        	$this.FormatLine($sub, $color)
                    	}
                	} else {
                    	foreach ($line2 in $this.WrapText("  $line")) {
                        	$this.FormatLine($line2)
                    	}
                	}
            	}
        	} else {
            	$this.FormatLine("(No transcript available)", $this.ColorScene)
        	}

        	$this.FormatLine("")
        	Write-Host $this.Divider -ForegroundColor $this.ColorBorder

        	$this.FormatLine("Alt Text:", $this.ColorAltText)
        	foreach ($line in $altWrap) {
            	$this.FormatLine("  $line", $this.ColorAltText)
        	}

        	Write-Host $this.BottomBorder -ForegroundColor $this.ColorBorder
        	Write-Host ""
    	} catch {
        	Write-Error "Error retrieving XKCD comic: $_"
    	}
	}
}

# Launch viewer
$xkcd = [XkcdViewer]::new()
$xkcd.ShowComic()
