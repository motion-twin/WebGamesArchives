import Protocol;
import mt.bumdum9.Lib;

/*
@:build(ods.Data.build("data.ods", "perm", "id") ) enum PermType { }

typedef DataPerm = {
	id:PermType,
	name:String,
	desc:String,
}
*/

enum BonusKind {
	BK_Jump;
	BK_Star;
}

enum EStep {
	VOID;
	MOVE;
	JUMPING;
	SPECIAL;
	WAIT;
}

typedef DataProgression = {
	_cursor:Int,
	_list:Array<DataLevel>,
}

typedef DataLevel = {
	_squares:Array<Int>,
	_bads:Array<Int>,
	_doors:Array<Int>,
	_start:Int,
}