import Datas;
import mt.bumdum.Lib;
import Constructable;

class Cs {//}

	public static var mcw = GamePlay.WORLD_WIDTH;
	public static var mch = GamePlay.WORLD_HEIGHT;

	// UPDATE GENERALE
	public static var AUTO_UPDATE =			60000;
	public static var AUTO_UPDATE_WAIT_FOR_PLAYER =	15000;
	public static var AUTO_UPDATE_CHAT_OUT = 	90000;

	// UPDATE SPECIFIQUE ( dépend de la navigation du joueur )
	public static var AUTO_UPDATE_PLANET_IN =	60000;
	public static var AUTO_UPDATE_CHAT_IN = 	5000;


	public static var COLORS = [0xE0C339,0xDF7448,0x66D588,0x8CD53B,0xDE6031,0xC4BBA6,0x8799C0,0xEC76DA];

	public static var COLOR_DANGREN = [0xDCEEFF,0xAF88FF,0xFF72F1,0xFF6B60,0xFC9504,0xFFEA3C,0x2DE346,0x33E8FD];
	public static var COLOR_SKATCH = COLOR_DANGREN;

	//public static var COLOR_SKATCH =  [0xD6C328,0xFEAE02,0xFF6834,0xFC60EC,0xBFB1D1,0x66A0BF,0x63D388,0x8ED63A];
	// public static var COLOR_DANGREN = [0xFBE83D,0xF7Ab05,0xC394FD,0xFB72EF,0xD6CAED,0x4EDAFB,0x5AF190,0x89EC3C];

	public static var BDIR =  [[0,0],[0,-1],[-1,0],[-1,-1]];
	public static var DIR =  [[1,0],[0,1],[-1,0],[0,-1]];
	public static var FDIR = [[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1],[1,-1]];

	public static var COLOR_SKY = 0x875800;
	public static var COLOR_LINE = 0xE0C86B;
	public static var COLOR_LINE2 = 0xCC8601;
	public static var COLOR_TEXT = 0xFF9900;
	public static var COLOR_MARONASSE = 0x898D6B;
	public static var COLOR_PANEL_TEXT = 0x898D6B;
	public static var COLOR_PANEL_TEXT_DARK = 0x898D6B;


	public static function initColors(){
		switch(Game.me.raceId){
			case 0:
				COLORS = COLOR_SKATCH;
			case 1:
				COLORS = COLOR_DANGREN;
				COLOR_SKY = 0x007777;
				COLOR_LINE = 0xA5ECF3;
				COLOR_LINE2 = 0x00CCDD;
				COLOR_TEXT = 0x00EEEE;
				COLOR_MARONASSE = 0x005566;
				COLOR_PANEL_TEXT = 0x93685C;
				COLOR_PANEL_TEXT_DARK = 0x36251F;

				inter.Board.WIDTH -= 3;
		}
	}

	public static function getTime(ms:Float,?flFull,?flShort){

		var s = Std.int(ms/1000);


		var h = Math.floor(s/3600);
		var m = Math.floor( (s-(h*3600)) / 60 );
		s -=  h*3600 + m*60;

		var ss = Std.string(s);
		while(ss.length<2)ss = "0"+ss;
		var str = ss+"s";
		if(flShort)str="";
		if(m>0 || flFull){
			var ms = Std.string(m);
			while(ms.length<2)ms = "0"+ms;
			str = ms+"m "+str;
		}

		if(h>0 || flFull){
			str = Std.string(h)+"h "+str;
		}

		return str;

	}

	// DISPLAY
	// GEN COST
	public static function genCostLine(mc,time:Float,?cost:_Cost,?flFull,?flShort,?flInvert){
		//if( cost == null ) cost = getRandomCost();

		var dm = new mt.DepthManager(mc);
		var a = [cost._material,cost._cloth,cost._ether,cost._pop,null,time];
		var id = 0;
		var x = 0.0;
		for( n in a ){
			if( n!=null && n>0 ){
				var str = Std.string(n);
				if( id == 5 ) str = Cs.getTime(Std.int(n),flFull,flShort);
				var mc = genCost(dm,x,id,str);
				x += mc._width+3;
			}
			id++;
		}

	}
	public static function genCost(dm,x,type,str){

		var mc:{ >flash.MovieClip, field:flash.TextField } = cast dm.attach("mcRes",0);
		mc._x = x;
		mc._y = -2;
		mc.smc.gotoAndStop(type+1);
		mc.field.text = str;

		mc.field._width = mc.field.textWidth+8;
		mc.smc._x = mc.field._width+5;

		return mc;
	}

	public static function genTime(mc,n,?flFull,?flShort,?color){
		if (n == null)
			return genText(mc, "...", color);
		var str = Cs.getTime(Std.int(n),flFull,flShort);
		if( n>1000000000 )
			str = "impossible";
		return genText(mc,str,color);
	}
	
	public static function genText(mc,str,?color){
		if(color==null)color=0xFFFFFF;
		var root = new mt.DepthManager(mc).attach("mcField",0);
		var field:flash.TextField = cast(root).field;
		field.text = str;
		Game.fixTextField(field);
		field.textColor = color;
		field._width = field.textWidth+3;
		return root;
	}

	// A DEPLACER
	public static function isBig(b:_Bld){
		var bl = BuildingLogic.get(b);
		return bl.size > 1;
		//return  b == TOWNHALL || b == QUARRY || b == FIELD || b == UNIVERSITY || b == ARCHIMORTAR || b == FACTORY || b == FORT :
	}
	public static function isEther(b:_Bld){
		return  b == PUMP || b == FOUNDRY || b == FOUNTAIN || b == CAULDRON || b == SCULPTOR || b == HOT_SPRING || b == STONE_FORGE || b == SPRAYER || b == SOURCE;
	}

	public static function getBatZone(type,x,y){
		if(isBig(type)){
			var a = [];
			for( d in BDIR )a.push([x+d[0],y+d[1]]);
			return a;
		}else{
			return [[x,y]];
		}

	}
	public static function getBigZone(x,y){
		var a = [];
		for( d in BDIR )a.push([x+d[0],y+d[1]]);
		return a;
	}

	public static function getBigPoint(isle:inter.Isle,px,py){

		for( d in Cs.BDIR ){
			var flOk = true;
			var z = null;
			for( d2 in Cs.BDIR ){
				var fx = px-d[0]+d2[0];
				var fy = py-d[1]+d2[1];
				var dalle = isle.grid[fx][fy];
				if( z==null )z = dalle.z;
				if( dalle.bt!=null || dalle.link!=null || dalle == null || z!= dalle.z || dalle.flEther ){
					flOk = false;
					break;
				}
			}
			if(flOk){
				return {
					x: px-d[0],
					y: py-d[1],
				}

			}
		}
		return null;
	}

	// HACK
	public static function getRandomCost():_Cost{
		var cost:_Cost = {
			_material : 10+Std.random(100)*5,
			_cloth : null,
			_ether : null,
			_pop : null,
		}

		if(Std.random(3)==0)	cost._cloth = (3+Std.random(10))*5;
		if(Std.random(4)==0)	cost._ether = (1+Std.random(10))*5;
		if(Std.random(10)==0)	cost._pop = 1+Std.random(3);

		return cost;

		/*
		return o;
			var min = 10+Std.random(100)*5;
			var cl = null;
			var et = null;
			i	cl =
			if(Std.random(3)==0)	et = Std.random(10)*5;
			genCostLine( mc.cost, min, cl, et, Std.random(5000) );

		*/

	}

	// TXT
	public static inline function getTitleTxt(str){
		return "<b><font size='14'>"+str+"</font></b>";
	}
	public static inline function getCapacityTxt(c){
		var str = Lang.getShipCapacity(c);
		return "<i><font color='#448800'>"+str+"</font></i>";
	}

	// TRAD
	public static function transCost(c:Cost):_Cost{
		return {
			_material:c.material,
			_cloth:c.cloth,
			_ether:c.ether,
			_pop:c.population,

		}


	}

	// GET INTERFACE LINKAGE
	public static function gil(str:String){
		if( Game.me.raceId > 0 )str += Std.string(Game.me.raceId+1);
		return str;
	}

	// Is
	public static function isStatus(status:Int,n){
		return ( status & Std.int(Math.pow(2, n))) > 0;
	}

//{
}















