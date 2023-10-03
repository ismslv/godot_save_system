extends Node

var ball_data = {}
var ball_types = ["basketball", "football", "volleyball", "tennis", "golf"]

func _ready():
	ball_data["basketball"] = BallData.new()
	ball_data["basketball"].texture = load("res://images/basketball.png")
	ball_data["basketball"].size = 0.5
	
	ball_data["football"] = BallData.new()
	ball_data["football"].texture = load("res://images/football.png")
	ball_data["football"].size = 0.3
	
	ball_data["volleyball"] = BallData.new()
	ball_data["volleyball"].texture = load("res://images/volleyball.png")
	ball_data["volleyball"].size = 0.25
	
	ball_data["tennis"] = BallData.new()
	ball_data["tennis"].texture = load("res://images/tennis.png")
	ball_data["tennis"].size = 0.2
	
	ball_data["golf"] = BallData.new()
	ball_data["golf"].texture = load("res://images/golf.jpg")
	ball_data["golf"].size = 0.2
