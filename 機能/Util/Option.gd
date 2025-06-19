class_name Option

var some
var is_some:bool

func unwrap():
	if self.is_some:
		return self.some
	else:
		printerr("Unwraped on none value.")
		return null

static func Some(value) -> Option:
	var opt = Option.new()
	opt.some = value
	opt.is_some = true
	return opt

static func None() -> Option:
	var opt = Option.new()
	opt.is_some = false
	return opt
