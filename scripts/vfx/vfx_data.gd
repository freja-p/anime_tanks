class_name VFXData
extends Resource

@export var radius : float = 4
@export var duration : float = 0.4

@export var vfx_scene : PackedScene

func build() -> VFX:
	var vfx : VFX = vfx_scene.instantiate() as VFX
	vfx.vfx_data = self
	return vfx
	
