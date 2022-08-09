
typedef Zone = {
	name:String,
	pos:Array<Int>,
	col:Int,
	pal:Array<Array<Int>>
}




class ZoneInfo{//}

	static var DIF = 0;

	// static var TOLERANCE = 0.8;
	static var TOLERANCE = 0.3;

	// ZONES
	public static var MOLTEAR = 	0;
	public static var SOUPALINE = 	1;
	public static var LYCANS = 	2;
	public static var SAMOSA = 	3;
	public static var TIBOON = 	4;
	public static var BALIXT = 	5;
	public static var KARBONIS = 	6;
	public static var SPIGNYSOS = 	7;
	public static var POFIAK = 	8;
	public static var SENEGARDE = 	9;
	public static var DOURIV = 	10;
	public static var GRIMORN = 	11;
	public static var DTRITUS = 	12;
	public static var ASTEROBELT = 	13;
	public static var NALIKORS = 	14;
	public static var HOLOVAN = 	15;
	public static var KHORLAN = 	16;
	public static var CILORILE = 	17;
	public static var TARCITURNE = 	18;
	public static var CHAGARINA = 	19;
	public static var VOLCER = 	20;
	public static var BALMANCH = 	21;
	public static var FOLKET = 	22;
	public static var EARTH = 	23;

	public static var ASTEROBELT_CX = 	27;
	public static var ASTEROBELT_CY = 	6;
	public static var ASTEROBELT_RAY = 	110;


	/*
	static function initDatas() {
		var data = Std.resource("datas");
		// TODO : decrypt
		var obj = haxe.Unserializer.run(data);
		trace(obj);
		return obj;
	}
	static var DATAS = initDatas();
	*/

	public static var encryptedList = haxe.Resource.getString("ZoneInfo");

	// FAUSSE LISTE DES PLANETES - NE PAS EFFACER !
	public static var list : Array<Zone> = [
		{ name:"Moltear", 	pos:[-55,34,7],	 	col: 0xAA0044,	pal:[[100,100,150,55,55,105],[100,100,100,105,55,55] ]			},
		{ name:"Soupaline", 	pos:[-7,1,2], 		col: 0x444488,	pal:[[40,0,200,20,20,20],[20,200,40,20,40,20] ]				},
		{ name:"Lycans", 	pos:[1,14,8], 		col: 0xAA6622,	pal:[[100,100,0,155,155,40]]						},
		{ name:"Samosa", 	pos:[412,93,11],	col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
		{ name:"Tiboon", 	pos:[9,-10,2],		col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
		{ name:"Balixt", 	pos:[-9,-39,5],		col: 0x884466,	pal:[[40,30,10,100,200,50]]						},
		{ name:"Karbonis", 	pos:[27,6,0],		col: 0xAA8888,	pal:[[170,40,70,80,60,70],[180,180,20,70,70,40]]			},
		{ name:"Spignysos", 	pos:[-36,-10,5],	col: 0x222288,	pal:[[20,40,150,20,20,100],[0,175,175,50,75,75]]			},
		{ name:"Pofiak", 	pos:[-18,85,3],		col: 0x118833,	pal:[[20,80,60,20,150,80],[150,150,20,100,100,0]]			},
		{ name:"Senegarde", 	pos:[93,48,5],		col: 0x880066,	pal:[[150,20,80,100,80,100],[50,20,200,150,50,50]]			},
		{ name:"Douriv", 	pos:[-84,-102,7],	col: 0x884499,	pal:[[200,20,20,100,20,20],[20,200,20,20,100,20],[20,20,200,20,20,100]]	},
		{ name:"Grimorn", 	pos:[81,-122,4],	col: 0xBBBBBB,	pal:[[60,60,60,60,60,60]]						},
		{ name:"D-tritus", 	pos:[247,-44,2],	col: 0x555555,	pal:[[30,30,0,150,150,60]]						},
		{ name:"Asteroide", 	pos:[0,0,0],		col: 0x555555,	pal:[[30,30,0,160,120,60],[250,200,0,50,30,0]]				},
		{ name:"Nalikors", 	pos:[67,153,4],		col: 0x55AA88,	pal:[[0,0,40,0,50,210],[0,40,40,0,210,210]]				},
		{ name:"Holovan", 	pos:[-150,111,6],	col: 0xAA4488,	pal:[[100,0,40,250,50,210],[0,40,40,250,40,40]]				},
		{ name:"Khorlan", 	pos:[180,-191,5],	col: 0x88AA88,	pal:[[0,100,0,150,150,150],[150,150,150,100,50,0]]			},
		{ name:"Cilorile", 	pos:[78,-23,5],		col: 0x87526E,	pal:[[150,80,100,100,100,100],[100,200,200,50,50,50]]			},
		{ name:"Tarciturne", 	pos:[192,115,3],	col: 0x66AAAA,	pal:[[60,60,60,60,60,60]]						},
		{ name:"Chagarina", 	pos:[-320,-574,4],	col: 0xBBCCC0,	pal:[[50,60,60,50,60,60]]						},
		{ name:"Volcer", 	pos:[-237,270,8],	col: 0x8550AA,	pal:[[20,20,60,90,60,60],[20,70,20,20,100,60],]				},
		{ name:"Balmanch", 	pos:[104,-310,5],	col: 0xCCBB77,	pal:[[0,0,0,120,120,120],[0,0,0,150,0,100]]				},
		{ name:"Folket", 	pos:[470,393,3],	col: 0x2277AA,	pal:[[0,50,100,0,50,150]]						},
	];

	//public static var list:Array<Zone> = [];

	public static var holes = [
		[ [-9,-7],[48,23] ],
		[ [-106,54],[62,-142] ],
		[ [5,-61],[-230,1] ],
		[ [-85,-232],[-19,143] ],
		[ [121,-50],[334,-162] ],
	];

	public static function getBox(p){
		return {
			cx:p.pos[0],
			cy:p.pos[1],
			rad:p.pos[2],
			xmin:p.pos[0] - p.pos[2],
			xmax:p.pos[0] + p.pos[2] - 1,
			ymin:p.pos[1] - p.pos[2],
			ymax:p.pos[1] + p.pos[2] - 1
		}
	}

	public static function getPlanet(x, y) : Int {
		var planet = null;
		var id = 0;
		for (p in list){
			if (p == null)
				throw "list contains null element : "+Std.string(list);
			if (p.pos == null)
				throw "p.pos == null : "+Std.string(p);
			var sq = getBox(p);
			if (x >= sq.xmin && x <= sq.xmax && y >= sq.ymin && y <= sq.ymax){
				planet = id;
				break;
			}
			id ++;
		}
		if (planet == null)
			return null;
		var p = list[planet];
		if (isInCircle(x, y, p.pos[0], p.pos[1], p.pos[2]))
			return planet;
		return null;
	}

	public static function getSquares(id){
		var a = [];
		var box = getBox(list[id]);
		for (x in box.xmin...box.xmax+1)
			for (y in box.ymin...box.ymax+1)
				if (isInCircle(x,y,box.cx, box.cy, box.rad))
					a.push([x,y]);
		/*
		if( pos.length==3 ){
			var ray = pos[2];
			var sx = pos[0]-ray;
			var sy = pos[1]-ray;
			for( x in 0...ray*2 ){
				for( y in 0...ray*2 ){
					var dx = x - ray;
					var dy = y - ray;
					if( Math.sqrt(dx*dx+dy*dy) <= ray+TOLERANCE ){
						a.push([x+sx,y+sy]);
					}
				}
			}
		}
		*/
		return a;
	}

	public static function isInCircle( x:Int, y:Int, cx:Int, cy:Int, rad:Int ) : Bool {
		var dx = cx - x - 0.5;
		var dy = cy - y - 0.5;
		return Math.sqrt(dx*dx + dy*dy) <= rad + TOLERANCE;
	}

	// ???
	static function main(){
		for (id in 0...list.length)
			test(id);
	}
	static function test( id:Int ){
		trace("### PLANET "+id);
		var squares = getSquares(id);
		var manual = new Array();
		var coords = getBox(list[id]);
		for (x in (coords.xmin-1)...(coords.xmax+1)){
			for (y in (coords.ymin-1)...(coords.ymax+1)){
				if (isInCircle(x, y, coords.cx, coords.cy, coords.rad))
					manual.push([x,y]);
			}
		}
		if (squares.length != manual.length)
			throw "different sizes : "+squares.length+" != "+manual.length;
		var size = squares.length;
		while (squares.length > 0){
			var s = squares.pop();
			var m = manual.pop();
			if (s[0] != m[0] || s[1] != m[1])
				throw "Prout";
		}
		trace("ok : "+size+" blocks for radius "+coords.rad);
	}

	//
	static function initFonction(){

		#if web
		//VERITABLE LISTE DES PLANETES NE PAS EFFACER !
		var a = [
			{ name:"Moltear", 	pos:[-55,34,7],	 	col: 0xAA0044,	pal:[[100,100,150,55,55,105],[100,100,100,105,55,55] ]			},
			{ name:"Soupaline", 	pos:[-7,1,2], 		col: 0x444488,	pal:[[40,0,200,20,20,20],[20,200,40,20,40,20] ]				},
			{ name:"Lycans", 	pos:[1,14,8], 		col: 0xAA6622,	pal:[[100,100,0,155,155,40]]						},
			{ name:"Samosa", 	pos:[412,93,11],	col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
			{ name:"Tiboon", 	pos:[9,-10,2],		col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
			{ name:"Balixt", 	pos:[-9,-39,5],		col: 0x884466,	pal:[[40,30,10,100,200,50]]						},
			{ name:"Karbonis", 	pos:[27,6,0],		col: 0xAA8888,	pal:[[170,40,70,80,60,70],[180,180,20,70,70,40]]			},
			{ name:"Spignysos", 	pos:[-36,-10,5],	col: 0x222288,	pal:[[20,40,150,20,20,100],[0,175,175,50,75,75]]			},
			{ name:"Pofiak", 	pos:[-18,85,3],		col: 0x118833,	pal:[[20,80,60,20,150,80],[150,150,20,100,100,0]]			},
			{ name:"Senegarde", 	pos:[93,48,5],		col: 0x880066,	pal:[[150,20,80,100,80,100],[50,20,200,150,50,50]]			},
			{ name:"Douriv", 	pos:[-84,-102,7],	col: 0x884499,	pal:[[200,20,20,100,20,20],[20,200,20,20,100,20],[20,20,200,20,20,100]]	},
			{ name:"Grimorn", 	pos:[81,-122,4],	col: 0xBBBBBB,	pal:[[60,60,60,60,60,60]]						},
			{ name:"D-tritus", 	pos:[247,-44,2],	col: 0x555555,	pal:[[30,30,0,150,150,60]]						},
			{ name:"Asteroide", 	pos:[0,0,0],		col: 0x555555,	pal:[[30,30,0,160,120,60],[250,200,0,50,30,0]]				},
			{ name:"Nalikors", 	pos:[67,153,4],		col: 0x55AA88,	pal:[[0,0,40,0,50,210],[0,40,40,0,210,210]]				},
			{ name:"Holovan", 	pos:[-150,111,6],	col: 0xAA4488,	pal:[[100,0,40,250,50,210],[0,40,40,250,40,40]]				},
			{ name:"Khorlan", 	pos:[180,-191,5],	col: 0x88AA88,	pal:[[0,100,0,150,150,150],[150,150,150,100,50,0]]			},
			{ name:"Cilorile", 	pos:[78,-23,5],		col: 0x87526E,	pal:[[150,80,100,100,100,100],[100,200,200,50,50,50]]			},
			{ name:"Tarciturne", 	pos:[192,115,3],	col: 0x66AAAA,	pal:[[60,60,60,60,60,60]]						},
			{ name:"Chagarina", 	pos:[-320,-574,4],	col: 0xBBCCC0,	pal:[[50,60,60,50,60,60]]						},
			{ name:"Volcer", 	pos:[-298,-149,8],	col: 0x8550AA,	pal:[[20,20,60,90,60,60],[20,70,20,20,100,60],]				},
			{ name:"Balmanch", 	pos:[-340,362,5],	col: 0xCCBB77,	pal:[[0,0,0,120,120,120],[0,0,0,150,0,100]]				},
			{ name:"Folket", 	pos:[574,-254,3],	col: 0x2277AA,	pal:[[0,50,100,0,50,150]]						},
			{ name:"Terre", 	pos:[8000,8100,3],	col: 0x2277AA,	pal:[[0,50,100,0,50,150]]						},
		];


		list = a;
		#else
		/*
		var a = [
			{ name:"Moltear", 	pos:[-55,34,7],	 	col: 0xAA0044,	pal:[[100,100,150,55,55,105],[100,100,100,105,55,55] ]			},
			{ name:"Soupaline", 	pos:[-7,1,2], 		col: 0x444488,	pal:[[40,0,200,20,20,20],[20,200,40,20,40,20] ]				},
			{ name:"Lycans", 	pos:[1,14,8], 		col: 0xAA6622,	pal:[[100,100,0,155,155,40]]						},
			{ name:"Samosa", 	pos:[412,93,11],	col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
			{ name:"Tiboon", 	pos:[9,-10,2],		col: 0xAA6622,	pal:[[55,55,55,200,200,200]]						},
			{ name:"Balixt", 	pos:[-9,-39,5],		col: 0x884466,	pal:[[40,30,10,100,200,50]]						},
			{ name:"Karbonis", 	pos:[27,6,0],		col: 0xAA8888,	pal:[[170,40,70,80,60,70],[180,180,20,70,70,40]]			},
			{ name:"Spignysos", 	pos:[-36,-10,5],	col: 0x222288,	pal:[[20,40,150,20,20,100],[0,175,175,50,75,75]]			},
			{ name:"Pofiak", 	pos:[-18,85,3],		col: 0x118833,	pal:[[20,80,60,20,150,80],[150,150,20,100,100,0]]			},
			{ name:"Senegarde", 	pos:[93,48,5],		col: 0x880066,	pal:[[150,20,80,100,80,100],[50,20,200,150,50,50]]			},
			{ name:"Douriv", 	pos:[-84,-102,7],	col: 0x884499,	pal:[[200,20,20,100,20,20],[20,200,20,20,100,20],[20,20,200,20,20,100]]	},
			{ name:"Grimorn", 	pos:[81,-122,4],	col: 0xBBBBBB,	pal:[[60,60,60,60,60,60]]						},
			{ name:"D-tritus", 	pos:[247,-44,2],	col: 0x555555,	pal:[[30,30,0,150,150,60]]						},
			{ name:"Asteroide", 	pos:[0,0,0],		col: 0x555555,	pal:[[30,30,0,160,120,60],[250,200,0,50,30,0]]				},
			{ name:"Nalikors", 	pos:[67,153,4],		col: 0x55AA88,	pal:[[0,0,40,0,50,210],[0,40,40,0,210,210]]				},
			{ name:"Holovan", 	pos:[-150,111,6],	col: 0xAA4488,	pal:[[100,0,40,250,50,210],[0,40,40,250,40,40]]				},
			{ name:"Khorlan", 	pos:[180,-191,5],	col: 0x88AA88,	pal:[[0,100,0,150,150,150],[150,150,150,100,50,0]]			},
			{ name:"Cilorile", 	pos:[78,-23,5],		col: 0x87526E,	pal:[[150,80,100,100,100,100],[100,200,200,50,50,50]]			},
			{ name:"Tarciturne", 	pos:[192,115,3],	col: 0x66AAAA,	pal:[[60,60,60,60,60,60]]						},
			{ name:"Chagarina", 	pos:[-320,-574,4],	col: 0xBBCCC0,	pal:[[50,60,60,50,60,60]]						},
			{ name:"Volcer", 	pos:[-298,-149,8],	col: 0x8550AA,	pal:[[20,20,60,90,60,60],[20,70,20,20,100,60],]				},
			{ name:"Balmanch", 	pos:[-340,362,5],	col: 0xCCBB77,	pal:[[0,0,0,120,120,120],[0,0,0,150,0,100]]				},
			{ name:"Folket", 	pos:[574,-254,3],	col: 0x2277AA,	pal:[[0,50,100,0,50,150]]						},
			{ name:"Terre", 	pos:[8000,8100,3],	col: 0x2277AA,	pal:[[0,50,100,0,50,150]]						},
		];
		var str = haxe.Serializer.run(a);
		var o = new mt.net.Codec("bonjour");
		str = StringTools.urlEncode(o.run(str));
		flash.System.setClipboard(str);
		//*/

		var str = StringTools.urlDecode(encryptedList);
		var o = new mt.net.Codec("bonjour");
		list = haxe.Unserializer.run(o.run(str));
		#end

		return true;
	}

	private static function setDifficultyXXX(n){
		if( ZoneInfo.DIF != 0 )return;
		DIF = n;

		if( DIF==1 ){
			var seed = new mt.Rand(87);
			for( pl in list){
				var x = pl.pos[1];
				var y = pl.pos[0];
				var a = Math.atan2(y,x)+ (1+seed.rand()*2.14)*(seed.random(2)*2-1);
				var dist = Math.sqrt(x*x+y*y)*(1.1+Math.random()*0.2);
				var nx = Std.int( Math.cos(a)*dist );
				var ny = Std.int( Math.sin(a)*dist );
				var pdx = nx - pl.pos[0];
				var pdy = ny - pl.pos[1];

				var ray = pl.pos[2];

				for( item in MissionInfo.ITEMS ){

					var dx = item.x-pl.pos[0];
					var dy = item.y-pl.pos[1];
					if( Math.abs(dx) <= ray && Math.abs(dy) <=ray ){
						item.x += pdx;
						item.y += pdy;
					}
				}

				pl.pos[0] = nx;
				pl.pos[1] = ny;
				pl.pos[2] += 2;
			}

		}
	}

	static var init = initFonction();


//{
}


// PROTOCOLE

// - PlayLevel(x,y);
// - EndLevel(x,y,mined);
// - GetTrophy(x,y);
// - GetSpecial(id);


// COL_OBJECTS











