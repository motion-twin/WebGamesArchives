import mt.bumdum9.Lib;
class Tubulo extends Game{//}

	// CONSTANTES

	// VARIABLES
	var flCheck:Bool;
	var xMax:Int;
	var yMax:Int;
	var size:Int;
	var decal:Float;
	var tubeList:Array<Array<{mc:Sprite,id:Int,p:Float,tp:Null<Int>}>>;
	var moveList:Array<flash.display.MovieClip>;
	var can:Array<{x:Int,y:Int}>;

	// MOVIECLIPS

	override function init(dif){
		gameTime = 360;
		super.init(dif);
		xMax = 4;
		yMax = 4;
		size = 40;
		can = [
			{ x:0, y:0 },
			{ x:1, y:0 },
			{ x:0, y:1 },
			{ x:-1, y:0 },
			{ x:0, y:-1 }
		];
		initPuzzle();
		attachElements();
		zoomOld();
	}

	function initPuzzle(){

		tubeList = new Array();
		for( x in 0...xMax ){
			tubeList[x] = [];
			for( y in 0...yMax )tubeList[x].push({id:0,mc:null,p:100.0,tp:null});
		}
		shuffle();

	}

	function shuffle(){
		var max = 1+Math.round(dif*8);
		for( i in 0...max ){
			var x = Std.random(xMax);
			var y = Std.random(yMax);
			for( cn in can){
				var cx = x + cn.x;
				var cy = y + cn.y;
				if( isIn(cx, cy) ) {
					var info = tubeList[cx][cy];
					info.id = (info.id+2)%3;
				}
			}
		}
	}
	function isIn(x,y) {
		return x >= 0 && x < xMax && y >= 0 && y < yMax ;
	}
	

	function attachElements(){

		dm.attach("tubulo_bg",0);

		var bx = Cs.omcw*0.5;
		var by = Cs.omch*0.5 - size*(yMax+xMax)*0.125;

		for( x in 0...xMax ){
			for( y in 0...yMax ){
				var mc = newSprite("mcTube");
				var slot = tubeList[x][y];
				mc.x = bx + x*size*0.5		+ 	y*(-size*0.5);
				mc.y = by + x*size*0.4		+ 	y*size*0.4;
				mc.root.scaleX =  size*0.01;
				mc.root.scaleY =  size*0.01;
				getMc(mc.root,"tube").gotoAndStop(slot.id+1);
				mc.updatePos();
				initTube(mc,x,y);
			}
		}
	}

	function initTube(mc,x,y){
		tubeList[x][y].mc = mc;
		var me = this;
		mc.root.addEventListener( flash.events.MouseEvent.CLICK, 		function(e) { me.select(x, y); } );
		mc.root.addEventListener( flash.events.MouseEvent.ROLL_OVER, 	function(e) { me.setColor(x, y, 70); } );
		mc.root.addEventListener( flash.events.MouseEvent.ROLL_OUT, 	function(e) { me.setColor(x, y, 100); } );
		mc.root.addEventListener( flash.events.MouseEvent.MOUSE_OUT,	function(e) { me.setColor(x, y, 100); } );
		
		/*
		mc.root.onPress = callback(select,x,y);
		mc.root.onRollOver = callback(setColor,x,y,70);
		mc.root.onRollOut = callback(setColor,x,y,100);
		mc.root.onDragOut = mc.root.onRollOut;
		*/



	}

	function select(x,y){
		if(step==2)return;
		moveList = new Array();
		step = 2;
		decal = 0;
		flCheck = true;
		for( cn in can) {
			var cx = x + cn.x;
			var cy = y + cn.y;
			if( !isIn(cx, cy) ) continue;
			var info = tubeList[cx][cy];
			moveList.push(info.mc.root);
			info.id = (info.id+1)%3;

		}
	}

	function setColor(x,y,p){
		for( cn in can) {
			var cx = x + cn.x;
			var cy = y + cn.y;
			if( isIn(cx,cy) )	tubeList[cx][cy].tp = p;
		}

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				checkLight();

			case 2:
				checkLight();
				decal += 40;
				if( decal > 314 ){
					step = 1;
					decal = 314;
				}
				

				for( i in 0...moveList.length){
					var mc:flash.display.MovieClip = cast(moveList[i]);
					getMc(mc,"tube").y = Math.sin(decal/100)*size*2;

				}
				if( flCheck && decal > 157 ){
					checkColor();
					flCheck = false;
				}



		}
		//

	}

	function checkLight(){
		for( x in 0...tubeList.length ){
			for(y in 0...tubeList[x].length ){	// y
				var info = tubeList[x][y];
				if( info.tp != null ){
					var dif = info.tp - info.p;
					info.p += dif*0.2;
					Col.setPercentColor(info.mc.root,1-info.p*0.01,0xFFFFFF);
				}
			}
		}
	}

	function checkColor(){
		var win = true;
		for( x in 0...tubeList.length ){
			for(y in 0...tubeList[x].length ){
				var info = tubeList[x][y];
				getMc(info.mc.root,"tube").gotoAndStop(info.id+1);
				if( info.id != 0 )win = false;
			}
		}
		if(win) {
			setWin(true, 50);
			for( a in tubeList ) for( t in a ) {
				t.mc.root.mouseEnabled = false;
				t.mc.root.mouseChildren = false;
			}
		}
	}





//{
}

