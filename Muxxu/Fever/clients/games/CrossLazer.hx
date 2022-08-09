import mt.bumdum9.Lib;

typedef CrossLine = {>flash.display.MovieClip,vr:Float};
typedef CrossBp = {>Phys,cs:Float,z:Float};
typedef CrossLaz= {>flash.display.MovieClip,t:Float};

class CrossLazer extends Game{//}

	// CONSTANTES
	static var ALPHA = 0.7;

	// VARIABLES
	var flTest:Bool;

	var decal:Float;
	var timer:Null<Float>;
	var mdy:Float;
	var blackPrc:Null<Float>;

	var lineList:Array<CrossLine>;

	var lazerList:Array<CrossLaz>;
	var bpList:Array<CrossBp>;

	// MOVIECLIPS
	var hori:{>flash.display.MovieClip,field:flash.text.TextField};
	var verti:{>flash.display.MovieClip,field:flash.text.TextField};
	var mire:flash.display.MovieClip;
	var bad:flash.display.MovieClip;

	override function init(dif){
		gameTime = 200;
		super.init(dif);

		flTest = false;
		mdy = 0;
		decal = 0;
		attachElements();
		bpList = new Array();
		lineList = new Array();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("crossLazer_bg",0);


		var m = 50;
		bad = dm.attach("mcCrossBad",Game.DP_SPRITE2);
		bad.x = m + Math.random()*(Cs.omcw-2*m);
		bad.y = m + Math.random()*(Cs.omch-2*m);
		bad.scaleX = 0.8-dif*0.5;
		bad.scaleY = bad.scaleX;

		hori = cast dm.attach("mcCrossHoriLine",Game.DP_SPRITE);
		hori.alpha = ALPHA;


	}

	override function update(){
		moveMonster();
		switch(step){
			case 1:
				updateDecal();

				hori.y = (Math.cos(decal/100)+1)*Cs.omch*0.5;
				hori.field.text = "y:"+getStringNum(hori.y);

			case 2:
				updateDecal();
				verti.x = (Math.cos(decal/100)+1)*Cs.omcw*0.5;
				verti.field.text = "x:"+getStringNum(verti.x);

				mire.x = verti.x;
				mire.y = hori.y;

			case 3:

				for( mc in lazerList ){
					mc.t--;
					if(mc.t<0){
						mc.scaleX *= 0.8;
						mc.scaleY = mc.scaleX;
						if( mc.scaleX < 0.02 && !flTest )	hit();
					}
				}

				if(timer!=null){
					timer--;
					if( timer < 0 ){
						setWin(true,20);
						timer = null;
					}
				}

				for(  p in bpList ){
					p.z *= p.cs;
					p.root.scaleX = p.scale*p.z;
					p.root.scaleY = p.scale*p.z;
					var prc = Num.mm( 0, 100-Math.pow(p.z,1)*100, 100 );
					Col.setPercentColor(p.root,prc*0.01,0x333399);

				}

				// LINE
				var a = lineList.copy();
				for( mc in a ){
					mc.rotation += mc.vr;
					mc.scaleY *= 0.75;
					if( mc.scaleY < 0.05 ){
						mc.parent.removeChild(mc);
						lineList.remove(mc);
					}
				}

				// BLACK
				if(blackPrc!=null){
					Col.setPercentColor(bg,blackPrc*0.01,0x000000);
					blackPrc *= 0.5;
				}


		}
		//
		super.update();
	}

	function moveMonster(){
		mdy = (mdy+20)%628;
		bad.y += Math.cos(mdy/100)*bad.scaleX;

		bad.scaleX *= 1.003;
		bad.scaleY = bad.scaleX;
	}

	function blastMonster(){

	
		
		// LINE
		for( i in 0...10 ){
			var mc:CrossLine = cast dm.attach("mcCrossRay",Game.DP_SPRITE2);
			mc.x = bad.x;
			mc.y = bad.y;
			mc.rotation = Math.random()*360;
			mc.scaleY = 0.8+Math.random()*3;
			mc.vr = (Math.random()*2-1)*1.5;
			lineList.push(mc);
		}

		// PART
		var max = 28;
		for( i in 0...max ){
			var p:CrossBp = cast newPhys("mcCrossBadPart");
			p.x = bad.x;
			p.y = bad.y;
			p.z = 1;
			p.scale = bad.scaleX * ( 1 + (Math.random()*2-1)*0.2 );


			var a = Math.random()*6.28;
			var sp  = 1+Math.random()*4;

			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			//p.vr = (Math.random()*2-1)*8

			p.cs = 1 + ((i/max)*2-1)*0.05;
			p.weight = 0;

			p.updatePos();
			p.root.rotation = Math.random() * 500;
			var mc = getMc(p.root, "p");
			if( mc != null ) mc.gotoAndPlay(Std.random(2)+1);

			
			bpList.push(p);
		}

		// ONDE
		var onde = dm.attach("mcCrossOnde",Game.DP_SPRITE2);
		onde.x = bad.x;
		onde.y = bad.y;



		// DESTROY
		bad.gotoAndPlay("death");
		blackPrc = 100;

		//
		
		hori.parent.removeChild(hori);
		verti.parent.removeChild(verti);
		mire.parent.removeChild(mire);


	}

	function updateDecal(){
		var sp = 8+dif*16;
		decal = (decal+sp)%628;
	}

	override function onClick(){
		switch(step){
			case 1:
				step = 2;
				verti = cast dm.attach("mcCrossVertiLine",Game.DP_SPRITE);
				mire = dm.attach("mcCrossMire",Game.DP_SPRITE);
				verti.alpha = ALPHA;
				mire.alpha = ALPHA;

			case 2:
				step = 3;
				lazerList = new Array();
				for( i in 0...12 ){
					var x = verti.x+(Math.random()*2-1)*3;
					var y = hori.y+(Math.random()*2-1)*3;
					var rot = Math.random()*360;
					for( n in 0...3){
						var mc:CrossLaz = cast dm.attach("mcCrossLazer",Game.DP_SPRITE2);
						mc.x = x;
						mc.y = y;
						mc.rotation = rot;
						mc.t = n*6;
						lazerList.push(mc);
					}
					//mc.scaleX = mc.scaleY = 100+Math.random()*200

				}
				timeProof = true;
		}
	}

	function hit(){
		flTest = true;
		if( shapeHitTest( verti.x, hori.y ) ){
			blastMonster();
			timer = 20;
		}else{
			setWin(false,20);
		}

	}

	function shapeHitTest(x:Float,y:Float){
		var dx = x - bad.x;
		var dy = y - bad.y;
		var ray = bad.scaleX*30;
		var dist = Math.sqrt(dx*dx+dy*dy);
		return dist<ray;
	}


	function getStringNum(n){
		var base = Std.string(Std.int(n));
		while(base.length<3)base = "0"+base;
		return base+"."+Std.random(10);
	}






//{
}










