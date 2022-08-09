package seq;

import mt.bumdum9.Lib;
import Protocol;

using Lambda;
using mt.bumdum9.MBut;
class SelectTarget extends mt.fx.Sequence 
{
	var ball:ent.Ball;
	var trgBall:ent.Ball;
	var ghost : Ent;
	var cross:SP;
	var pathLayer:SP;
	var targets : Array<ent.Ball>;
	
	public function new(b) {
		super();
		ball = b;
		targets = [];
		
		// ROUND
		Filt.glow(ball.root, 4, 8, 0xFFFFFF);
		ball.goto("over");
		
		// MARK SQUARES
		for( sq in Game.me.squares ) sq.tag = -1;
		for( sq in Game.me.squares ) sq.selectable = -1;
		ball.square.tag = 0;
		ball.square.selectable = 0;
		var zone = [ball.square];
		while(zone.length > 0) zone = expand(zone);
		
		// GHOST
		ghost = new Ent();
		ghost.root.addChild( ent.Ball.getSkin(ball.type) );
		ghost.root.visible = false;
		
		// CROSS
		cross = new gfx.Cross();
		cross.visible = false;
		Game.me.dm.add(cross, Game.DP_FX);
		cross.filters = [new flash.filters.DropShadowFilter(2,45,0,0.5)];
		
		// BG CLICK
		Game.me.bindOnSquareSelected( select );
		Game.me.bindOnMoveCancelled( cancel );
		//
		if( !api.AKApi.isReplay() )
		{
			function emit(p_sq : Square)
			{
				if( p_sq != null )
					Game.me.emitSquareSelectedEvent(p_sq);
			}
			function emit_cancel()
			{
				Game.me.emitMoveCancelEvent();
			}
			
			for( sq in Game.me.squares )
			{
				sq.removeActions();
				//
				if ( sq.selectable == 1 ) 	sq.setAction( callback(emit, sq), callback(showPath, sq), hidePath );
				else						sq.setAction( emit_cancel, callback(showCancel, sq),  hideCancel );
			}
		}
	}
	
	override function update()
	{
		super.update();
		Game.me.fxAmbient();
	}
	
	// VALID
	function select(sq) 
	{
		if( this.dead ) return;
		kill();
		new seq.Move( ball, getPathTo(sq) );
	}
	
	function showPath(sq:Square ) 
	{
		var pos = sq.getCenter();
		ghost.root.visible = true;
		ghost.setPos(pos.x, pos.y - 4);
		// PATH
		pathLayer = new SP();
		Game.me.dm.add(pathLayer, Game.DP_GROUND);
		
		var path = getPathTo(sq);
		var first = true;
		pathLayer.graphics.lineStyle(2, 0xFFFFFF, 1);
		
		var length = path.length;
		for( i in 0...length ) 
		{
			var lsq = path[i];
			if ( lsq == null ) throw "square null at " + i;
			var pos = Game.me.getPos(lsq.x + 0.5, lsq.y + 0.5);
			if( i == 0 ) 	pathLayer.graphics.moveTo(pos.x, pos.y);
			else 		 	pathLayer.graphics.lineTo(pos.x, pos.y);
		}
		
		// TRG
		trgBall = path[0].getBall();
		if( trgBall != null ) 
		{
			Filt.glow(trgBall.root, 4, 8, 0xFFFFFF);
			ghost.root.visible = false;
		}
		
		// ARROW
		if( path.length > 1 )
		{
			arrow(path[0], path[1]);
			if( trgBall != null && ( ball.type == BallType._MOUSE || trgBall.type == BallType._MOUSE ) )
				arrow(path[path.length - 1], path[path.length - 2]);
			//SHOW MOUVEMENT EFFECT/IMPACT
			hideMoveEffect();
			showMoveEffect( ball.square, sq );
		}
	}
	
	function isMoveMakesCombo( ballType, from : Square, to:Square ) : { horizontalList : List<ent.Ball>, verticalList : List<ent.Ball> }  
	{
		//check if there's a combo
		var r = true, l = true, u = true, d = true;//directions
		var horList = new List<ent.Ball>(), vertList = new List<ent.Ball>(), x = to.x, y = to.y;
		var grid = Game.me.buildGrid();
		
		function valid(x, y) 
		{
			if( x < 0 || x >= Game.XMAX ) return false;
			if( y < 0 || y >= Game.YMAX ) return false;
			if( x == from.x && y == from.y ) return false;
			if( grid[x][y] == null ) return false;
			return true;
		}
		
		//colonne
		for( i in 1...Cs.COMBO_MINIMUM + 1 ) 
		{
			if( r && valid(x + i, y) && grid[x + i][y].type == ballType ) horList.add(grid[x + i][y]);
			else r = false;
			//
			if( l && valid(x - i, y) && grid[x - i][y].type == ballType ) horList.add(grid[x - i][y]);
			else l = false;
			
			if( u && valid(x, y - i) && grid[x][y - i].type == ballType ) vertList.add(grid[x][y - i]);
			else u = false;
			
			if( d && valid(x, y + i) && grid[x][y + i].type == ballType ) vertList.add(grid[x][y + i]);
			else d = false;
		}
		
		return { horizontalList : horList, verticalList : vertList };
	}
	
	function hideMoveEffect() 
	{
		for( t in targets )
		{
			if( t != null )
			{
				var mc = t.root;
				mc.filters = [];
			}
		}
	}
	
	function applySelectionEffect( targets : Iterable<ent.Ball> )
	{
		for( t in targets ) 
		{
			if( t != null ) 
			{
				var mc = t.root;
				mc.filters = [];
				Filt.glow(mc, 4, 10, 0xFFB600 );
			}
		}
	}
	
	function showMoveEffect(from:Square, to:Square) {
		var grid = Game.me.buildGrid();
		var fBall = from.getBall();
		if( fBall.type == BallType._LION || fBall.type == BallType._SNAKE )
		{
			var comboInfos = isMoveMakesCombo(from.getBall().type, from, to);
			for( list in [comboInfos.horizontalList, comboInfos.verticalList] )
			{
				if( fBall.type == BallType._LION )
				{
					if( list.length >= Cs.COMBO_MINIMUM - 1 )
					{
						var tmpTargets = to.nei.copy();
						for( a in list )
							tmpTargets = tmpTargets.concat( a.square.nei );
						targets = tmpTargets.map(function(s) return if( s != null ) s.getBall() else null ).array();
						//cleaning
						for( a in list )
							while( targets.remove(a) ) { }
						//
						applySelectionEffect(targets);
					}
				}
				else if( fBall.type == BallType._SNAKE )
				{
					if( list.length >= Cs.COMBO_MINIMUM - 1 )
					{
						var ref = list.first();
						if( list == comboInfos.horizontalList )
						{
							for( i in 0...Game.XMAX )
								targets.push( grid[i][ref.square.y] );
						}
						else
						{
							for( i in 0...Game.YMAX )
								targets.push( grid[ref.square.x][i] );
						}
						//clean
						for( a in list )
							while( targets.remove(a) ) { }
						//
						applySelectionEffect(targets);
					}
				}
			}
		}
	}
	
	function arrow(a, b) 
	{
		var mc = new gfx.Arrow();
		pathLayer.addChild(mc);
		var pos = Game.me.getPos((a.x + b.x) * 0.5 +0.5, (a.y + b.y) * 0.5 +0.5);
		mc.x = pos.x;
		mc.y = pos.y;
		mc.rotation = Game.me.getDir(a.x - b.x, a.y - b.y) * 90;
	}
	
	function hidePath() 
	{
		hideMoveEffect();
		if( pathLayer == null ) return;
		if( trgBall != null ) trgBall.root.filters = [];
		ghost.root.visible = false;
		pathLayer.parent.removeChild(pathLayer);
		pathLayer = null;
	}
	
	// CANCEL
	function cancel() 
	{
		if( dead ) return;
		kill();
		new SelectBall();
	}
	
	function showCancel(sq:Square) 
	{
		var pos = sq.getCenter();
		cross.x = pos.x;
		cross.y = pos.y;
		cross.visible = true;
	}
	
	function hideCancel() 
	{
		cross.visible = false;
	}
	
	function getPathTo(sq:Square)
	{
		var path = [];
		var cur = sq;
		var to = 0;
		//
		while( cur != ball.square ) 
		{
			path.push(cur);
			for( nei in cur.nei ) 
			{
				if( nei.tag >= 0 && nei.tag < cur.tag  )
				{
					cur = nei;
					break;
				}
			}
			
			if( to++ == 1000 )
			{
				new mt.fx.Flash(Game.me);
				break;
			}
		}
		
		path.push(ball.square);
		return path;
	}
	
	function expand(zone:Array<Square>) 
	{
		var a = [];
		for( sq in zone ) 
		{
			for( nsq in sq.nei ) 
			{
				if( nsq.selectable != -1 ) continue;
				nsq.tag = sq.tag + 1;
				nsq.selectable = 1;
				
				var push = true;
				if( !nsq.isFree() )
				{
					var trgBall = nsq.getBall();
					var ntype = (trgBall == null) ? null : trgBall.type;
					// BASE
					nsq.tag = 99999;
					push = false;
					nsq.selectable = 0;
					
					if( ball.type == BallType._MOUSE || ntype == BallType._MOUSE ) 
					{
						nsq.selectable = 1;
					}
					
					if( ball.type == BallType._BEAR ) 
					{
						nsq.selectable = 1;
					}
					
					if( ntype == BallType._GHOST ) 
					{
						nsq.tag = sq.tag + 1;
						push = true;
					}
				}
				if( push ) a.push(nsq);
			}
		}
		return a;
	}
	
	override function kill() 
	{
		super.kill();
		ball.root.filters = [];
		ball.goto("stand");
		hidePath();
		ghost.kill();
		cross.parent.removeChild(cross);
		//
		Game.me.unbindOnSquareSelected( select );
		Game.me.unbindOnMoveCancelled( cancel );
		//
		if( !api.AKApi.isReplay() )
		{
			for( sq in Game.me.squares )
			{
				sq.removeActions();
			}
		}
	}
}
