@tool
class_name EditorTools extends Node


## Selecting a child of the owner node or one of its explicitly related nodes counts.
static func is_selected(node: Node, related_nodes: Array[Node] = []) -> bool:
	if not Engine.is_editor_hint() or not node:
		return false
	var selection := EditorInterface.get_selection()
	if not selection:
		return false
	for selected: Node in selection.get_selected_nodes():
		if selected == node or node.is_ancestor_of(selected):
			return true
		for related: Node in related_nodes:
			if is_instance_valid(related) and (
				selected == related or related.is_ancestor_of(selected)
			):
				return true
	return false


static func get_editor_zoom() -> float:
	if not Engine.is_editor_hint():
		return 1.0
	var viewport := EditorInterface.get_editor_viewport_2d()
	if not viewport:
		return 1.0
	var viewport_scale := viewport.global_canvas_transform.get_scale()
	return minf(absf(viewport_scale.x), absf(viewport_scale.y))
