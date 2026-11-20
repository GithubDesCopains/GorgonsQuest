extends RefCounted
class_name SceneLookup

## Single place that knows where the running level lives in the scene tree.

const MAIN_NODE_NAME := "Main"

static func main_scene(from: Node) -> Node:
	"""The root 'Main' node, or null when 'from' is not in the tree (unit tests, freed nodes)."""
	if from == null or not from.is_inside_tree():
		return null
	return from.get_tree().root.get_node_or_null(MAIN_NODE_NAME)

static func effect_parent(from: Node) -> Node:
	"""Where temporary effects are added: Main when running, else the node's own parent."""
	var main := main_scene(from)
	return main if main != null else from.get_parent()
