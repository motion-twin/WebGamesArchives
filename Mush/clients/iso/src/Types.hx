package ;

import Protocol;

enum Sheet
{
	BUMDUM;
	AYAME;
	FX_SHEET;
	CHAR_SHEET;
	
	CHAIR_SHEET;
	TABLE_SHEET;
	
	SMALL_FILL_SHEET;
	MID_FILL_SHEET;
	MID_FILL_SHEET2;
	BIG_SHEET;
	BIG_SHEET2;
	MASK_SHEET;
	DEV_SHEET;
}

enum Entities
{
	PLAYER;
	CHARACTER;
	FX;
	PROPS;
	DUMMY;
}

typedef PixSlice =
{
	sheet : Sheet,
	index : String,
	
	ofsX: Int,
	ofsY: Int,
	
	?frames : Array<{ col:Null<Int>,grdOfsY:Null<Int>}>,
	?data: List<String>,
	?deps : V2I,
	?modulePad : V2I,
	
	prioOfs : Int,
	?engine : Engine,
	autoAnim : Bool,
	animable:Bool,
	?dir: Dirs.E_DIRS,
}

typedef PixSetup =
{
	sheet : Sheet,
	frame : Int,
	index : String,
}

enum CharSet
{
	CS_UP;
	CS_SIT;
	
	CS_RUNNING;
}

enum DepFlags
{
	Smoking;
}

typedef DepInfos =
{
	tile:Tile,
	data:Array< V2I >, //whole tile list
	te: TileEntry,
	gameData : DepData,
	flags : Flags<DepFlags>,
	?mask : PixSetup,
	?rectCache: Array<V2I>, //TL BR of dep
	?ent: Entity,
	?pad: Array<V2I>,
	?debug : { pixel:V2I },
	?dir: Dirs.E_DIRS,
	?baseSetup:PixSetup,
	?iid:ItemId,
	?target:String,
	?locker:Bool,
	?key:String,
	?itemUid:Int,
	?xml:haxe.xml.Fast,
};

enum DepData
{
	NoData;
	Chair;
	Door( here : RoomId, there : RoomId );
	Equipment( iid : ItemId);
	Blocker;
	Decal;
}

typedef TileEntry = { setup:PixSetup, el:mt.pix.Element };
typedef SweepEntry = { rect:Array<V2I>, ent:Entity };

 enum Engine
 {
	UseTile;
	UseEntity;
	UsePostFx;
	UsePostWall;
	UsePreWall;
 }


enum Temp
{
	YELLOW;
	RED;
	ORANGE;
	
	SMOKE;
}