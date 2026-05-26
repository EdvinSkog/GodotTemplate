extends Node

# Global player-related stuff

## Reference to Player node
var fpc: FirstPersonController
var toppc: TopDownController
var snapview: Snapview

## Use this when toggling back to a "default" mouse mode the player is in.
var mouse_mode: Input.MouseMode = Input.MouseMode.MOUSE_MODE_VISIBLE
