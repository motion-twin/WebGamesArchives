import mt.bumdum9.Lib;

typedef HamFall = {mc:flash.display.MovieClip,decal:Float,sd:Float,flUp:Bool};

class Hamburger extends Game{//}
	//
	static var RAY = 30;
	static var MAX = 4;

	// CONSTANTES
	var gl:Float;

	// VARIABLES
	var index:Int;
	var timer:Float;
	var fallTimer:Float;
	var fallInterval:Float;
	var speed:Float;
	var speedDecal:Float;
	var hList:Array<{mc:flash.display.MovieClip,dx:Float}>;
	var fList:Array<HamFall>;

	//
	var sun:FxSun;


	override function init(dif){
		gameTime = 650;
		super.init(dif);

		gl = Cs.omch-30;
		speed = 1.5+dif*2.5;
		speedDecal = 3+dif*8;
		fallTimer = 0;
		fallInterval = 35-dif*20;
		index = 0;

		fList = [];
		attachElements();

		zoomOld();


	}

	function attachElements(){

		bg = dm.attach("hamburger_bg",0);

		hList= new Array();
		for( i in 0...2 ){
			var mc = dm.attach("mcHamburger",Game.DP_SPRITE);
			mc.gotoAndStop(11-i*10);
			mc.y = gl;
			hList.push({mc:mc,dx:0.0});
		}





	}

	override function update(){
		switch(step){
			case 1:
				moveAll();

				fallTimer--;
				if( fallTimer < 0 ){
					if(index < MAX ){
						index++;
						fallTimer = fallInterval+Math.random()*fallInterval;
						var dec = Math.random()*628;
						var sd = speedDecal+Math.random()*speedDecal;
						for( i in 0...2 ){
							var mc = dm.attach("mcHamburger",Game.DP_SPRITE);
							mc.gotoAndStop(index+1+i*10);
							mc.y = -20;
							if( i == 1 )dm.under(mc);
							fList.push( { mc:mc, decal:dec, flUp:true, sd:sd } );
						}
					}
				}

				var a = fList.copy();
				for( info in a ){
					var mc = info.mc;
					var h = Cs.omcw*0.5;
					info.decal = (info.decal+info.sd)%628;
					mc.x = Cs.omcw*0.5 + Math.cos(info.decal/100)*((Cs.omcw-RAY*2)*0.42);
					mc.y += speed;
					if( info.flUp && mc.y > gl ){
						mc.y = gl;
						info.flUp = false;
						var last =hList[hList.length-2];
						var dx = last.mc.x-mc.x;
						if( Math.abs(dx) < RAY*0.8 ){
							hList.push({mc:mc,dx:last.dx-dx});
							//fList.splice(i--,1);
							fList.remove(info);
						}
					}
					if(mc.y > Cs.omch )setWin(false,20);

				}
				if( fList.length == 0 && index == MAX ) {
					timer = 0;
					step++;
				}
				
			case 2 :
				centerAll();
				if( timer ++ > 6 ) {
					step++;
					setWin(true, 24);
					new mt.fx.Flash(box, 0.2);
					sun = new FxSun();
					bg.addChild(sun);
					sun.x = Cs.omcw * 0.5;
					sun.y = Cs.omch * 0.5;
					sun.stop();
					
					var max = 120;
					for( i in 0...max ) {
						var p = new mt.fx.Part(new McConfetti());
						p.x = Math.random() * Cs.omcw;
						p.y = Math.random() * Cs.omch;
						Col.setColor(p.root, Col.getRainbow2(Math.random()));
						p.twist(10);
						p.weight = 0.1 + Math.random() * 0.1;
						p.vy = -Math.random() * 3;
						p.frict = 0.97;
						p.updatePos();
						p.root.gotoAndPlay(Std.random(p.root.totalFrames)+1);
						dm.add(p.root, 5);
						p.setScale(0.7);
						
						var dx = p.x - sun.y;
						var dy = p.y - sun.y;
						var a = Math.atan2(dy, dx);
						var speed = Math.max(10 - Math.sqrt(dx * dx + dy * dy) * 0.1, 0);
						p.vx += Math.cos(a) * speed;
						p.vy += Math.sin(a) * speed;
						
					}
					
				}
			case 3 :
				sun.rotation += 3;

		}
		super.update();
	}



	function moveAll(){
		for( info in hList ){
			info.mc.x = Num.mm( RAY, getMousePos().x, Cs.omcw-RAY )+info.dx;
		}
	}
	
	function centerAll() {
		var cx = Cs.omcw * 0.5;
		var cy = Cs.omch * 0.5 + 14;
		var c  = 0.5;
		for( info in hList ) {
			info.mc.x += ((cx+info.dx) - info.mc.x)*c;
			info.mc.y += (cy - info.mc.y)*c;
		}
	}


//{
}



