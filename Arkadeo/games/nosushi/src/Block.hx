import mt.bumdum9.Lib;
import api.AKApi;
import api.AKProtocol;
import Game;

class Block {
	
	public var x : mt.flash.Volatile<Int>;
	public var y : mt.flash.Volatile<Int>;

	public var id : mt.flash.Volatile<Int>;
	public var bonus : Bonus;
	public var bonusTimer : Null<mt.flash.Volatile<Int>>;
	public var prizeToken : Null<SecureInGamePrizeTokens>;

	public var mc : {> MC, _bonus: MC, _block: MC};
	public var bmp : SP;
	public var bmpOffset : {x: Float, y: Float};

	public var group : Group;

	public function new( px : Int, py : Int, isInit : Bool ){
		x = px;
		y = py;
		if( Game.me.blackProba > 0 && Game.me.rand(Game.me.blackProba) == 0 )
			id = Game.BLACK_ID.get();
		else
			id = Game.me.rand(Game.MAX_ID.get());

		if( AKApi.getGameMode() == GM_PROGRESSION && AKApi.getLevel() < Game.BONUS_MIN_LEVEL.get() )
			bonus = Bonus.B_None;
		else
			bonus = mt.deepnight.RandList.fromEnum(Bonus,__unprotect__("proba")).draw(Game.me.rand);


		switch( bonus ){
		case B_Bombe,B_Dynamite:
			if( AKApi.getGameMode() == GM_PROGRESSION && AKApi.getLevel() < Game.BOMBE_MIN_LEVEL.get() )
				bonus = B_None;
			else
				bonusTimer = Game.BOMBE_TIMER.get();
		case B_MorePlay:
			if( Game.me.curMoreplay >= Game.MAX_MOREPLAY.get() )
				bonus = B_None;
			else
				Game.me.curMoreplay++;
		case B_X2:
			if( Game.me.findSameBlock( this ) )
				bonus = B_None;
		default:
		}

		var a = Game.me.filteredPrizeTokens();
		if( bonus == B_None && a.length > 0 ){
			var proba = Math.ceil( (Game.me.leftPlay * Game.me.emptyCells) / a.length );
			if( AKApi.getGameMode() == GM_PROGRESSION ){
				var progToAdd = Math.round(Game.me.globalProgression * Game.me.totalPrizeTokens);
				var added = Game.me.totalPrizeTokens - Game.me.prizeTokens.length;
				// A distribuer ce tour
				var s = progToAdd - added;
				if( s > 0 )
					proba = Math.ceil( Game.me.emptyCells / s );
			}
			if( Game.me.rand(proba) == 0 ){
				prizeToken = Game.me.getPrizeToken();
				bonus = switch( prizeToken.frame ){
				case 1: B_AK1;
				case 2: B_AK2;
				case 3: B_AK3;
				case 4: B_AK4;
				}
			}
		}


		draw(isInit);
	}

	function toString(){
		return "("+x+","+y+")";
	}

	function draw( init ){
		
		mc = cast new gfx.Bloc();
		mc.gotoAndStop(id+1);
		mc._bonus.gotoAndStop(Type.enumIndex(bonus)+1);

		Game.me.dmtray.add(mc,Game.DP_BLOCKS);
		bmp = Game.flatten( mc );
		bmpOffset = {x: bmp.x, y: bmp.y};
		Game.me.dmtray.add(bmp,Game.DP_BLOCKS);
		drawPos();

		if( init ){
			mc.visible = false;
		}else{
			bmp.visible = false;
			mc.scaleX = mc.scaleY = 1 / 4;
			var f = new mt.fx.Grow(mc,0.3,1);
			Game.me.addFx(f,function(){
				mc.visible = false;
				bmp.visible = true;
			});
		}
	}

	public function drawPos(){
		mc.x = x * Game.RAY - y * Game.RAY + Game.DELTA_X;
		mc.y = x * Game.RAY + y * Game.RAY + Game.DELTA_Y;
		bmp.x = mc.x + bmpOffset.x;
		bmp.y = mc.y + bmpOffset.y;
	}

	public function makeGroup( g ){
		group = g;
		group.arr.push(this);

		if( id == Game.BLACK_ID.get() )
			return;

		var grid = Game.me.grid;
		var a = [
			grid[x][y-1],
			grid[x][y+1],
			x>0 ? grid[x-1][y] : null,
			x<Game.GRID_SIZE-1 ? grid[x+1][y] : null,
		];
		for( n in a ){
			if( n != null && n.group == null && n.id == id )
				n.makeGroup(g);
		}
	}

	public function gravityLeft(){
		Game.me.grid[x][y] = null;
		x++;
		Game.me.grid[x][y] = this;
		move();
	}

	public function gravityDown(){
		Game.me.grid[x][y] = null;
		y++;
		Game.me.grid[x][y] = this;
		move();
	}

	function move(){
		var nx = x * Game.RAY - y * Game.RAY + Game.DELTA_X + bmpOffset.x;
		var ny =  x * Game.RAY + y * Game.RAY + Game.DELTA_Y + bmpOffset.y;
		var f = new mt.fx.Tween(bmp,nx,ny,0.4);
		Game.me.addFx(f,function(){
			drawPos();
		});
	}

	public function breakBmp(){
		if( bmp == null )
			return;
		bmp.parent.removeChild(bmp);
		bmp = null;
		mc.visible = true;
	}

	public function vanish(){
		if( bmp != null && bmp.visible )
			new mt.fx.Sleep( new fx.Alpha(bmp,0,0.08), null, 10 );
		else if( mc != null && mc.visible )
			new mt.fx.Sleep( new fx.Alpha(mc,0,0.08), null, 10 );
	}

	public function exec( isGroup : Bool, isValid : Bool, count : Int, pts : Int ){
		if( isGroup ){
			doBonus();
			mc.filters = [];
			breakBmp();
			var c = Std.int(Math.max(1,3 + Math.round((20-count)/6)));
			var t = new fx.Play(mc._block, 2...mc._block.totalFrames);
			t.onFinish = function(){
				mc.parent.removeChild(mc);
			};

			if( pts > 0 ){
				var tf = new TF();
				tf.text = Std.string( pts );

				var f = tf.getTextFormat();
				f.size = 18;
				f.color = Game.ID_COLORS[id];
				f.bold = true;
				f.font = "arial";
				tf.setTextFormat(f);

				var sp = new SP();
				Game.me.dm.add(sp,Game.DP_PART);
				sp.addChild(tf);
				sp.x = mc.x - tf.textWidth / 2;
				sp.y = mc.y - tf.textHeight;
				sp.alpha = 0;
				sp.cacheAsBitmap = true;

				var f = new flash.filters.GlowFilter();
				f.color = 0xFFFFFF;
				f.strength = 4;
				f.blurX = f.blurY = 4;
				f.alpha = 1;
				sp.filters = [f];

				var f = new fx.Alpha(sp,1,0.2);
				f.onFinish = function(){
					var p = new mt.fx.Part(sp);
					p.weight = -0.2;
					p.timer = 15;
					p.fadeLimit = 5;
					p.fadeType = 1;
				}
				new mt.fx.Sleep(f,null,14);
			}
		}
		Game.me.grid[x][y] = null;
	}

	public function doBonus( doBombe = false ){
		switch( bonus ){
		case B_None:
			return;
		case B_Bombe,B_Dynamite:
			if( doBombe ){
				Game.me.enqueueBomb(this);
				return;
			}
		case B_MorePlay:	
			Game.me.addPlay( Game.BONUS_ASPIRINE.get() );
		case B_AK1,B_AK2,B_AK3,B_AK4:
			AKApi.takePrizeTokens( prizeToken );
		case B_X2:
		}

		mc._bonus.gotoAndStop( Type.enumIndex(B_None)+1 );

		var bmc = new gfx.Bonus();
		bmc.gotoAndStop(Type.enumIndex(bonus)+1);
	
		bmc.x = mc.x;
		bmc.y = mc.y - 10;
		Game.me.dm.add(bmc,Game.DP_TOPPART);
		
		var scale = 2.5;
		if( bonus == B_Bombe || bonus == B_Dynamite )
			scale = 0.1;
		var fx = new fx.BonusVanish(bmc,scale);
		fx.curveIn(2);
	}


	public function showBombe(){
		var bmc = new gfx.Bonus();
		bmc.gotoAndStop(Type.enumIndex(bonus)+1);
	
		bmc.x = mc.x;
		bmc.y = mc.y - 10;
		Game.me.dm.add(bmc,Game.DP_TOPPART);
		
		var f = new mt.fx.Radiate(bmc,0.5,0xFFFFFF,10);
		f.onFinish = function(){
			var fx = new fx.BonusVanish(bmc);
			fx.curveIn(2);
		}
	}

	public function turnBonus(){
		if( bonus != B_Bombe && bonus != B_Dynamite )
			return;
		bonusTimer--;
		
		bmp.visible = false;
		mc.visible = true;

		var col = bonus==B_Bombe ? 0xFF0000 : 0xFFFFFF;
		var p = bonus==B_Bombe ? 0.35 : 0.28;

		if( bonusTimer > 1 ){
			Game.me.addFx(new fx.Radiate(mc._bonus,0.04,col,0.6, 12 ),function(){
				bmp.visible = true;
				mc.visible = false;
			});
			return;
		}else if( bonusTimer > 0 ){
			new fx.Radiate( mc._bonus, 0.08, col, p, -1 );
			return;
		}

		breakBmp();
		doBonus( true );
	}

}
