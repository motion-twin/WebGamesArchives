import mt.bumdum9.Lib;

class Tunnel extends Game{//}

	static var CS = 10;
	static var COL_MAX = 10;

	//var probaPlat:Int;

	var cycle:Float;
	var space:Float;
	var mod:Float;
	var pos:Int;
	var speed:Int;
	var cols:Array<Array<Null<Int>>>;
	var lvl:flash.display.BitmapData;
	var hero:Phys;
	var scroll:Array<Phys>;
	var bgScrollA:flash.display.MovieClip;
	var bgScrollB:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime =  320;
		super.init(dif);
		timeProof= true;
		mod = 0;
		pos = 0;
		speed = 3;
		space = 10-dif*2;
		cycle = 0;
		scroll = [];

		attachElements();

		//var a:Array<Null<Int>>;
		//a = [0];
		//trace(a[-1]);

	}

	function attachElements(){



		box.scaleX = box.scaleY = 4;
		bg = dm.attach("tunnel_bg",0);

		// SCROLL
		bgScrollA = dm.attach("tunnel_scrollA",0);
		bgScrollB = dm.attach("tunnel_scrollB",0);

		// LEVEL
		lvl = new flash.display.BitmapData(100+CS,100,true,0);
		//dm.empty(1).attachBitmap(lvl,0);
		dm.empty(0).addChild(new flash.display.Bitmap(lvl));
		cols = [];
		while(cols.length<11)newCol();




		// HERO
		hero = newPhys("tunnel_hero");
		hero.x = 2.5*CS;
		hero.y = 50;
		hero.weight = 0.1;
		hero.frict = 0.98;
		hero.vy = -2;

		hero.updatePos();


	}

	override function update(){

		space -= 0.01 + 0.03*dif;
		if( space < 2 ) space = 2;

		pos += speed;
		lvl.scroll(-speed,0);
		while( pos > CS ){
			pos-=CS;
			cols.shift();
			newCol();

		}

		updateHero();

		updateScroll();

		if( gameTime == 0 )setWin(true);

		super.update();
	}

	// LEVEL
	function newCol(){


		mod += 0.2;
		if( Std.random(6) == 0 ) mod += 0.5*dif;

		// GET LAST
		var last:Array<Null<Int>>;
		if( cols.length > 0 ){
			last = cols[cols.length-1];
		}else{
			last = [];
			for( i in 0...COL_MAX ) last.push(0);
		}
		var col:Array<Null<Int>> = last.copy();

		// MODIFY
		while( mod>=1 ){
			mod--;

			var actualSpace = 0;
			for( n in col ) if(n==0)actualSpace++;
			var dif = actualSpace - space;

			// REMOVE
			if( Math.random()*2-1 > dif ){
				var swap = getSwapPos(col,0);
				var y = swap[Std.random(swap.length)];
				col[y] = 0;
			}

			// ADD
			if( Math.random()*2-1 < dif ){
				var swap = getSwapPos(col,1);
				var y = swap[Std.random(swap.length)];
				col[y] = 1;
			}

		}

		// DRAW
		var brush = dm.attach("tunnel_block",0);

		var x = cols.length*CS - pos ;
		lvl.fillRect(new flash.geom.Rectangle(x,0,x+CS,100), 0 );

		for( y in 0...10 ){
			if( col[y] == 1 ){
				var m = new flash.geom.Matrix();
				m.translate(x,y*CS);
				brush.gotoAndStop(Std.random(brush.totalFrames)+1);
				lvl.draw(brush,m);
			}

		}
		brush.parent.removeChild(brush);

		// PUSH
		cols.push(col);
	}
	function getSwapPos(col,type:Int){
		var a = [];
		for( y in 0...COL_MAX ){
			var prev2:Null<Int> = col[y-2];
			var prev:Null<Int> = col[y-1];
			var now:Null<Int> = col[y];
			var next:Null<Int> = col[y+1];
			var next2:Null<Int> = col[y+2];

			
			switch(type){
				case 0 : // removable
					if( now == 1 && ( prev==0 || next==0 ) ){
						a.push(y);
					}
				case 1 : // addable
					var surprise = cols.length > 9 && Std.random(15) == 0 && dif > 0 && space > 5-dif*2;
 					if( now == 0 && ( (prev==1 && prev2!=0) || (next==1&&next2!=0) || prev == null || next == null || surprise ) ){
						a.push(y);
					}
			}
		}
		return a;
	}

	// HERO
	function updateHero(){

		if(hero==null)return;

		// CONTROL
		//var mp = getMousePos();
		//hero.x = (0.5+3*(mp.x/Cs.mcw))*CS;
		hero.root.gotoAndStop(2);
		if( click ){
			hero.vy -= 0.18;
			hero.root.gotoAndStop(1);
		}


		// COLLISION
		var px = Std.int( ( hero.x+pos - 0.5 ) 	/ CS );
		var py = Std.int( ( hero.y - 0.5 ) 	/ CS );

		if( cols[px][py] == 1 || hero.y < -CS || hero.y > 100+CS ){

			// PARTS
			var max = 24;
			for( i in 0...max ){
				var a = (i+Math.random())/max * 6.28;
				var speed = Math.random()*1.5;
				var cr = 2;
				var p = newPhys("tunnel_debris");
				p.vx = Math.cos(a)*speed+Math.random()*2;
				p.vy = Math.sin(a)*speed;
				p.x = hero.x + p.vx*cr;
				p.y = hero.y + p.vy*cr;
				p.timer = 10 + Std.random(10);
				p.fadeType = 0;
				p.weight = 0.05+Math.random()*0.05;
				p.root.gotoAndStop(Std.random(2)+1);
				scroll.push(p);
			}

			//
			hero.kill();
			hero = null;
			setWin(false, 10);
			fxShake(32);
		}

		if( hero == null ) return;
		
		// QUEUE
		return;
		Filt.glow(hero.root,2,4,0xFFFFFF);
		cycle = (cycle+0.04)%1;
		var col = Col.colToObj(Col.getRainbow(cycle));
		var cm = new flash.geom.ColorTransform(0,0,0,1,col.r,col.g,col.b,0);
		var m = new flash.geom.Matrix();
		 m.translate(hero.x,hero.y);
		lvl.draw(hero.root,m,cm);
		hero.root.filters =[];

	}

	//
	function updateScroll(){
		// SCROLL
		for( p in scroll ){
			p.x -= speed;
			p.x = Std.int(p.x);
			p.y = Std.int(p.y);
		}

		bgScrollA.x -= speed*0.25;
		bgScrollB.x -= speed*0.5;
		if(bgScrollA.x < -100 ) bgScrollA.x += 100;
		if(bgScrollB.x < -100 ) bgScrollB.x += 100;
	}

//{
}

























