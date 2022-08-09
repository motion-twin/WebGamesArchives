package ;

/**
 * ...
 * @author de
 */
enum ChatType
{
	Local;
	_Central;
	Mush;
	_Alert;
	Objectives;
	Wall;
	FavWall;
	
	Private0;
	Private1;
	Private2;
	
	Private3;
	Private4;
}

enum UI_FLAGS
{
	UF_EXPECT_CLOSET_OPENED; //0
	UF_FAKE_HUNTER;
	UF_FORCE_CLOSET_OPENED;
	UF_BREAK_THE_DOOR;
	UF_EXPECT_NORMAL_MODE;
	UF_SIMPLE_UI; // 5
	UF_EXPECT_TIPS;
}

class CrossConsts
{
	public static var COOK_SEL = "sel";
	public static var COOK_CURCHAT = "curChat";
	public static var REMOTING_COM_CHANNEL = "default";
	public static var COOK_INV_OFFSET_L = "inv_offset_l";
	
	public static var BASELINE_NONE = 439;
	
	public static var BASELINE_CLOSET = 260;
	public static var BASELINE_ACTIONS = 350;
	
	public static var PRIVATE_CHAN_START = Type.enumIndex(Private0);
	
}

typedef ShipJsView =
{
	var mapType : Int;
}

typedef CrossHeroView =
{
	id:Int,
	serial:String,
	name:String,
	surname:String,
	dev_surname:String,
	short_desc:String,
	skills:List<{name:String,desc:String,img:String}>,
	titles:List<{name:String,desc:String,img:String}>,
	statuses:List<{name:String,desc:String,img:String}>,
	spores: {nb:Int, name:String,desc:String,img:String},
	gender:String,
	me:Bool,
}

typedef CrossNPCView =
{
	id:Int,
	serial:String,
}

enum CrossFlags
{
	MushBody;
	PilgredUnlocked;
	IcarusLanded;
	IsA;
}

enum FeedResponse
{
	FRReload;
	FRJq( jq:String, html:String, fx:Null<String> );
}

typedef PrivChanId = Int;



