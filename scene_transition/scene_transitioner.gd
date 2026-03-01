extends Control

# SceneTransitioner handles scene changes and all involved
# - scene loading
# - porthole zoom in/out
# - music fade in/out
# - etc

func _ready() -> void:
	$TransitionAnimation.current_animation = "scene_enter"
