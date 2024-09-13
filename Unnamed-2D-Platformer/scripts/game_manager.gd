extends Node

var score = 0

@onready var score_label = $ScoreLabel
@onready var block = $"../block"



func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."
	if score > 7:
		block.remove_block()
