class_name GroupProcessHandler extends Handler



# Combined with using Groups, it shall allow toggling of visibility/processing

func toggle_group(group: StringName, active: bool) -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
	
	var process_option: Node.ProcessMode
	if active: process_option = Node.PROCESS_MODE_INHERIT
	else: process_option = Node.PROCESS_MODE_DISABLED
		
	for node in nodes:
		node.visible = active
		node.process_mode = process_option

## Wrapper for multiple group toggling
func toggle_multiple_groups(groups: Array[StringName], active: bool) -> void:
	for each in groups:
		toggle_group(each, active)
