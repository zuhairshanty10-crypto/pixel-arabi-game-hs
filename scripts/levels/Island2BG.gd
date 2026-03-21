extends ParallaxBackground

## Adds subtle automatic motion to the northern lights and fog layers

var time: float = 0.0

func _process(delta):
	time += delta
	
	# Gently sway northern lights layers
	var nl1 = $L2_NorthernLights1
	var nl2 = $L5_NorthernLights2
	var fog = $L3_Fog
	
	nl1.motion_offset.x = sin(time * 0.15) * 30.0
	nl2.motion_offset.x = cos(time * 0.1) * 25.0
	fog.motion_offset.x = sin(time * 0.08) * 15.0
	
	# Slight star twinkle via subtle vertical shift
	$L4_Stars.motion_offset.y = sin(time * 0.2) * 3.0
