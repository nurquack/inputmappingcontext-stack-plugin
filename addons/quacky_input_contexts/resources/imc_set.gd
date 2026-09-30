@tool
extends Resource
class_name IMCSet

@export var id_to_imc_dict: Dictionary[int, IMC] = {}

@export var action_to_imc_dict: Dictionary[String, IMC]

@export var current_id: int = 1
