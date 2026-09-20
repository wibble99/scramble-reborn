extends RefCounted
class_name Stages
## Registry tying stage index -> hand-authored stage data resource.
## Adding a fifth stage later only means adding one more data file here.

const STAGE_COUNT := 4

static func get_stage_data(index: int) -> Dictionary:
	var i: int = index % STAGE_COUNT
	match i:
		0:
			return Stage1Data.get_data()
		1:
			return Stage2Data.get_data()
		2:
			return Stage3Data.get_data()
		3:
			return Stage4Data.get_data()
		_:
			return Stage1Data.get_data()
