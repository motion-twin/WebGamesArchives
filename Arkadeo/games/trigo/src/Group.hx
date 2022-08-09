import api.AKProtocol;
import mt.flash.Volatile;

class Group {
	
	public var arr : Array<Block>;
	public var sp : SP;
	public var bsp : SP;

	public var id : Volatile<Int>;	
	public var blocks : List<Block>;
	public var newBlocks : List<Block>;
	var good : Bool;
	var borderPoints : Array<PT>;

	public var xMin : Int;
	public var yMin : Int;
	var xMax : Int;
	var yMax : Int;

	public function new( origin : Block ){
		if( origin.id == null )
			throw "can't create group with id null";
		arr = [origin];
		id = origin.id;

		blink();

		sp = new SP();
		Game.me.dm.add( sp, Game.DP_WGROUP );	
	}

	function add( b : Block ){
		arr.push( b );
				
		good = true;

		if( b.id == null ){
			good = false;
			return true;
		}

		if( b.id != id ){
			good = false;
			return true;
		}

		if( b.grouped ){
			good = false;
			return true;
		}

		for( i in 0...arr.length-1 ){
			if( arr[i] == b ){
				good = false;
				return false;
			}
		}
		
		var grid = Game.me.grid;

		if( arr.length == 3 ){
			blocks = new List();
			newBlocks = new List();

			var sp = new SP();
			sp.graphics.beginFill(0);
			sp.graphics.lineStyle(1.1,0);
			sp.graphics.moveTo( arr[arr.length-1].x+0.5, arr[arr.length-1].y+0.5 );
			for( e in arr )
				sp.graphics.lineTo( e.x+0.5, e.y+0.5 );
			sp.graphics.endFill();

			Game.me.bmd.fillRect(new flash.geom.Rectangle(0,0,Game.GRID_SIZE.get(),Game.GRID_SIZE.get()),0xFFFFFF);
			Game.me.bmd.draw(sp,null,null,null,null,true);

			xMin = Game.GRID_SIZE.get();
			yMin = Game.GRID_SIZE.get();
			xMax = 0;
			yMax = 0;
			for( b in arr ){
				if( b.x < xMin  )
					xMin = b.x;
				if( b.y < yMin )
					yMin = b.y;
				if( b.x > xMax  )
					xMax = b.x;
				if( b.y > yMax )
					yMax = b.y;
			}

			if( xMin == xMax || yMin == yMax ){
				good = false;
				return true;
			}

			for( b in arr ){
				if( !isInside(b) ){
					good = false;
					return true;
				}
			}

			var gs = Game.GRID_SIZE.get();
			var blines = new List();
			var lRow = [];
			for( ix in 0...gs )
				lRow[ix] = false;
			for( ix in 0...gs ){
				var l = false;
				for( iy in 0...gs ){
					var b = grid[ix][iy];
					var isIn = isInside(b);
					if( isIn && !l )
						blines.add( [b.tl(),b.tr()] );
					if( isIn && !lRow[iy] )
						blines.add( [b.bl(),b.tl()] );
					if( !isIn && l )
						blines.add( [b.tr(),b.tl()] );
					if( !isIn && lRow[iy] )
						blines.add( [b.tl(),b.bl()] );
					if( isIn && ix == gs-1 )
						blines.add( [b.tr(),b.br()] );
					if( isIn && iy == gs-1 )
						blines.add( [b.br(),b.bl()] );
					lRow[iy] = isIn;
					l = isIn;
					if( !isIn )
						continue;
					blocks.add(b);
					if( !b.grouped )
						newBlocks.add( b );
				}
			}

			borderPoints = sortPoints( blines );

			if( newBlocks.length == 0 ){
				good = false;
				return true;
			}

			if( Game.me.gblocks != null && blocks.length - newBlocks.length != Game.me.gblocks.length ){
				good = false;
				return true;
			}

		}
		return true;
	}

	function isInside( p : Block ){
		return Game.me.bmd.getPixel(p.x,p.y)&0xFF <= 160;
	}

	public function over( b : Block ){
		sp.graphics.clear();

		if( b.grouped )
			return;

		add(b);

		var c = good ? 0xFFFFFF : 0xFF0000;
		
		if( good && arr.length == 3 )
			showBorders();

		sp.graphics.lineStyle( 4, c, 0.5);

		var s = arr[0].center();
		sp.graphics.moveTo( s.x, s.y );
		for( i in 1...arr.length ){
			var b = arr[i].center();
			sp.graphics.lineTo( b.x, b.y );
		}
		sp.graphics.lineTo( s.x, s.y );
		sp.graphics.endFill();
		
		arr.pop();
	}

	public function click( b : Block ) : Null<Bool> {
		if( !add(b) ){
			deselect();
			return false;
		}
		if( !good ){
			arr.pop();
			return false;
		}

		if( arr.length < 3 )
			return null;

		bsp = new SP();
		Game.me.dm.add(bsp,Game.DP_GROUP);
		showBorders(bsp, 0x434448 );
		
		unblink();

		return true;	
	}

	public function showFPlay( r : Float ){
		var n = borderPoints.length;
		var e = Math.ceil(r*n);

		sp.graphics.clear();
		var l = borderPoints[borderPoints.length-1];
		sp.graphics.lineStyle(5,0xFFF6D2,0.8);
		sp.graphics.moveTo( l.x, l.y );
		for( i in 0...e ){
			var p = borderPoints[i];

			if( i == e-1 ){
				var sr = (r*n) - i;
				var mp = new PT(
					l.x + (p.x-l.x)*sr,
					l.y + (p.y-l.y)*sr
				);
				sp.graphics.lineTo( mp.x, mp.y );

				var part = Game.me.createPart( mp, 2 );
				part.vx += (p.x-l.x)*1/Game.BLOCK_SIZE;
				part.vy += (p.y-l.y)*1/Game.BLOCK_SIZE;
			}else{
				sp.graphics.lineTo( p.x, p.y );
				l = p;
			}
		}
	}

	public function hide(){
		if( sp.parent != null )
			sp.parent.removeChild(sp);
		if( bsp != null && bsp.parent != null )
			bsp.parent.removeChild(bsp);
		unblink();
	}
	
	public function unblink() {
		Lambda.iter(Game.me.listBlocks(id),function(b) b.unblink());
	}
	
	public function blink(){
		Lambda.iter(Game.me.listBlocks(id), function(b) b.blink());
	}

	public function deselect(){
		hide();
		if( Game.me.group == this )
			Game.me.group = null;
	}

	public function calcPts(){
		var m = Game.me.combo;
		return api.AKApi.const( Math.round(blocks.length * (blocks.length-1)/2 * Game.PTS.get() * m) );
	}

	function sortPoints( blines : List<Array<PT>> ){
		var points = [];
		var f = blines.pop();
		var first = f[0];
		var last = f[1];
		points.push(last);
		while( true ){
			for( l in blines ){
				if( l[0].x == last.x && l[0].y == last.y ){
					blines.remove(l);
					last = l[1];
					points.push(last);
					if( last.x == first.x && last.y == first.y ){
						return points;
					}
				}
			}
		}
	}

	public function showBorders( ?s : SP, col = 0xFFF6D2 ){
		if( s == null )
			s = sp;
		s.graphics.lineStyle(2,col);
		var l = borderPoints[borderPoints.length-1];
		s.graphics.moveTo( l.x, l.y );
		for( p in borderPoints )
			s.graphics.lineTo(p.x, p.y);
	}

	public function center(){
		return new PT(
			(xMin+xMax)/2,
			(yMin+yMax)/2
		);
	}

}
