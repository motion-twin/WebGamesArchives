import mt.flash.Volatile;
import api.AKProtocol;

typedef BMC = {> MC,
	_blink : Null<MC>,
	_hili: MC
}

class Block {
	public var x : Volatile<Int>;
	public var y : Volatile<Int>;
	public var id : Volatile<Null<Int>>;

	public var sp : SP;
	public var mc : BMC;
	public var bmp : BMP;

	public var grouped : Bool;
	
	public var fxShine : Null<fx.Shine>;
	public var prizeToken : Null<SecureInGamePrizeTokens>;

	public function new( x, y, delay: Null<Int>, ?speed : Float ){
		this.x = x;
		this.y = y;
		this.grouped = false;

		var useTuto = false;
		this.id = Game.me.seed.random( Game.MAX_ID.get() );
		if( Game.me.tuto != null ){
			for( step in 0...Game.TUTO_POS.length ){
				var arr = Game.TUTO_POS[step];
				if( arr == null )
					continue;
				for( pos in arr ){
					if( pos[0] == x && pos[1] == y ){
						id = step;
						useTuto = true;
						break;
					}
				}
			}
		}
		
		if( !useTuto ){
			var a = Game.me.filteredPrizeTokens();
			var isCorner = (x==0 || x==Game.GRID_SIZE.get()-1) && (y==0 || y==Game.GRID_SIZE.get()-1);
			if( !isCorner && a.length > 0 ){
				var leftPlay = Game.me.gTimer / Game.TIMER_PKPROBA_PLAY.get();
				var proba = Math.ceil( leftPlay * Game.me.emptyCells / a.length );

				if( Game.me.seed.random(proba) == 0 ){
					prizeToken = Game.me.getPrizeToken();
					id = null;
				}
			}
		}

		draw(delay,speed);
	}

	public function draw( delay : Null<Int>, ?speed : Null<Float> ){
		remove();

		sp = new SP();
		
		mc = cast grouped ? new gfx.Blocks2() : new gfx.Blocks();
		if( prizeToken != null ){
			mc.gotoAndStop( prizeToken.frame+5 );
		}else{
			mc.gotoAndStop( id+1 );
		}

		if( mc._blink != null ){
			mc._blink.stop();
			mc._blink.visible = false;
		}
		mc._hili.visible = false;
		bmp = Game.flatten( mc );

		sp.addChild( bmp );
		sp.addChild( mc );
		mc.visible = false;

		var c = center();
		sp.x = c.x;
		sp.y = c.y;
		Game.me.dm.add(sp,Game.DP_BLOCKS);
		Game.me.dm.ysort( Game.DP_BLOCKS );

		if( delay != null ){
			sp.scaleX = sp.scaleY = 0;
			if( speed == null ) speed = 0.1;
			new mt.fx.Sleep( new mt.fx.Grow(sp,speed,1), delay );
		}

		return sp;
	}
	
	public function group( g : Group, delay: Int ){
		if( grouped )
			throw "already grouped";

		id = g.id;
		grouped = true;
		Game.me.gblocks.add( this );
		Game.me.swapingBlocks++;

		unblink();
		var fx = new FxSwap(sp, function() return draw(null));
		fx.onFinish = function(){
			Game.me.swapingBlocks--;
		}
		new mt.fx.Sleep(fx, null, delay );
	}

	public function destroy(){
		Game.me.grid[x][y] = null;

		mc.visible = false;

		var f = new mt.fx.FadeTo(sp,0.3,0,0xFFFFFF);
		f.onFinish = function(){
			var f = new mt.fx.FadeTo(sp,0.03,0,0x0);
			f.onFinish = remove;
			
			for( i in 0...2 ){
				var p = Game.me.createPart(new PT(sp.x,sp.y),1);
				p.timer = 50;
				p.weight = 0.4;
			}
		}
	}

	public function gather( g : Group, delay : Int ){
		Game.me.grid[x][y] = null;

		mc.visible = false;

		var f = new mt.fx.FadeTo(sp,0.07,0,0xFFFFFF);
		f.curveIn(2);
		f.onFinish = function(){
			for( i in 0...2 ){
				var p = Game.me.createPart( center(), 1 );
				p.vy += -1.5;
				p.weight = 0.16;
				p.timer = 30 + Game.me.fxSeed.random(10);
			}
			var f = new mt.fx.Vanish(sp,8,8,true);
			f.onFinish = function(){
				var p = Game.me.createPart( center(), 3 );
				p.weight = -0.05;
				remove();
			};
		};

		var s = new mt.fx.Sleep( f, onGather, delay );
	}

	function onGather(){
		if( prizeToken != null ){
			api.AKApi.takePrizeTokens( prizeToken );
			var s = prizeToken.amount.get()==1 ? Text.pk1 : Text.pk({_x: prizeToken.amount.get()});
			var c = center();
			Game.me.showText( s, -1, c.x, c.y, 11 );
		}
	}

	public function mouseOver(){
		if( !grouped ){
			if( prizeToken == null )
				over();
			return;
		}
		for( b in Game.me.gblocks )
			b.over();
		return;
	}

	public function mouseOut(){
		if( !grouped )
			return out();
		for( b in Game.me.gblocks )
			b.out();
		return;
	}

	public function over(){
		mc.visible = true;
		mc._hili.visible = true;
		mc._hili.alpha = 1;
		new fx.Alpha( mc._hili, 0.5, 0.6 );
	}

	public function out(){
		var f = new fx.Alpha(mc._hili,0,0.2);
		f.curveIn(2);
		f.onFinish = function(){
			mc.visible = false;
			mc._hili.visible = false;
		}
	}

	public function blink(){
		if( grouped )
			return;
		if( !mc._blink.visible ){
			mc.visible = true;
			mc._blink.visible = true;
			mc._blink.gotoAndPlay(1);
		}
	}

	public function unblink(){
		if( grouped )
			return;
		if( mc._blink.visible ){
			mc.visible = false;
			mc._blink.stop();
			mc._blink.visible = false;
		}
	}
	
	public function shine() {
		fxShine = new fx.Shine( this );
	}
	
	public function unshine() {
		if( fxShine == null )
			return;
		if( !fxShine.dead )
			fxShine.kill();
		fxShine = null;
	}

	public function remove(){
		if( sp != null && sp.parent != null )
			sp.parent.removeChild(sp);
	}

	public function center() {
		return new PT(
			Game.BLOCK_SIZE * x + Game.DELTA_X,
			Game.BLOCK_SIZE * y + Game.DELTA_Y
		);
	}

	public function tl() {
		var c = center();
		return new PT( c.x-Game.BLOCK_SIZE/2, c.y-Game.BLOCK_SIZE/2);
	}

	public function tr() {
		var c = center();
		return new PT( c.x+Game.BLOCK_SIZE/2, c.y-Game.BLOCK_SIZE/2);
	}

	public function bl() {
		var c = center();
		return new PT( c.x-Game.BLOCK_SIZE/2, c.y+Game.BLOCK_SIZE/2);
	}

	public function br() {
		var c = center();	
		return new PT( c.x+Game.BLOCK_SIZE/2, c.y+Game.BLOCK_SIZE/2);
	}

}

class FxSwap extends mt.fx.Fx {

	static var DUR = 25;
	static var THICK = 3;

	var sp : SP;
	var onMiddle : Null<Void -> SP>;
	var timer : Int;
	var x : Float;
	
	public function new( sp : SP, cb ){
		super();
		this.sp = sp;
		this.timer = DUR;
		this.onMiddle = cb;
		this.x = sp.x;
	}

	override function update(){
		if( timer > DUR/2 ){
			var r = timer*2/DUR - 1;  // 1 -> 0
			sp.scaleX = r;
			sp.x = x - (1-r) * THICK/2;
			sp.filters = [
				new flash.filters.DropShadowFilter( THICK*(1-r), 0, 0x0, 1.3, 1.3, 5 )
			];
		}else{
			if( onMiddle != null ){
				sp = onMiddle();
				onMiddle = null;
			}
			var r = 1 - timer*2/DUR; // 0 -> 1
			sp.scaleX = r;
			sp.x = x + (1-r) * THICK/2;

			sp.filters = [
				new flash.filters.DropShadowFilter( THICK*(1-r), 180, 0x0, 1.3, 1.3, 5 )
			];
			if( timer == 0 ){
				sp.filters = [];
				sp.cacheAsBitmap = true;
				kill();
			}
		}

		timer--;
	}

}
