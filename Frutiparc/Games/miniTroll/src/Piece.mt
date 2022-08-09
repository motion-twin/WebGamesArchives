class Piece{//}

	var flTurn:bool;
	var flSlide:bool;
	var flGround:bool;
	var flBind:bool;
	var flSpeedable:bool;
	
	var fSpeed:float;
	var sSpeed:float;
	var speeder:float;
	var oym:float;
	var x:int;
	var y:int;
	//var dx:int;
	//var dy:int;
	var dRot:float;
	var ta:int;
	var da:float;
	var mouseWay:int;
	var slideWay:int;
	var cx:float;
	var cy:float;
	var groundTimer:float;
	var groundTimerMax:float;
	var list:Array<ElementInfo>;

	var game:Game;
	var base:MovieClip;
	
	function new(g){
		/*
		list = [
			{ x:0, y:0, e:null, mc:null }
			{ x:1, y:0, e:null, mc:null }
			{ x:0, y:1, e:null, mc:null }
		]
		*/
		flBind = false;
		flSpeedable = false;
		game = g
		x = Math.floor(game.xMax/2);
		y = 0;
		cx = 0;
		cy = 0;
		ta = 0;
		flGround = false;
		//flSlide = false;
		flTurn = true;
		slideWay = 0;
		// CONSTANTES
		groundTimerMax = 4
		fSpeed = 0.05
		sSpeed = 0.35
		speeder = 0.75	// 0.5
	}
	
	function init(){
		base = game.dm.empty( Game.DP_SPRITE )
		/*
		for( var i=0; i<list.length; i++ ){
			var o  = list[i];
			var mc = Std.createEmptyMC( base, i );
			mc._x = o.x*game.ts;
			mc._y = o.y*game.ts;
			var token = new sp.el.Token();
			token.setSkin( Std.attachMC( mc, "token", 1 ) );
			token.skin._xscale = token.skin._yscale = game.ts;
			token.setType(game.getColor());
			token.x = -0.5*game.ts;
			token.y = -0.5*game.ts;
			token.update();
			o.e = token;
			o.mc = mc;
		}
		*/
		// DECAL
		
		var xMin = 0
		var xMax = 0
		var yMin = 0
		var yMax = 0	
		for( var i=0; i<list.length; i++ ){
			var ei = list[i]
			xMin = Math.min(xMin,ei.x )
			xMax = Math.max(xMax,ei.x )
			yMin = Math.min(yMin,ei.y )
			yMax = Math.max(yMax,ei.y )		
		}
		//
		var dx = Math.round((xMax-xMin)%2)
		var dy = Math.round((yMax-yMin)%2)
		dRot = Math.min(dx,dy)*0.5
		//
		for( var i=0; i<list.length; i++ ){
			var ei  = list[i];
			var mc = Std.createEmptyMC( base, i );
			mc._x = (ei.x-dRot)*game.ts;
			mc._y = (ei.y-dRot)*game.ts;
			ei.e.setSkin( Std.attachMC( mc, ei.e.link, 1 ) )
			ei.e.setScale(game.ts)
			ei.e.updateSkin();
			ei.e.x = -0.5*game.ts;
			ei.e.y = -0.5*game.ts;
			ei.e.update();
			ei.mc = mc;
			
		}		
		update();
		
	}
	
	function update(){
		//var co = Manager.control
		
		// BOOST
		speeder = 0
		if( !Cm.pref.$mouse && Key.isDown(Cm.pref.$key[3]) || Cm.pref.$mouse && Cs.mch*0.75 < game._ymouse ){	// (oym+1) < game._ymouse
			if(flSpeedable)speeder = 1;
		}else{
			flSpeedable = true;
		}
		
		oym = game._ymouse
		
		
		// FALL
		if(flGround){
			if( !checkActualCanvas(0,1) ){
				groundTimer += Timer.tmod;
				if( ( groundTimer > groundTimerMax || speeder > 0.5 ) && slideWay == 0 ){
					validate();
				}
			}else{
				flGround = false;
			}
		}
		
		if(!flGround){
			cy += (fSpeed+speeder)*Timer.tmod;
			var n = Math.floor(cy)
			cy = cy%1
			while(n>0){
				y++;
				if( !checkActualCanvas(0,1) ){
					flGround = true
					cy = 0
					groundTimer = 0
					break;
				}else{
					n--
				}
			}
		}
		
		// TURN
		if( ( !Cm.pref.$mouse && Key.isDown(Cm.pref.$key[2]) ) ||  ( Cm.pref.$mouse && Manager.flPress )  ){
			if(flTurn){
				flTurn = false;
				if( !flBind ){
					turn(1)
					if( !checkActualCanvas(0,0) ){
						turn(-1)
					}else{
						ta = (ta+90)%360
					}
				}else{
					base._rotation = 30
				}
			}
		}else{
			flTurn = true;
		}
		da = ta - base._rotation
		while(da>180)da-=360;
		while(da<-180)da+=360;
		if(Math.abs(da)>0.5){
			base._rotation += da*Math.min(0.5*Timer.tmod,1)
			for( var i=0; i<list.length; i++ ){
				var mc = list[i].mc
				mc._rotation = -base._rotation
			}
		}
		
		// SLIDE
		slide();
		
		// MOVE
		base._x = Cs.game.marginLeft+(x+cx+0.5+dRot)*game.ts
		base._y = Cs.game.marginUp+(y+cy+0.5+dRot)*game.ts

	}
	
	function turn(sens){
		for( var i=0; i<list.length; i++ ){
			var o = list[i]
			var x = o.x-dRot;
			var y = o.y-dRot;
			var nx = -y*sens
			var ny = x*sens
			o.x = Math.round(nx + dRot)
			o.y = Math.round(ny + dRot)
		}
	}
	
	function slide(){

		if( slideWay == 0 ){
			checkSlide();

		}		
		
		
		if( slideWay !=0 ){
			var lim = 0.8
			cx += Cs.mm(-lim,sSpeed*slideWay*Timer.tmod,lim)
			
			while( Math.abs(cx) >= 1 ){

				x += slideWay
				cx -= slideWay

				var sens = slideWay
				checkSlide();

				if( slideWay != sens ){
					cx=0;
					slideWay = 0
					return
				}

			}
		}		

			
	}
	
	function checkSlide(){
		var sens = getSens();
		if( sens!=0 && checkActualCanvas(sens,0) && ( !flGround || groundTimer < groundTimerMax ) ){
			
			slideWay = sens;
		}else{
			slideWay = 0
		}
		//return false;
		
	};
	
	function getSens(){
		//var co  = Manager.control
		switch(Cm.pref.$mouse){
			case false:
				if(Key.isDown(Cm.pref.$key[0])) return -1;
				if(Key.isDown(Cm.pref.$key[1])) return 1;
				return 0;
			case true:
				var dx = game._xmouse -  base._x
				var ax = Math.abs(dx)
				var sens = 0
				if( ax > game.ts*0.5 ){
					return int(ax/dx);
				}
				return 0;
		}
		return 0;	
		
	}
		
	function checkCanvas(x,y){
		for( var i=0; i<list.length; i++ ){
			var o = list[i]
			var px = o.x+x;
			var py = o.y+y;
			if( !game.isFree(px,py) ){
				return false;
			}
		}
		return true;
	}
	
	function checkActualCanvas(dx,dy){
		for(var nx=Math.floor(x+cx)+dx; nx<=Math.ceil(x+cx)+dx; nx++){
			for(var ny=Math.floor(y+cy)+dy; ny<=Math.ceil(y+cy)+dy; ny++){
				if( !checkCanvas(nx,ny) ) return false;
			}		
		}
		return true;
	}
		
	function validate(){
		for( var i=0; i<list.length; i++ ){
			var ei = list[i];
			ei.e.px = x + ei.x;
			ei.e.py = y + ei.y;
			ei.e.game = game;
			ei.e.init();
		};
		game.onPieceValidate();
		base.removeMovieClip();
	}

	
	
	
	
	
	
	
	
	
	
	
	
//{	
}











