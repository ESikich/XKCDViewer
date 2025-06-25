# XKCD Comic Viewer (PowerShell)

A PowerShell-based terminal viewer for XKCD comics that fetches a random comic (excluding #404), formats its title, URL, transcript, and alt text, and displays it in a colorful, bordered layout.

## Features

- Fetches a random XKCD comic using the XKCD API.
- Displays comic title, URL, transcript, and alt text in a styled box.
- Color-coded speaker lines in the transcript.
- Handles multi-line wrapping and formatting.
- Skips comic #404 (intentionally missing).
- Assigns consistent colors to speakers using a rotating palette.

## Requirements

- PowerShell 5.1 or later
- Internet connection (to fetch XKCD data)

## Usage
1. Save the script as `XkcdViewer.ps1`.
2. Run the script in PowerShell:

```powershell
.\XkcdViewer.ps1
```

The script will display a randomly selected XKCD comic in a styled terminal output.

## Example Output

```
╔═════════════════════════════════════════════════════════════════════════════════╗
║                          XKCD #1234: Comic Title Here                           ║
║                          https://xkcd.com/1234                                  ║
╠═════════════════════════════════════════════════════════════════════════════════╣
║ Transcript:                                                                     ║
║                                                                                 ║
║ → Alice: This is a line from the transcript.                                    ║
║ → Bob: Another speaker joins the conversation.                                  ║
║ • [Scene description or action]                                                 ║
╠═════════════════════════════════════════════════════════════════════════════════╣
║ Alt Text:                                                                       ║
║   This is the alt text of the comic.                                            ║
╚═════════════════════════════════════════════════════════════════════════════════╝
```

## Customization

You can customize the colors used in the output by modifying the following properties in the `XkcdViewer` class:

- `$ColorBorder`
- `$ColorTitle`
- `$ColorURL`
- `$ColorTranscript`
- `$ColorAltText`
- `$ColorScene`
- `$Palette` (used for speaker colors)

## License

This script is provided as-is under the MIT License. XKCD comics are © Randall Munroe and available at https://xkcd.com.

## Acknowledgments
- XKCD for the comics and public API.
