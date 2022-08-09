package ;

import Lib;
class Skinner
{
	public static function skinLevel()
	{
		var grid = Game.me.grid;
		var dm = Game.me.dm;
		var rand = Game.me.rand;
		
		var reflectOffset = -3;
		var reflectAlpha = 0.25;
		var reflectRatio = 150;
		var barrierOffset = 10;
		
		for( y in 0...Lib.GRID_HMAX )
		{
			for( x in 0...Lib.GRID_WMAX )
			{
				var cell = grid[y][x];
				var coord = Lib.getCoord_XY( x, y );
				//
				if( cell.flags.has(Block) && !cell.flags.has(NoSkin) )
				{
					var mc = new gfx.Block();
					var frame = 1;
					if( !cell.flags.has(Forest ) ) frame += rand.random( mc.totalFrames - 1 );//plus de Luges !
					mc.gotoAndStop( frame );
					
					cell.gfx = mc;
					mc.x += coord.x;
					mc.y += coord.y;
					mc.cacheAsBitmap = true;
					dm.add( mc, Game.DM_GAME );
					
					var offset = if( frame == 1 || frame == 8 ) -10 else reflectOffset;
					var r = new Reflection( mc, reflectAlpha, reflectRatio, 0, offset );
					r.x = coord.x;
					r.y = coord.y;
					dm.add( r, Game.DM_REFLECT );
					
					cell.reflection = r;
				}
				else if( cell.flags.has(Lake) && !cell.flags.has(NoSkin) )
				{
					var mc = new gfx.Lake();
					var frame = if( cell.collisionFlags.has(CTop) && cell.collisionFlags.has(CLeft) ) 5;
								else if( cell.collisionFlags.has(CTop) && cell.collisionFlags.has(CRight) ) 6;
								else if( cell.collisionFlags.has(CBottom) && cell.collisionFlags.has(CLeft) ) 8;
								else if( cell.collisionFlags.has(CBottom) && cell.collisionFlags.has(CRight) ) 9;
								else if( cell.collisionFlags.has(CLeft) ) 2;
								else if( cell.collisionFlags.has(CRight) ) 3;
								else if( cell.collisionFlags.has(CBottom) ) 7;
								else if( cell.collisionFlags.has(CTop) ) 4;
								else 1;
					mc.gotoAndStop( frame );
					
					cell.gfx = mc;
					mc.x += coord.x;
					mc.y += coord.y;
					mc.cacheAsBitmap = true;
					dm.add( mc, Game.DM_GAME );
					if( cell.collisionFlags.has(CBottom) )
					{
						var r = Lib.snapshot(mc);
						r.alpha = reflectAlpha;
						r.x += coord.x;
						r.y += coord.y + barrierOffset;
						dm.add( r, Game.DM_REFLECT );
						
						cell.reflection = r;
					}
				}
				else if( cell.hasCollide() && !cell.flags.has(NoSkin) )
				{
					var mc = new Sprite();
					if( cell.collisionFlags.has(CTop) && (cell.y > 0) )
					{
						var b = new gfx.Barrier();
						b.gotoAndStop("t");
						b.sub.gotoAndStop( rand.random(b.sub.totalFrames) + 1 );
						mc.addChild(b);
					}
					
					if( cell.collisionFlags.has(CLeft) && (cell.x > 0) )
					{
						var b = new gfx.Barrier();
						b.gotoAndStop("l");
						b.sub.gotoAndStop( rand.random(b.sub.totalFrames) + 1 );
						mc.addChild(b);
					}
					
					if( cell.collisionFlags.has(CRight) && (cell.x < Lib.GRID_REAL_WMAX) )
					{
						var b  = new gfx.Barrier();
						b.gotoAndStop("r");
						b.sub.gotoAndStop( rand.random(b.sub.totalFrames) + 1 );
						mc.addChild(b);
					}
					
					if( cell.collisionFlags.has(CBottom) && (cell.y < Lib.GRID_REAL_HMAX) )
					{
						var b  = new gfx.Barrier();
						b.gotoAndStop("b");
						b.sub.gotoAndStop( rand.random(b.sub.totalFrames) + 1 );
						mc.addChild(b);
					}
					//
					if( mc.width > 0 && mc.height > 0 )
					{
						cell.gfx = mc;
						mc.x += coord.x;
						mc.y += coord.y;
						mc.cacheAsBitmap = true;
						dm.add( mc, Game.DM_GAME );
						
						var r = Lib.snapshot(mc);
						r.alpha = 0.10;
						r.x += mc.x;
						r.y += mc.y + barrierOffset;
						dm.add( r, Game.DM_REFLECT );
						
						cell.reflection = r;
					}
				};
				
				if( cell.flags.has(Home) )
				{
					var mc = new gfx.Arrival();
					cell.gfx = mc;
					mc.x += coord.x;
					mc.y += coord.y - 32;
					mc.cacheAsBitmap = true;
					dm.add( mc, Game.DM_GAME );
				}
			}
		}
	}
	
	public static function drawGrid()
	{
		var offset = 5;
		var mc = Game.me.dm.empty( Game.DM_BACKGROUND );
		var g = mc.graphics;
		g.lineStyle(0.3, 0x70B9B5, .4);
		for( i in 1...Lib.GRID_WMAX  )
		{
			g.moveTo( i * Lib.TILE_SIZE, -offset );
			g.lineTo( i * Lib.TILE_SIZE, Lib.TILE_SIZE * Lib.GRID_HMAX + offset);
		}
		for( i in 1...Lib.GRID_HMAX  )
		{
			g.moveTo( -offset, i * Lib.TILE_SIZE );
			g.lineTo( offset+Lib.TILE_SIZE * Lib.GRID_WMAX,  i * Lib.TILE_SIZE);
		}
		mc.cacheAsBitmap = true;
	}
	
	public static function drawBackground()
	{
		var dm = Game.me.dm;
		var rand = Game.me.rand;
		
		for( offset in 0...(10-Lib.GRID_MID_WMAX) )
		{
			for( i in -(offset+1)...Lib.GRID_WMAX+(offset+1) )
			{
				//TOP
				var mc = new gfx.Snow();
				mc.x = i * Lib.TILE_SIZE;
				mc.y = -(offset + 1) * Lib.TILE_SIZE;
				
				var frame = 5;
				if( offset == 0 )
				{
					frame = if( i == -1 ) 9;
							else if( i == Lib.GRID_WMAX ) 8;
							else 4;
				}
				mc.gotoAndStop(frame);
				if( frame <= 5 )
					mc.sub.gotoAndStop( rand.random(mc.sub.totalFrames) + 1 );
				mc.cacheAsBitmap = true;
				dm.add(mc, Game.DM_BACKGROUND);
				
				//BOTTOM
				var mc = new gfx.Snow();
				mc.x = i * Lib.TILE_SIZE;
				mc.y = Lib.HEIGHT + ((offset) * Lib.TILE_SIZE );
				var frame = 5;
				if( offset == 0 )
				{
					frame = if( i == -1 ) 7;
							else if( i == Lib.GRID_WMAX ) 6;
							else 3;
				}
				mc.gotoAndStop(frame);
				
				if( frame <= 5 )
				{
					if( mc.y > Lib.HEIGHT + Lib.TILE_MID_SIZE && i > (Lib.GRID_MID_WMAX / 3) )
						mc.sub.gotoAndStop(1);
					else
						mc.sub.gotoAndStop( rand.random(mc.sub.totalFrames) + 1 );
				}
				
				mc.cacheAsBitmap = true;
				dm.add(mc, Game.DM_BACKGROUND);
			}
			
			for( i in -offset...Lib.GRID_HMAX+offset )
			{
				//LEFT
				var mc = new gfx.Snow();
				mc.x = - (offset+1) * Lib.TILE_SIZE;
				mc.y = i * Lib.TILE_SIZE;
				var frame = offset == 0 ? 2 : 5;
				mc.gotoAndStop(frame);
				mc.sub.gotoAndStop( rand.random(mc.sub.totalFrames) + 1 );
				
				mc.cacheAsBitmap = true;
				dm.add(mc, Game.DM_BACKGROUND);
				
				//RIGHT
				var mc = new gfx.Snow();
				mc.x = (Lib.GRID_WMAX+offset) * Lib.TILE_SIZE;
				mc.y = i * Lib.TILE_SIZE;
				var frame = offset == 0 ? 1 : 5;
				mc.gotoAndStop(frame);
				mc.sub.gotoAndStop( rand.random(mc.sub.totalFrames) + 1 );
				
				mc.cacheAsBitmap = true;
				dm.add(mc, Game.DM_BACKGROUND);
			}
		}
		var g = Game.me.container.graphics;
		g.beginFill(0xD3F6F4);
		g.drawRect(0, 0, Lib.STAGE_WIDTH, Lib.STAGE_HEIGHT);
		g.endFill();
		//
		dm.ysort(Game.DM_BACKGROUND);
	}
}