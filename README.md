# Elevate

Elevate in this game you operate an elevator to move people to their destinations. If you can bring people in time to their destinations (or just a bit late) it will improve the building economy which on midnight will contribute to the building growing taller.

Taller building with more offices gives you more people to transport. As you go, you also will gain tech coins which can be used to upgrade the elevator so you can support the growing demands.

## Play the game

[Play in browser](https://elevate.slinga.nu/app/)

or

```
flutter run -d web
```

## Flame Game Jam 2026 (March)

This game was written as part of the Flame Game Jam 2026.

## Code & AI

99% Human made code, written during the game jam period. The only AI-written code is in lib/utils/sky_color.dart still with some human tweaks. AI was consulted for some issues but more like using it as a search engine than writing code directly.

## Assets

All assets was made by me during the game jam period specifically for this game.

* Images was created in Inkscape.
* Audio was created using a MIDI keyboard and Ableton to record short clips. In lib/models/music_composer.dart there is then logic for the weights used to pick next clip to play which depends on various factors, including which level the elevator currently is located at. There is also a lib/models/audio_effects.dart file that plays audio when the elevator starts moving.
  - I don't have any source files for the audio clips as it was just recorded, exported and then deleted the midi track to re-use the recording slot in the program. I still a beginner in this as of writing this and maybe should have saved those, I don't know.
