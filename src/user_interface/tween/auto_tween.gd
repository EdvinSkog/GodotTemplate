class_name AutoTween extends RefCounted

## Starts tweens keyed by node and name.

const _META := &"_auto_tweens"


static func to(
	node: Node,
	property: NodePath,
	value: Variant,
	duration: float,
	transition := Tween.TRANS_QUAD,
	ease_type := Tween.EASE_OUT,
	delay := 0.0,
) -> Tween:
	var tween := start(node, str(property), transition, ease_type)
	tween.tween_property(node, property, value, duration).set_delay(delay)
	return tween


static func method(
	node: Node,
	key: String,
	callable: Callable,
	from: Variant,
	to_value: Variant,
	duration: float,
	transition := Tween.TRANS_QUAD,
	ease_type := Tween.EASE_OUT,
	delay := 0.0,
) -> Tween:
	var tween := start(node, key, transition, ease_type)
	tween.tween_method(callable, from, to_value, duration).set_delay(delay)
	return tween


## Kills the tween registered under key and returns a fresh, registered tween
## for callers that need several sequential steps.
static func start(
	node: Node,
	key: String,
	transition := Tween.TRANS_QUAD,
	ease_type := Tween.EASE_OUT,
) -> Tween:
	kill(node, key)
	var tween := node.create_tween().set_trans(transition).set_ease(ease_type)
	tween.set_ignore_time_scale(true)
	var tweens: Dictionary = node.get_meta(_META, {})
	tweens[key] = tween
	node.set_meta(_META, tweens)
	return tween


static func kill(node: Node, key: String) -> void:
	if not node.has_meta(_META):
		return
	var tweens: Dictionary = node.get_meta(_META)
	var previous: Tween = tweens.get(key)
	if previous and previous.is_valid():
		previous.kill()
	tweens.erase(key)
