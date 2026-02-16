# ReadyCheckAddon

## Overview
ReadyCheckAddon is a simple World of Warcraft addon that enhances the ready check experience by displaying a custom image until the ready check is complete. 

## Installation
1. Download the ReadyCheckAddon folder.
2. Place the folder in your World of Warcraft addons directory, typically located at:
   - `World of Warcraft/_retail_/Interface/AddOns/`
3. Ensure that the folder structure remains intact:
   ```
   ReadyCheckAddon/
   ├── ReadyCheckAddon.toc
   ├── ReadyCheckAddon.lua
   └── media
       └── <some list of media files>
   ```

## Usage
- Once installed, the addon will automatically respond to ready check events in the game.
- When a ready check is initiated, the addon will display a random image until you have responded to the readycheck.

## Features
- Displays a custom image during ready checks.
- Automatically hides the image once the ready check is complete.

## Details
- Displas a 256x256 image, unfortunately the only picture format wow can display is .tga
- Images are converted via ImageMagick
- New images go in /images
- You can run the update_media.sh in order to convert your files to tga

## Support
For any issues or feature requests, please contact the addon developer through the appropriate channels.