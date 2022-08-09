class Render {

	static inline var FBITS = 14;
	static inline var FSIZE = 1 << FBITS;
	static inline var FMASK = FSIZE - 1;
	static inline var INF = (1 << 29) - 1;

	var fov : Float;
	var level : Level;

	public function new(lvl,fov) {
		this.fov = fov;
		this.level = lvl;
	}

	function f( v : Float ) {
		return Std.int(v*100) / 100;
	}

	inline static function ffmult( a : Int, b : Int ) {
		return (a >> (FBITS >> 1)) * (b >> ((FBITS + 1) >> 1));
	}

	inline static function fmult( a : Int, b : Int ) {
		return Std.int((a / FSIZE) * b);
	}

	inline static function fdiv( a : Int, b : Int ) {
		return Std.int((a / b) * FSIZE);
	}

	inline static var DBITS = FBITS - (Level.TBITS*2+2);

	inline static function getT( t : Int, x : Int, y : Int ) {
		return t | ((if( DBITS >= 0 ) y >> DBITS else y << -DBITS)&(Level.TMASK << (Level.TBITS + 2))) | ((x>>(FBITS-(Level.TBITS+2)))&(Level.TMASK << 2));
	}

	inline function getB( t : Int, x : Int, y : Int, z : Int ) {
		return flash.Memory.getByte(t + level.addr(x,y,z));
	}

	inline function fdist( dx : Int, dy : Int, dz : Int ) {
		return (ffmult(dx,dx)>>2) + (ffmult(dy,dy)>>2) + (ffmult(dz,dz)>>2);
	}

	inline function getFog( d : Int ) {
		var k = d >> (FBITS + 3);
		return if( k > 0xFF ) 0xFF else k;
	}

	public function pick( lvl : Int, width : Int, height : Int, fpx : Float, fpy : Float, fpz : Float, a : Float, px : Int, py : Int, angleZ : Float, empty : Bool ) {
		var Math = Math;
		var dist = (width / 2) / Math.tan(fov / 2);
		var dx = Math.cos(a - fov / 2);
		var dy = Math.sin(a - fov / 2);
		var dz = Math.sin((height / width) * fov / 2);
		dx += (Math.cos(a + fov / 2) - dx) * px / width;
		dy += (Math.sin(a + fov / 2) - dy) * px / width;
		dz += (Math.sin(-(height / width) * fov / 2) - dz) * py / height;
		dz += angleZ;
		dx *= 0.1;
		dy *= 0.1;
		dz *= 0.1;
		var ox = -1, oy = -1, oz = -1;
		while( true ) {
			var x = Std.int(fpx);
			var y = Std.int(fpy);
			var z = Std.int(fpz);
			if( level.outside(x,y,z) )
				break;
			var b = getB(lvl,x,y,z);
			if( b > 0 ) {
				if( empty ) {
					if( ox == -1 ) break;
					return { x : ox, y : oy, z : oz, b : null };
				}
				return { x : x, y : y, z : z, b : level.blocks[b] };
			}
			ox = x;
			oy = y;
			oz = z;
			fpx += dx;
			fpy += dy;
			fpz += dz;
		}
		return null;
	}

	public function render( bmp : Int, lvl : Int, bg : Int, bgBits : Int, width : Int, height : Int, fpx : Float, fpy : Float, fpz : Float, a : Float, dz : Float ) {
		var Math = Math;
		var dist = (width / 2) / Math.tan(fov / 2);
		var dx0 = Math.cos(a - fov / 2);
		var dy0 = Math.sin(a - fov / 2);
		var dz0 = Math.sin((height / width) * fov / 2);
		var ax = (Math.cos(a + fov / 2) - dx0) / width;
		var ay = (Math.sin(a + fov / 2) - dy0) / width;
		var az = (Math.sin(-(height / width) * fov / 2) - dz0) / height;

		var dx0 = Std.int(dx0 * FSIZE);
		var dy0 = Std.int(dy0 * FSIZE);
		var dz0 = Std.int((dz0 + dz) * FSIZE);
		var ax = Std.int(ax * FSIZE);
		var ay = Std.int(ay * FSIZE);
		var az = Std.int(az * FSIZE);

		// make sure we will not have dx=0, dy=0 or dz=0 at some time
		if( Std.int(dx0/ax)*ax == dx0 )
			dx0++;
		if( Std.int(dy0/ay)*ay == dy0 )
			dy0++;
		if( Std.int(dz0/az)*az == dz0 )
			dz0++;

		var px = Std.int(fpx * FSIZE);
		var py = Std.int(fpy * FSIZE);
		var pz = Std.int(fpz * FSIZE);

		var px0 = px >> FBITS;
		var px1 = (px + FMASK) >> FBITS;
		var py0 = py >> FBITS;
		var py1 = (py + FMASK) >> FBITS;
		var pz0 = pz >> FBITS;
		var pz1 = (pz + FMASK) >> FBITS;

		var t = level.t;

		var dz = dz0;
		for( bmpY in 0...height ) {
			var dx = dx0, dy = dy0;
			var z0, zinc;
			if( dz <= 0 ) {
				zinc = -1;
				z0 = pz0;
			} else {
				zinc = 1;
				z0 = pz1;
			}
			for( bmpX in 0...width ) {
				var Xy = fdiv(dy,dx);
				var Xz = fdiv(dz,dx);
				var Yx = fdiv(dx,dy);
				var Yz = fdiv(dz,dy);
				var Zx = fdiv(dx,dz);
				var Zy = fdiv(dy,dz);

				var blend = 0xFF, dr = 0, dg = 0, db = 0, fog = 0, ds = 0;
				var tex, dist, shade, bdist = -1;

				var x0,  xinc;
				if( dx <= 0 ) {
					xinc = -1;
					x0 = px0;
					Xy = -Xy;
					Xz = -Xz;
				} else {
					xinc = 1;
					x0 = px1;
				}
				var y0, yinc;
				if( dy <= 0 ) {
					yinc = -1;
					y0 = py0;
					Yx = -Yx;
					Yz = -Yz;
				} else {
					yinc = 1;
					y0 = py1;
				}
				var z0 = z0;
				if( dz <= 0 ) {
					Zx = -Zx;
					Zy = -Zy;
				}

			do {

				var bx = 0, bbx = null, by = 0, bby = null, bz = 0, bbz = null;

				// X lookup
				var mx = ((x0 << FBITS) - px) * xinc;
				if( xinc < 0 ) x0--;
				var xy = py + fmult(Xy,mx);
				var xz = pz + fmult(Xz,mx);
				while( true ) {
					var iy = xy >> FBITS, iz = xz >> FBITS;
					if( level.outside(x0,iy,iz) ) {
						x0 = INF;
						break;
					}
					bx = getB(lvl,x0,iy,iz);
					if( bx != 0 ) {
						bbx = level.blocks[bx];
						if( flash.Memory.getByte(getT(bbx.addrLR,xy,xz)) & blend != 0 )
							break;
					}
					x0 += xinc;
					xy += Xy;
					xz += Xz;
				}

				// Y lookup
				var my = ((y0 << FBITS) - py) * yinc;
				if( yinc < 0 ) y0--;
				var yx = px + fmult(Yx,my);
				var yz = pz + fmult(Yz,my);
				while( true ) {
					var ix = yx >> FBITS, iz = yz >> FBITS;
					if( level.outside(ix,y0,iz) ) {
						y0 = INF;
						break;
					}
					by = getB(lvl,ix,y0,iz);
					if( by != 0 ) {
						bby = level.blocks[by];
						if( flash.Memory.getByte(getT(bby.addrLR,yx,yz)) & blend != 0 )
							break;
					}
					y0 += yinc;
					yx += Yx;
					yz += Yz;
				}

				// Z lookup
				var mz = ((z0 << FBITS) - pz) * zinc;
				if( zinc < 0 ) z0--;
				var zx = px + fmult(Zx,mz);
				var zy = py + fmult(Zy,mz);
				while( true ) {
					var ix = zx >> FBITS, iy = zy >> FBITS;
					if( level.outside(ix,iy,z0) ) {
						z0 = INF;
						break;
					}
					bz = getB(lvl,ix,iy,z0);
					if( bz != 0 ) {
						bbz = level.blocks[bz];
						if( flash.Memory.getByte(getT(if( dz >= 0 ) bbz.addrD else bbz.addrU,zx,zy)) & blend != 0 )
							break;
					}
					z0 += zinc;
					zx += Zx;
					zy += Zy;
				}

				// Distance calculus
				var ddx,ddy,ddz;
				var xd,yd,zd;
				if( x0 == INF )
					xd = INF;
				else {
					if( xinc < 0 ) x0++;
					xd = fdist(px - (x0<<FBITS),py - xy,pz - xz);
				}
				if( y0 == INF )
					yd = INF;
				else {
					if( yinc < 0 ) y0++;
					yd = fdist(px - yx,py - (y0<<FBITS),pz - yz);
				}
				if( z0 == INF )
					zd = INF;
				else {
					if( zinc < 0 ) z0++;
					zd = fdist(px - zx,py - zy,pz - (z0<<FBITS));
				}

				// Texturing
				if( xd < yd ) {
					if( xd < zd ) {
						dist = xd;
						shade = bbx.shadeX;
						tex = getT(bbx.addrLR,xy,xz);
					} else {
						dist = zd;
						if( dz >= 0 ) {
							shade = bbz.shadeDown;
							tex = getT(bbz.addrD,zx,zy);
						} else {
							shade = bbz.shadeUp;
							tex = getT(bbz.addrU,zx,zy);
						}
					}
				} else if( yd < zd ) {
					dist = yd;
					shade = bby.shadeY;
					tex = getT(bby.addrLR,yx,yz);
				} else if( zd != INF ) {
					dist = zd;
					if( dz >= 0 ) {
						shade = bbz.shadeDown;
						tex = getT(bbz.addrD,zx,zy);
					} else {
						shade = bbz.shadeUp;
						tex = getT(bbz.addrU,zx,zy);
					}
				} else {
					if( (blend&0xDF) == 0xDF )
						blend = 0;
					else {
						shade = 0xFF;
						dist = INF;
						tex = bg + ((bmpY<<bgBits)&0xFFFC);
					}
					break;
				}

				var alpha = flash.Memory.getByte(tex);
				if( alpha == 0xFF ) break;
				blend &= 0xFF - alpha;
				if( bdist < 0 ) bdist = dist;
				switch( alpha ) {
				case 1: // invisible
					shade = 0xFF;
					ds = 0;
					fog = 0;
					tex = bg + ((bmpY<<bgBits)&0xFFFC);
					break;
				case 2: // amethyste
					ds += shade - 206;
					dr += (100 * shade) >> 8;
					dg += (40 * shade) >> 8;
					db += (125 * shade) >> 8;
				case 4: // emeraude
					ds += shade - 276;
					dg += (150 * shade) >> 8;
					dr += (10 * shade) >> 8;
					db += (70 * shade) >> 8;
				case 8: // rubis
					ds += shade - 206;
					dr += (110 * shade) >> 8;
					dg += (5 * shade) >> 8;
					db += (40 * shade) >> 8;
				case 16: // saphir
					ds += shade - 256;
					dg += (56 * shade) >> 8;
					db += (214 * shade) >> 8;
				case 32: // fog
					ds += shade - 200;
					fog += 100;
				case 64: // shade
					ds += shade - 290;
				case 128: // light
					ds += shade + 50;
				}
			} while( true );

				if( blend == 0 ) {
					flash.Memory.setI32(bmp,0);
					bmp += 4;
					dx += ax;
					dy += ay;
					continue;
				}


				if( blend & 0xDF == 0xDF ) {
					var k;
					fog += getFog(dist);
					if( fog > 0xFF )
						fog = 0xFF;
					shade += ds;
					if( shade < 0 )
						shade = 0;
					flash.Memory.setByte(bmp,0xFF-fog);
					tex++; bmp++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					if( k > 255 ) k = 255;
					flash.Memory.setByte(bmp,k);
					bmp++; tex++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					if( k > 255 ) k = 255;
					flash.Memory.setByte(bmp,k);
					bmp++; tex++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					if( k > 255 ) k = 255;
					flash.Memory.setByte(bmp,k);
					bmp++;
				} else {
					var k;
					var bfog = getFog(bdist);
					var tbg = bg + ((bmpY<<bgBits)&0xFFFC);
					fog += getFog(dist);
					shade += ds;
					if( bfog >= 0xFF )
						bfog = 0xFF;
					if( fog >= 0xFF )
						fog = 0xFF;
					flash.Memory.setByte(bmp,0xFF);
					tex++; tbg++; bmp++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					k = (k * (255 - fog) + flash.Memory.getByte(tbg) * fog) >> 8;
					k += dr;
					k = (k * (255 - bfog) + flash.Memory.getByte(tbg) * bfog) >> 8;
					if( k > 255 ) k = 255 else if( k < 0 ) k = 0;
					flash.Memory.setByte(bmp,k);
					tex++; tbg++; bmp++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					k = (k * (255 - fog) + flash.Memory.getByte(tbg) * fog) >> 8;
					k += dg;
					k = (k * (255 - bfog) + flash.Memory.getByte(tbg) * bfog) >> 8;
					if( k > 255 ) k = 255 else if( k < 0 ) k = 0;
					flash.Memory.setByte(bmp,k);
					tex++; tbg++; bmp++;
					k = (flash.Memory.getByte(tex) * shade) >> 8;
					k = (k * (255 - fog) + flash.Memory.getByte(tbg) * fog) >> 8;
					k += db;
					k = (k * (255 - bfog) + flash.Memory.getByte(tbg) * bfog) >> 8;
					if( k > 255 ) k = 255 else if( k < 0 ) k = 0;
					flash.Memory.setByte(bmp,k);
					tex++; tbg++; bmp++;
				}

				// next
				dx += ax;
				dy += ay;
			}
			dz += az;
		}
	}

}