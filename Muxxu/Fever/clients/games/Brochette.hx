import mt.bumdum9.Lib;

using mt.deepnight.SuperMovie;

class Brochette extends Game{//}

	// CONSTANTES
	static var SPEED = 24;
	static var MAX = 7;
	static var SY = 46;
	static var DY = 26;
	static var FH = 20;

	// VARIABLES
	var nid:Int;
	var emax:Int;
	var decal:Float;
	var bList:Array<Array<Int>>;
	var fList:Array<flash.display.MovieClip>;
	var cList:Array<flash.display.MovieClip>;

	// MOVIECLIPS
	var pic:flash.display.MovieClip;
	var cache:flash.display.MovieClip;
	var ex:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime = 340-dif*100;
		super.init(dif);
		emax = 3+Math.floor(dif*8);
		if(emax>11)emax = 11;

		bList = new Array();
		for( i in 0...MAX )bList[i]=[Std.random(emax)];

		fList = new Array();
		attachElements();
		zoomOld();
		
	}

	function attachElements(){

		bg = dm.attach("brochette_bg",0);

		// EXEMPLE
		ex = dm.empty(Game.DP_SPRITE2);
		ex.x = 204;
		ex.y = 157;
		var edm = new mt.DepthManager(ex);
		edm.attach("mcBrochette",1);
		for( i in 0...bList.length ){
			var mc = edm.attach("mcBrochetteFood",Game.DP_SPRITE);
			mc.y = -(DY+FH*i);
			mc.gotoAndStop(bList[bList.length-(1+i)][0]+1);
			cast(mc).p.visible = bList.length-1;

		}
		ex.scaleX = 70*0.01;
		ex.scaleY = 70*0.01;
		ex.rotation = -30;

		Col.setPercentColor( ex, 0.5, 0xFDF2D0 );

		// PIC
		pic = dm.attach("mcBrochette",Game.DP_SPRITE2);
		pic.x = Cs.omcw*0.25;
		pic.y = Cs.omch-SY;

		// CACHE
		cache = dm.attach("mcBrochetteCache",Game.DP_SPRITE);
		cache.y = Cs.omch;

		// FOOD

		var ec = Cs.omcw/(emax+0.5);
		for( i in 0...emax ){
			var mc = dm.attach("mcBrochetteFood",Game.DP_SPRITE);
			mc.x = (i+0.75)*ec;
			mc.y = 222;
			mc.scaleX = 80*0.01;
			mc.scaleY = 80*0.01;
			cast(mc).p.visible = false;
			mc.gotoAndStop(i+1);
			
			var me = this;
			//mc.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.select(i); } );
			mc.onClick(function() { me.select(i); });
			mc.handCursor(true);
			
		}




	}

	override function update(){

		switch(step){
			case 1:
			case 2:
				var speed  = SPEED;


				var cy = Num.mm( 0, ((Cs.omch+DY)-pic.y)/speed, 1 );
				moveFoods(speed*cy);

				pic.y += speed;


				if( pic.y > Cs.omch+DY+FH ){
					pic.y = Cs.omch+DY+FH;
					step = 3;
					var mc = dm.attach("mcBrochetteFood",Game.DP_SPRITE2);
					mc.x = pic.x;
					mc.y = Cs.omch+FH;
					mc.gotoAndStop(nid+1);
					cast(mc).p.visible = fList.length==0;
					fList.push(mc);
					//dm.under(mc);
					//dm.under(pic);
				}
				fList.reverse();
				for( mc in fList ) dm.over(mc);
				fList.reverse();

			case 3:
				var speed  = -SPEED;
				pic.y += speed;
				moveFoods(speed);
				if( pic.y < Cs.omch-SY ){
					var dy = (Cs.omch-SY)-pic.y;
					moveFoods(dy);
					pic.y += dy;
					step = 1;

					if(fList.length==MAX){
						var fl = true;
						cList = new Array();
						var i = 0;
						for( o in bList ){
							if(o[0]!=o[1]){
								fl=false;
								cList.push(fList[i]);
							}
							i++;
						}
						setWin(fl,20+(fl?0:10));
						step = 4;
						decal = 0;
					}

				}

			case 4:
				decal = (decal+75)%628;
				for(mc in cList ) {
					var c = 0.6 + Math.cos(decal / 100) * 0.4;
					Col.setPercentColor(mc,c,0xFF0000 );
				}
		}
		super.update();
	}

	function select(id){
		if(step == 1 ){
			bList[fList.length].push(id);
			if(step==1){
				nid = id;
				step = 2;
			}
		}
	}

	function moveFoods(vy){
		for( mc in fList )mc.y += vy;
	}



//{
}











