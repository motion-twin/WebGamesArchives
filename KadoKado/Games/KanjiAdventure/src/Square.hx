import Protocol;
import mt.bumdum.Lib;



class Square {//}


	public static var DP_FX = 4;
	public static var DP_ACTOR = 3;
	public static var DP_ITEM = 2;
	public static var DP_UFX = 1;
	public static var DP_DECOR = 0;

	public var ent:Ent;

	public var rid:Int;
	public var heat:Int;
	public var x:Int;
	public var y:Int;
	public var itemId:Int;
	public var mcItem:flash.MovieClip;


	public var type:SquareType;

	var root:flash.MovieClip;
	var mcHeat:flash.MovieClip;
	public var dm:mt.DepthManager;
	var text:flash.display.BitmapData;


	public function new(px,py,?t){
		x = px;
		y = py;
		setType(t);

	}

	public function setHeat(n){
		heat = n;
		if( n!=null ){
			if(mcHeat==null)mcHeat = dm.attach("mcHeat",DP_DECOR);
			mcHeat._alpha  = 60-n*5;
		}else{
			mcHeat.removeMovieClip();
			mcHeat=  null;
		}

	}
	public function setType(t){
		if(t==null)t = WALL;
		/*
		if(type!=null && type!=WALL ){
			trace("overlap"+Type.enumIndex(type));
			trace("z->"+Type.enumIndex(t));
		}
		*/
		type = t;

	}
	public function draw(floor:Floor){

		// POS
		var px = x*Cs.CS;
		var py = y*Cs.CS;
		var m = new flash.geom.Matrix();
		m.translate(px,py);

		// ROOT
		root = floor.dm.empty(Floor.DP_SQUARE);
		root._x = px;
		root._y = py;
		dm = new mt.DepthManager(root);

		// BRUSH
		var br = floor.brush;
		br.gotoAndStop(Type.enumIndex(type)+1);
		var fr = floor.seed.random(br.smc._totalframes)+1;

		var flShade = false;
		switch(type){
			case WALL :
				fr = 1;
				var n = 1;
				for( d in Cs.DIR ){
					var sq = floor.grid[x+d[0]][y+d[1]];
					if(sq.type!=WALL && sq != null)fr+=n;
					n*=2;
				}
			case GROUND :
				if( floor.grid[x][y-1].type == WALL )flShade = true;
			default :
		}
		br.smc.gotoAndStop(fr);
		//
		var fr2 = Std.random(br.smc.smc._totalframes)+1;
		br.smc.smc.gotoAndStop(fr2);
		//
		var mmc:flash.MovieClip = cast(br.smc).smc2;
		var fr3 = Std.random(mmc._totalframes)+1;
		mmc.gotoAndStop(fr3);


		var mcShade:flash.MovieClip = cast(br.smc).shade;
		mcShade._visible = flShade;



		// UP
		var up = floor.grid[x][y-1];
		if( up.isDynamic() ){

			//* DRAW ONLY UP PART
			var r = new flash.geom.Rectangle(px,py,Cs.CS,Cs.CS);
			floor.ground.draw(br,m,null,null,r);
			var b = br.getBounds(br);
			if(b.yMin<0){
				var h = Math.ceil(-b.yMin);
				text = new flash.display.BitmapData(Cs.CS,h+15,true,0);
				var m = new flash.geom.Matrix();
				m.translate(0,h);
				text.draw(br,m);
				var mc = dm.empty(DP_DECOR);
				mc.attachBitmap(text,0);
				mc._y = -h;
			}
			/*/
			var mc = dm.attach("mcSquare",DP_DECOR);
			mc.gotoAndStop(Type.enumIndex(type)+1);
			mc.smc.gotoAndStop(fr);



			//*/
		}else{
			floor.ground.draw(br,m);

		}


		// ITEM
		if(itemId!=null)showItem();

	}

	// ITEM

	public function addItem(id){
		if(itemId!=null)trace("addItem ERROR");
		itemId = id;

	}
	public function showItem(){
		mcItem = dm.attach("mcItem",1);
		mcItem.gotoAndStop(itemId+1);
	}
	public function removeItem(){
		itemId = null;
		mcItem.removeMovieClip();
	}

	// FX
	public function fxLight(){

		var max = 20;
		for( i in 0...max ){
			var dp = DP_UFX;
			if(i/max>0.5)dp = DP_FX;
			var p = new mt.bumdum.Part( dm.attach("partLight",dp) );
			p.x = Cs.CS*Math.random();
			p.y = Cs.CS*(i/max);
			p.weight = -(0.05+Math.random()*0.2);
			p.frict=  0.99;
			p.timer = 10+Math.random()*20;
			p.sleep = Math.random()*2;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.root._visible = false;
			p.updatePos();

			//Filt.glow(p.root,5,1,0xFFFFFF);
			Col.setPercentColor(p.root,80,Col.objToCol(Col.getRainbow(Math.random())));
			p.root.blendMode = "add";
		}

	}
	public function fxFlame(){
		var mc = dm.attach("fxFlame",DP_FX);
	}
	public function fxSmoke(){
		var max = 20;
		for( i in 0...max ){
			var dp = DP_UFX;
			if(i/max>0.5)dp = DP_FX;
			var p = new mt.bumdum.Part( dm.attach("partSmoke",dp) );
			p.x = Cs.CS*Math.random();
			p.y = Cs.CS*(i/max) - Math.random()*15;
			p.weight = -(0.05+Math.random()*0.15);
			p.frict =  0.99;
			p.timer = 10+Math.random()*15;
			p.fadeType = 0;
			var sens = x<Cs.CS*0.5?1:-1;
			p.root._rotation = Math.random()*360;
			p.vr = sens*(10+Math.random()*15);
			p.fr = 0.92;
			p.root.smc._xscale = sens*100;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.updatePos();
			//trace(p.root._visible);

			//Filt.glow(p.root,5,1,0xFFFFFF);
			//Col.setPercentColor(p.root,80,Col.objToCol(Col.getRainbow(Math.random())));
			//p.root.blendMode = "add";
		}

	}
	public function fxChaos(){
		fxLight();
		/*
		var max = 20;
		for( i in 0...max ){
			var dp = DP_UFX;
			if(i/max>0.5)dp = DP_FX;
			var p = new mt.bumdum.Part( dm.attach("partLight",dp) );
			p.x = Cs.CS*Math.random();
			p.y = Cs.CS*(i/max);
			p.weight = -(0.05+Math.random()*0.2);
			p.frict=  0.99;
			p.timer = 10+Math.random()*20;
			p.sleep = Math.random()*2;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.root._visible = false;
			p.updatePos();

			//Filt.glow(p.root,5,1,0xFFFFFF);
			Col.setPercentColor(p.root,80,Col.objToCol(Col.getRainbow(Math.random())));
			p.root.blendMode = "add";
		}
		*/

	}
	public function fxSleep(){
		var mc = dm.attach("fxSleep",DP_FX);
		Filt.glow(mc,2,4,0);
	}
	public function fxGem(col){
		var max = 20;
		for( i in 0...max ){
			var dp = DP_UFX;
			if(i/max>0.5)dp = DP_FX;
			var p = new mt.bumdum.Part( dm.attach("partGem",dp) );
			//trace(p.root._visible);
			p.x = Cs.CS*Math.random();
			p.y = Cs.CS*(i/max);
			p.weight = -(0.05+Math.random()*0.2);
			p.frict=  0.99;
			p.timer = 10+Math.random()*30;
			p.sleep = Math.random()*3;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.root._visible = false;
			p.root.blendMode = "overlay";
			Filt.glow(p.root,2,2,col);
			p.updatePos();

			//Filt.glow(p.root,5,1,0xFFFFFF);
			//Col.setPercentColor(p.root,80,Col.objToCol(Col.getRainbow(Math.random())));
			//p.root.blendMode = "add";
		}

	}

	public function fxScore(sc){
		var p = new mt.bumdum.Phys( dm.attach("partScore", DP_FX) );
		p.x = Cs.CS*0.5;
		p.y = -5;
		p.weight = -0.05;
		p.frict = 0.95;
		p.timer = 30;
		//p.fadeType = 0;
		Filt.glow(p.root,2,4,0);
		p.setScale(80);
		Reflect.setField(p.root,"_sc",sc);
	}

	// TOOLS
	public function isGround(){
		return type == GROUND || type == STAIR_UP || type == STAIR_DOWN;
	}
	public function isDynamic(){
		return type != WALL ;
	}
	public function isFree(){
		return type == GROUND && ent==null;
	}
	public function isHeroFree(){
		return isGround() && ent==null;
	}


	public function kill(){
		root.removeMovieClip();
		text.dispose();
	}

//{
}

