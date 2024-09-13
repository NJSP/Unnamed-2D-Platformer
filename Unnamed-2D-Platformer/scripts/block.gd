extends Node2D

@onready var game_manager = %GameManager
@onready var static_body_2d = $StaticBody2D


func remove_block():
		static_body_2d.queue_free()
