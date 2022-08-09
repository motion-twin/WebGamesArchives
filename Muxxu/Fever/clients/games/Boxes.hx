import Protocole;

class Boxes extends Game{

	var cycle : Int;
	var ocycle : Int;
	var baseCycle : Int;
	var boxes : List<Phys>;
	var elements : List<Phys>;
	var speed : Int;
	var crusher : flash.display.MovieClip;
	var chain1 : flash.display.MovieClip;
	var chain2 : flash.display.MovieClip;
	var clicked : Bool;
	var reverseClicked : Bool;
	var tempo : Int;
	var choice : Int;
	
	override function init(dif : Float) {
		gameTime = 320;
		super.init(dif );
		clicked = false;
		reverseClicked = false;
		speed = -3 - Math.ceil( dif * 6 );
		ocycle = cycle = baseCycle = 35 - Math.ceil( dif * 20 );
		elements = new List();
		boxes = new List();
		attachElements();
		tempo = 2;
	}

	function attachElements() {
		bg = dm.attach("mcBoxesClouds", 1 );
		var bg2 = dm.attach("mcBoxesBg", 3 );
		var bg2ss = getSmc(getSmc(bg2));
		
		choice = Std.random(bg2ss.totalFrames)+1;
		bg2ss.gotoAndStop(choice);
//		var top = dm.attach("mcBoxesTop", 6 );
		chain1 = dm.attach("mcBoxesChain", 5 );
		chain1.alpha = 0.8;
		crusher = dm.attach("mcBoxesCrusher", 5 );
		chain2 = dm.attach("mcBoxesChain", 5 );
		chain1.scaleY = 0.6;
		chain1.x = 0;
		chain2.x = 400;
		chain1.y = 3;
		chain2.y = 12;
		crusher.gotoAndStop(1);
		var tapis = dm.attach("mcBoxesTapis", 3);
		tapis.y = 370;
		
		
	}

	override function update() {
		
		if( !clicked ) {
			var pos = getMousePos().x;
			var dif = (crusher.x - pos) * 0.7;
			chain1.x -= dif;
			chain2.x += dif;
			crusher.x = getMousePos().x;
		}
		
		switch( step ) {
			case 1 :
				for (b in boxes ) {
					if( b.root.x + b.root.width < -2 ) {
						var mcc = getSmc(b.root);
						if(mcc!=null ) mcc = getSmc(mcc);
						if( mcc!= null && mcc.currentFrame == choice ) {
							setWin(false,20);
						}
						b.kill();
						boxes.remove(b);
					}
				}

				if( cycle-- < 0 ) {
					var mc = dm.attach("mcBoxesBox",5);
					mc.x = Cs.mcw;
					mc.y = 376 + Std.random(5) * if(Std.random(2)==0) 1 else -1;
					mc.gotoAndStop(1);
					var mcc = getSmc(getSmc(mc));
					var c = if( Std.random(2)==0 ) choice else Std.random(mcc.totalFrames)+1;
					mcc.gotoAndStop( c);
					var a = new Phys( mc);
					a.vx = speed;
					boxes.add( a );
					cycle = baseCycle;

					if( Std.random(5) == 0 ) {
						var mce = dm.attach("mcBoxesElements",3);
						mce.gotoAndStop( Std.random(mce.totalFrames)+1);
						mce.x = mc.x + mc.width + 15;
						mce.y = 366;
						var a = new Phys( mce);
						a.vx = speed;
						elements.add( a );
						ocycle = Std.random(5 );
					}
						
				}


				if( clicked ) {
					var cur = crusher.currentFrame;
					if( !reverseClicked )
						crusher.gotoAndStop(cur+4);

					var crux = crusher.x - 45;
					if( cur >= crusher.totalFrames ) {
						if( !reverseClicked ) {
							reverseClicked = true;
							for( b in boxes ) {
								if( b.x + b.root.width >= crux && ( b.x + b.root.width < crusher.x + 70 ) ){
									//dm.swap( b.root, 4);
									var mcc = getSmc(b.root);
									if( mcc != null ) mcc = getSmc(mcc);
									if( mcc!=null && mcc.currentFrame != choice && b.root.currentFrame == 1) {
										setWin(false);
									}
									b.root.gotoAndStop(2);
								}
								addShadow( crusher.x);
							}
						}
					} else {
						for( b in boxes ) {
							if( b.x >= crusher.x + 17 ) {
								//dm.swap( b.root, 5);
							} else {
								//dm.swap( b.root, 4);

							}
						}
					}
					if( reverseClicked ) {
						if( tempo-- <= 0 ) {
							crusher.gotoAndStop(cur-6);
							if( cur <= 6 ) {
								tempo = 2;
								reverseClicked = false;
								clicked = false;
								crusher.gotoAndStop(1);
							}
						}
					}
				}
		}

		xSortAll();
		
		super.update();
	}

	function xSortAll() {
		var a:Array<flash.display.Sprite> = [];
		for( o in boxes ) a.push(cast o.root);
		a.push( cast crusher );
		a.sort(xSort);
		for( mc in a ) 	dm.over(mc);
		
	}
	function xSort(a:flash.display.Sprite, b:flash.display.Sprite) {
		if( a.x > b.x ) return 1;
		return -1;
	}
	
	
	function addShadow(x) {
		var mce = dm.attach("mcBoxesShadow",3);
		mce.x = x;
		mce.y = 365;
		var a = new Phys( mce);
		a.vx = speed;
		elements.add( a );
		fxShake(5);
	}

	override function outOfTime() {
		setWin(true);
	}

	override function onClick() {
		if( clicked ) return;
		clicked = true;
	}
}
