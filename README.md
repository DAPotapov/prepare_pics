# prepare_pics

This script prepare images (change size and place watermark)
to be published on currated Wordpress site.
It accepts folder name(s)(or * for all folders in current folder) to be processed recursevly.
File with watermark should be in same directory as this script.

## Known issues

If given several arguments and at least one of them contains whitespaces,
may not proceed others if they contain '/' character
