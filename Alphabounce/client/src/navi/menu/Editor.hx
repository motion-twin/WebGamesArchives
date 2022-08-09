package navi.menu;
import mt.bumdum.Lib;

typedef Brush = {>flash.MovieClip,bl:Block,field:flash.TextField,n:Int};
typedef Vig = {>flash.MovieClip,id:Int,bmp:flash.display.BitmapData};

class Editor extends navi.Menu{//}



	static var DEFAULT_COLOR = 0xFF0000;

	var flAdmin:Bool;
	var flPaint:Bool;

	var mode:Int;
	var mx:Int;
	var my:Int;
	var brushIndex:Int;

	var grid:Array<Array<Block>>;

	var zone:flash.MovieClip;
	var bg:flash.MovieClip;
	var bmpBg:flash.display.BitmapData;

	var brush:Brush;
	var brushes:Array<Brush>;
	var brushTypes:Array<Bool>;
	var vigs:Array<Vig>;
	var mainVig:Vig;
	var pendingLevels:Array<String>;

	var so:flash.SharedObject;
	var kl:Dynamic;


	override function init(){
		super.init();

		so = flash.SharedObject.getLocal("niveau");


		initBg();

		//
		initEditor();



		initKeyListener();


		//if(!flash.Key.isDown(flash.Key.SPACE))loadCache();

	}
	function initEditor(){
		mode = 0;
		initGrid();
		loadDefault();
		initInterface();
		initButtons();
	}

	function initBg(){


		// BG
		bg = dm.empty(0);
		bmpBg = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x004400 );
		bg.attachBitmap(bmpBg,0);

		// LINES
		var col = 0x005500;
		for( x in 0...Cs.XMAX ) bmpBg.fillRect( new flash.geom.Rectangle( Std.int(Cs.getX(x)), 0, 1, Cs.mch ), col );
		for( y in 0...Cs.YMAX ) bmpBg.fillRect( new flash.geom.Rectangle( 0, Std.int(Cs.getY(y)), Cs.mcw, 1 ), col );

		// ZONE ACTION
		zone = dm.attach("square",1);
		zone._x = Cs.getX(0);
		zone._y = Cs.getY(0);
		zone._xscale = Cs.XMAX * Cs.BW;
		zone._yscale = (Cs.YMAX-1) * Cs.BH;
		zone._alpha = 0;

		zone.onPress = 		pressMap;
		zone.onRelease =	releaseMap;
		zone.onRollOver = 	rOverMap;
		zone.onRollOut = 	rOutMap;
		zone.onDragOut = 	rOutMap;

		// bg back
		bg.onPress = function(){};
		bg.useHandCursor= false;

		//
		var mc = dm.attach("mcLogField",10);
		mc._x = Cs.mcw;
		mc._y = Cs.mch;
		fieldLog = (cast mc).field;
		fieldLog2 = (cast mc).field2;
		fieldLog2.text = Text.get.EDITOR_CLIC_SUPPR;

	}
	function initGrid(){
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				grid[x][y] = null;
			}
		}

	}

	// UPDATE
	override public function update(){
		super.update();
		mx = Cs.getPX(bg._xmouse);
		my = Cs.getPY(bg._ymouse);

		if( flPaint && isIn(mx,my+1)){

			if( mt.flash.Key.isDown(46) ){ // SUPPR
				removeBlock(mx,my);
				//saveToCache();

			}else if( brush != null && brush.n>0 ){
				updatePaint();
			}

		}

	}
	function updatePaint(){
		var bl = grid[mx][my];

		if( bl.type != brush.bl.type ){
			if( bl==null ){
				bl = new Block( mx, my, brush.bl.type, dm.attach("mcBlock",2), true );
				grid[mx][my] = bl;
			}else{
				incBrush(brushes[bl.type],1);
			}
			bl.setType(brush.bl.type);
			if(brush.bl.type==0)bl.setColor([DEFAULT_COLOR]);
			incBrush(brush,-1);
			//saveToCache();

		}
	}

	// BLOCK
	function removeBlock(x,y){
		var bl = grid[x][y];
		incBrush(brushes[bl.type],1);
		bl.root.removeMovieClip();
		grid[x][y] = null;
	}

	// INTERFACES
	function initInterface(){

		// BRUSHES
		brushes = [];
		brushIndex = 0;
		for( i in 0...5 )newBrush(i);
		for( i in 10...100 )newBrush(i);






	}
	function newBrush(id){
		if(brushTypes[id]!=true ){
			if( !Cs.pi.flAdmin || !Block.isBasic(id) )return;
		}


		/*
		var max = 10;
		var dx = brushes.length%max;
		var dy = Std.int(brushes.length/max) ;
		var bl = new Block( dx, dy+Cs.YMAX, id, dm.attach("mcBlock",2) );
		brushes.push(bl);
		if(id==0)bl.setColor([DEFAULT_COLOR]);
		*/

		var brush:Brush = cast dm.attach("mcEditorBrush",2);
		brush.bl = new Block( null, null, id, brush.smc, true );


		if(id==0)brush.bl.setColor([DEFAULT_COLOR]);
		var max = 10;
		brush._x = Cs.getX(brushIndex%max);
		brush._y = Cs.getY(Cs.YMAX+Std.int(brushIndex/max)-0.5);
		brushes[id] = brush;
		brush.onPress = callback(select,brush);
		brush.n = 0;
		if(Cs.pi.flAdmin)brush.n = 999;
		incBrush(brush,0);

		brushIndex++;

		//return brush;
	}
	function select(br){
		unselect();
		brush = br;

		Filt.glow(brush,4,8,0xFFFFFF);
		dm.over(brush);

	}
	function unselect(){
		brush.filters = [];
		brush = null;
	}
	function incBrush(brush,inc){
		brush.n += inc;

		brush.field.text = Std.string(brush.n);
		if(brush.n>100)brush.field.text = "";
	}

	function cleanBlocks(){
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var bl= grid[x][y];
				if( bl!=null )removeBlock(x,y);

			}
		}
	}

	// ACTIONS
	public function pressMap(){
		flPaint = true;
		//paint()
	}
	public function releaseMap(){
		flPaint = false;
		//paint()
	}
	function rOverMap(){

	}
	function rOutMap(){

	}

	// CACHE
	public function loadDefault(){
		var level = new Level( Cs.pi.x, Cs.pi.y,map.zoneTable[Cs.pi.x-navi.Map.SX][Cs.pi.y-navi.Map.SY], true );
		level.flEdit = true;
		level.genModel();
		loadString( level.getString() );
	}

	/*

	public function saveToCache(){
		so.data.currentLevel = getString();
		so.flush();

	}

	public function loadCache(){
		loadString(so.data.currentLevel);
	}
	*/

	// BUTTONS
	function initButtons(){

		var a = [];
		switch(mode){
			case 0:
				a = [
					{ id:0,	f:quit,		vis:true						},
					{ id:1,	f:cleanBlocks,	vis:true						},
					{ id:2,	f:commit,	vis:Cs.pi.pendingLevels >=0 && Cs.pi.pendingLevels <32	},
					{ id:3,	f:check,	vis:Cs.pi.flEditor && Cs.pi.pendingLevels>0		},
					{ id:4,	f:resetLevel,	vis:Cs.pi.flEditor && Cs.pi.pendingLevels==-1		},
				];
			case 1:
				a = [
					{ id:0,	f:back,		vis:true		},
					{ id:5,	f:choose,	vis:true		},
					{ id:6,	f:cleanLevels,	vis:true		},
				];
		}

		var x = Cs.mcw+0.0;

		for( o in a ){
			if(o.vis){
				var mc = dm.attach("mcSubmit",8);
				mc.gotoAndStop(o.id+1);
				x -= mc._width+4;
				mc._x = x;
				mc._y = Cs.mch - 22;
				mc.onRollOver = function(){ mc.blendMode = "add"; };
				mc.onRollOut = function(){ mc.blendMode = "normal"; };
				mc.onDragOut = mc.onRollOut;
				mc.onPress = o.f;
				setHint(mc,Text.get.EDITOR_BUTS[o.id]);
			}

		}
	}
	function removeButtons(){
		dm.clear(8);
	}


	//
	public function getString(){

		var tab = [];
		for( x in 0...Cs.XMAX ){
			tab[x] = [];
			for( y in 0...Cs.YMAX ){
				tab[x][y] = grid[x][y].type;
			}
		}



		var pc = new mt.PersistCodec();
		pc.crc = true;
		var str = pc.encode(tab);
		return str;

		/* OLD
		var str = "";
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var n = 0;
				var bl = grid[x][y];
				if(bl!=null)n = bl.type+1;
				str += Std.string(n)+",";
			}
		}
		return str.substr(0,str.length-1);
		*/

	}
	public function loadString(str:String){



		brushTypes = [];
		var a = str.split(",");

		if( a.length > 100 ){
			loadOldString(a);
		}else{
			var pc = new mt.PersistCodec();
			pc.crc = true;
			var tab = pc.decode(str);
			for( x in 0...Cs.XMAX ){
				for( y in 0...Cs.YMAX ){
					var n = tab[x][y];
					if( n!=null ){
						var bl = new Block(x,y,n,dm.attach("mcBlock",2),true);
						if(bl.type==0)bl.setColor([DEFAULT_COLOR]);
						grid[x][y] = bl;
					}
				}
			}
		}
	}
	public function loadOldString(a:Array<String>){
		var i = 0;
		for( ch in a ){
			var n = Std.parseInt(ch)-1;
			brushTypes[n] = true;
			if( n >= 0 ){
				var x = Std.int(i/Cs.YMAX);
				var y = i%Cs.YMAX;
				var bl = new Block(x,y,n,dm.attach("mcBlock",2),true);
				if(bl.type==0)bl.setColor([DEFAULT_COLOR]);
				grid[x][y] = bl;
			}
			i++;
		}
	}

	// PROTOCOLE
	public function commit(){
		if(!isValid())return;
		Api.submit(Cs.pi.x,Cs.pi.y,getString());
		Api.onConfirm = quit;
		// EMUL
		Cs.pi.pendingLevels += 1;
	}

	// MODERATOR
	function check(){
		removeAll();
		removeButtons();
		Api.askPendingLevels(Cs.pi.x,Cs.pi.y);
		navi.Map.me.onReceiveLevels = displayPendingLevels;

		mode = 1;
		initButtons();

	}
	public function displayPendingLevels(a:Array<String>){ // MAX DISPLAY 32

		vigs = [];
		var id = 0;

		var side = 8;
		var ww = Cs.mcw / side;
		var hh = Cs.mch / side;

		for( str in a ){
			//trace(str);

			var level = new Level(0,0,0,true,str);
			level.flEdit = true;
			level.genModel();
			var bmp = level.getScreenshot(0.95/side,DEFAULT_COLOR);

			var mc:Vig = cast dm.empty(5);
			mc.attachBitmap(bmp,0);
			mc._x = (id%side)*ww;
			mc._y = 185+Std.int(id/side)*hh;
			mc.id = id;
			mc.bmp = bmp;
			mc.onPress = callback(selectLevel,mc.id);
			//mc.onRollOver = function(){ Col.setColor(mc,0,100); };
			//mc.onRollOut = function(){ Col.setColor(mc,0,0); };
			mc.onRollOver = function(){ Filt.glow(mc,2,4,0xFFFFFF);Filt.glow(mc,10,1,0x00FF00); };
			mc.onRollOut = function(){ mc.filters = []; };
			mc.onDragOut = mc.onRollOut;
			vigs.push(mc);
			id++;
		}
		pendingLevels = a;
	}

	function selectLevel(id){
		if(mainVig==null){
			mainVig = cast dm.empty(5);
			mainVig._x = Cs.mcw*0.25;
			mainVig._y = 0;

		}else{
			mainVig.bmp.dispose();
		}

		var level = new Level(0,0,0,true,pendingLevels[id]);
		level.flEdit = true;
		level.genModel();
		var bmp = level.getScreenshot(0.5,DEFAULT_COLOR);

		mainVig.attachBitmap(bmp,0);
		mainVig.bmp = bmp;
		mainVig.id = id;


	}

	function back(){
		if(mainVig!=null)vigs.push(mainVig);
		while(vigs.length>0){
			var mc = vigs.pop();
			mc.bmp.dispose();
			mc.removeMovieClip();
		}
		removeButtons();
		initEditor();

	}
	function choose(){
		if(mainVig==null)return;
		Api.selectPendingLevel(Cs.pi.x,Cs.pi.y,mainVig.id);
		Api.onConfirm = back;
		// EMUL
		Cs.pi.pendingLevels = -1;
	}
	function cleanLevels(){
		Api.deletePendingLevels(Cs.pi.x,Cs.pi.y);
		Api.onConfirm = back;
		// EMUL
		Cs.pi.pendingLevels = 0;
	}

	//
	function resetLevel(){
		Api.resetLevel(Cs.pi.x,Cs.pi.y);
		Api.onConfirm = quit;
		// EMUL
		Cs.pi.pendingLevels = 0;
	}



	// EDITOR TOOLS
	function moveAll(dx,dy){







	}

	// KEY
	function initKeyListener(){
		kl = {};
		Reflect.setField(kl,"onKeyDown",pressKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();

		switch(n){
			case flash.Key.UP: moveAll(0,-1);
			case flash.Key.DOWN: moveAll(0,1);
			case flash.Key.LEFT: moveAll(-1,0);
			case flash.Key.RIGHT: moveAll(1,0);

		}
	}

	// REMOVE
	function removeAll(){
		//bg.removeMovieClip;
		//bmpBg.dispose();

		// BRUSHES
		while(brushes.length>0)brushes.pop().removeMovieClip();

		// BLOCK
		cleanBlocks();

		//LOG
		fieldLog2.text = "";
	}

	//
	override function kill(){
		bmpBg.dispose();
		haxe.Log.clear();
		flash.Key.removeListener(cast kl);
		super.kill();
	}

	// IS_VALID
	function isValid(){
		var flOk = false;
		for(x in 0...Cs.XMAX){
			for(y in 0...Cs.YMAX){
				if( grid[x][y].type == 0 )flOk = true;
			}
		}
		return flOk;
	}

	// TOOLS
	function isIn(x,y){
		return x>=0 && x<Cs.XMAX && y>=0 && y<Cs.YMAX;
	}



//{
}








