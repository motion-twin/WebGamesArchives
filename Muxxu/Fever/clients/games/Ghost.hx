class Ghost extends Game{//}

	// CONSTANTES

	// VARIABLES
	var decal:Float;
	var blob:Float;

	// MOVIECLIPS
	var ghost:Phys;
	var bubble:Phys;
	var s1:flash.display.MovieClip;
	var s2:flash.display.MovieClip;
	var mesh:flash.display.MovieClip;

	override function init(dif){
		gameTime = 340;
		super.init(dif);
		blob = 0;
		decal = 0;
		attachElements();
		zoomOld();


	}

	function attachElements(){
		// MESH
		//mesh = dm.attach("ghost.mesh",0);

		bg = dm.attach("ghost_bg",Game.DP_SPRITE);
		s1 = Reflect.field(bg,"_s1");
		s2 = Reflect.field(bg,"_s2");
		mesh = Reflect.field(bg,"_mesh");



		// GHOST
		ghost = newPhys("mcGhost");
		ghost.x = Cs.omcw-10;
		ghost.y = Cs.omch*0.5;
		ghost.root.stop();
		ghost.updatePos();

		// BUBBLE
		bubble = newPhys("mcGhostBubble");
		bubble.x = Cs.omcw-24;
		bubble.y = Cs.omch*0.5;
		bubble.weight = 0.004;
		bubble.updatePos();

		// STALACTITES
		var frame = Std.string( 1+Math.floor(dif*10) );
		s1.gotoAndStop(frame);
		s2.gotoAndStop(frame);

	}


	override function update(){

		switch(step){
			case 1: // GAME
				moveGhost();
				moveBubble();
		}
		//
		super.update();
	}


	function moveGhost(){
		var m = getMousePos();

		// MOVE
		var dx = ghost.x - m.x;
		var dy = ghost.y - m.y;
		ghost.x -= dx*0.1;
		ghost.y -= dy*0.1;

		// LOOK
		var dist = ghost.getDist(bubble);
		var focus:{x:Float,y:Float} = null;
		if( dist < 80 ){
			focus = cast bubble;
		}else{
			focus = { x:m.x, y:m.y };
		}
		var sens = (focus.x < ghost.x)?-1:1;

		dx = ghost.x - focus.x;
		dy = ghost.y - focus.y;

		ghost.root.scaleX = sens;
		ghost.root.rotation = Math.atan2(dy,dx)/0.0174 + ((sens*0.5)+0.5)*180;

		// BLOW
		if( click ){
			ghost.root.gotoAndStop("2");
			if( dist < 80 ){
				var c = 1-(dist/80);
				var a = ghost.getAng(bubble);
				bubble.vx += Math.cos(a)*c*0.1;
				bubble.vy += Math.sin(a)*c*0.1;
				blob += 0.02*c;
			}
		}else{
			ghost.root.gotoAndStop("1");
		}

		// ALPHA
		var alpha = 1;
		if( isIn( ghost.x, ghost.y) )	alpha = 0;
		var da = alpha - ghost.root.alpha;
		ghost.root.alpha = Math.min(Math.max(0.2,ghost.root.alpha+da*0.15),1);

	}

	function moveBubble(){

		// BLOB
		decal = (decal+(16+blob*0))%628;
		blob *= 0.95;
		var c = 1+Math.cos(decal/100)*blob;
		bubble.root.scaleX = c;
		bubble.root.scaleY = c;

		if( bubble.x < 0 )setWin(true,10);

		// HIT
		if( isIn( bubble.x, bubble.y) ){
			bubble.root.play();
			bubble.vx = 0;
			bubble.vy = 0;
			setWin(false, 10);
			step = 2;
		}
	}

	function isIn(x:Float,y:Float){
		//var ratio = Cs.mcw/240;
		//x *= ratio;
		//y *= ratio;
		
		var pos  = new flash.geom.Point(x, y);
		pos = mesh.localToGlobal(new flash.geom.Point(x, y));
		x = pos.x;
		y = pos.y;
		return !mesh.hitTestPoint(x,y,true) || s1.hitTestPoint(x,y,true) || s2.hitTestPoint(x,y,true);
	}



//{
}


















