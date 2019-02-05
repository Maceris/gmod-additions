# gmod-additions
Some new features for TTT in gmod

##  Spawn inventory

Pressing 'i' ingame opens up an inventory that allows the player to 
spawn in any weapon they want that the game can detect, replacing the 
current weapon in that slot if one exists.

You can close by pressing 'i' again or clicking the close button.

---

##  Text Effects

Based on https://github.com/moatato/moat-texteffects

[An example video of the effects can be found here.](https://i.imgur.com/E4rDn3h.mp4)

---
## __Text Effects Included:__
* Dollars bouncing around over text
* Bubble effect over text
* Colored smoke around text
* Rainstorm under text
* Realistic fire under text

You can also type in console "m_textexamples" to display of the effects in game.

---
## __Functions Available:__  

### __Dollar Text__
* _intensity_ = number above 0, how many dollar signs to draw
```lua
DrawSwagText(intensity, text, font, x, y, color, color2, _obj_)
```

### __Bubble Text__
* _intensity_ = number between 0 and 1. Higher means faster movement
* _bubble_color_ = Color of the bubbles (Default is light blue)
```lua
DrawBubbleText(intensity, text, font, x, y, color, bubble_color, _obj_)
``` 


### __Smoke Text__
* _intensity_ = number between 0 and 1. Higher means more smoke
* _smoke_color_ = Color of the smoke (Default is grey)
```lua
DrawSmokeText(intensity, text, font, x, y, color, smoke_color, _obj_)
```


### __Rain Text__
```lua
DrawRainText(text, font, x, y, color, _obj_)
```


### __Inferno Text__
* _intensity_ = number between 0 and 1 (0.5 is half of the text height)
```lua
DrawBonfireText(intensity, text, font, x, y, color, _obj_)
```
