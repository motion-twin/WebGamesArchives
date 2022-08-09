import api.AKApi;

class Group {
	
	public var arr : Array<Block>;
	public var id : mt.flash.Volatile<Int>;

	public function new( id : Int ){
		arr = [];
		this.id = id;
	}

	function clickable(){
		return arr.length > 1;
	}

	public function onOver(){
		if( !clickable() )
			return;

		var i : Int = id;

		var m = null;
		switch( i ){
		case 0:
			m = new mt.flash.ColorMatrix();
			m.adjustBrightness(0.05);
			m.adjustContrast(0.2);
			m.adjustSaturation(0);
		case 1:
			m = new mt.flash.ColorMatrix();
			m.adjustBrightness(0.05);
			m.adjustContrast(0.2);
			m.adjustSaturation(0.1);
		case 2:
			m = new mt.flash.ColorMatrix();
			m.adjustBrightness(0.2);
			m.adjustContrast(0);
			m.adjustSaturation(0.05);
		}

		for( b in arr ){
			var sp = b.bmp.visible ? b.bmp : b.mc;
			sp.y -= 2;
			sp.filters = [ new flash.filters.ColorMatrixFilter(m.matrix) ];
		}
		
		if( isContractId() )
			new fx.CircleMask( Game.me.contractInfo.overMask, 0.25, (Game.me.contractPts + calcPts().get()) / Game.me.contractReqs[Game.me.contractStep].get() );
	}

	public function onOut(){
		if( !clickable() )
			return;

		for( b in arr ){
			var sp = (b.bmp!=null&&b.bmp.visible) ? b.bmp : b.mc;
			if( sp != null ){
				sp.y += 2;
				sp.filters = [];
			}
		}

		if( isContractId() )
			new fx.CircleMask.CircleMask( Game.me.contractInfo.overMask, 0.25, 0 );
	}

	function isContractId(){
		return Game.me.contractSteps > 0 && Game.me.contractIds[Game.me.contractStep].get() == id;
	}

	function isValid(){
		return switch(api.AKApi.getGameMode()){
			case GM_PROGRESSION: isContractId();
			case GM_LEAGUE: true;
			default://
		}
	}

	function calcPts(){
		var m = 1;
		for( b in arr ){
			switch( b.bonus ){
				case B_X2: m *= 2;
				default:
			}
		}
		return api.AKApi.const( Math.round(arr.length * (arr.length-1)/2 * Game.PTS.get() * m) );
	}

	public function onClick(){
		if( !clickable() )
			return;

		if( Game.me.leftPlay <= 0 || Game.me.step != Game.Step.S_Play )
			return;

		Game.me.leftPlay--;
		Game.me.updateMoves();

		var s = calcPts();

		var isContract = isContractId();
		var isValid = isValid();
		if( isContract ){
			Game.me.contractAdd( s );
			isContract = true;
		}else if( isValid ){
			api.AKApi.addScore(s);
		}else{
			s = api.AKApi.const(0);
			new mt.fx.Sleep( new mt.fx.Shake( Game.me.contractInfo.mc, 2, 2 ), null, 35 );
		}

		var cp = Game.me.curPlate;
		cp.gotoAndStop( id + 2 );
		var x = new fx.Play(cp._order);
		x.onFinish = function(){
			if( isValid ){
				var f = new mt.fx.Tween(cp,620,cp.y);
				f.onFinish = function(){
					cp.parent.removeChild(cp);
				};
				new mt.fx.Sleep(f,null,13);
			}else{
				var l = mt.bumdum9.Tools.slice(cp,14);
				cp.parent.removeChild(cp);
				for( p in l ){
					p.timer = 30;
					p.weight = 1 + Std.random(20)/10;
					p.vy = -12 - Std.random(6);
					p.vx = Std.random(15) - 7;
					Game.me.dmplates.add(p.root,Game.DP_PART);
					new mt.fx.Sleep(p,null,13);
				}
			}
		};
		new mt.fx.Sleep(x,null,20);
		Game.me.addFx(new fx.Sleep(33));

		if( AKApi.getGameMode() == GM_PROGRESSION ){
			var check = new gfx.Check();
			check.gotoAndStop( isValid ? 2 : 1 );
			check.x = 560;
			check.y = 400;
			check.scaleX = check.scaleY = 0.50;
			check.alpha = 0;

			Game.me.dmplates.add( check, Game.DP_TOPPART );
			var x = new fx.Alpha(check,1,1);
			x.onFinish = function(){
				var x = new fx.Alpha(check,0,0.3);
				x.onFinish = function(){
					check.parent.removeChild(check);
				}
				new mt.fx.Sleep(x,null,20);
			}
			new mt.fx.Sleep(x,null,25);
		}
	

		var count = arr.length;
		var pts = Math.round( s.get() / count );
		for( b in arr )
			b.exec(true,isValid,arr.length,pts);

		Game.me.setStep(S_Break);
	}

}
