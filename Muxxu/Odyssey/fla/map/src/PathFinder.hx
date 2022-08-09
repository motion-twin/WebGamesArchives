class PathFinder  {

	static inline var DMAX = 1 << 15;
	
	var w : Int;
	var h : Int;
	var delta : Int;
	var stride : Int;
	var div : Int;
	var bmp : flash.display.BitmapData;
	var ct : flash.geom.ColorTransform;
	var pixels : flash.utils.ByteArray;
	var mark : Int;
	var bitMask : Int;
	public var diagonals : Bool;
	public var statsPixels(default, null): Int;
	
	public function new( width, height, size ) {
		this.div = size;
		this.w = Math.ceil(width / size);
		this.h = Math.ceil(height / size);
		delta = w * h * 4;
		stride = w * 4;
		if( delta * 2 < 1024 ) throw "Too small";
		bmp = new flash.display.BitmapData(w, h, true, 0);
		ct = new flash.geom.ColorTransform(0, 0, 0, 1, 0, 0, 0, 255);
		//flash.Lib.current.addChild(new flash.display.Bitmap(bmp));
	}
	
	public function cleanup() {
		bmp.dispose();
	}
	
	public function reset() {
		bmp.fillRect(bmp.rect, 0);
		pixels = null;
	}
	
	public function draw( s : flash.display.DisplayObject, ?bits = 255 ) {
		var m = s.transform.matrix;
		m.scale(1 / div, 1 / div);
		var stage = flash.Lib.current.stage;
		var old = stage.quality;
		stage.quality = flash.display.StageQuality.LOW;
		ct.redOffset = bits;
		bmp.draw(s, m, ct);
		stage.quality = old;
		pixels = null;
	}
	
	public function glow( pixels : Int, ?bits = 1 ) {
		pixels = Math.ceil(pixels / div);
		bmp.applyFilter(bmp, bmp.rect, new flash.geom.Point(0, 0), new flash.filters.GlowFilter(bits << 16, 1, pixels, pixels, 1000, 3));
		this.pixels = null;
	}
	
	public function getPath( x1 : Int, y1 : Int, x2 : Int, y2 : Int, ?allowBits = 0 ) : Null<flash.Vector<Int>> {
		calculatePath(x2, y2, allowBits);
		return getCachedPath(x1, y1);
	}
	
	inline function getDist( addr : Int ) {
		return flash.Memory.getUI16(addr + delta) == mark ? ((flash.Memory.getByte(addr) & bitMask == 0) ? flash.Memory.getUI16(addr + delta + 2) : DMAX) : DMAX;
	}
	
	public function getCachedPath( x, y ) {
		x = Std.int(x / div);
		y = Std.int(y / div);
		if( x < 0 || y < 0 || x >= w || y >= h )
			throw "assert";
		flash.Memory.select(pixels);
		var addr = (x + y * w) << 2;
		var dist = getDist(addr);
		if( dist == DMAX )
			return null;
		var path = new flash.Vector();
		var write = -1, tmp;
		var hdiv = div >> 1;
		while( true ) {
			addr = (x + y * w) << 2;
			path[++write] = x * div + hdiv;
			path[++write] = y * div + hdiv;
			var dx = 0, dy = 0;
			if( x > 0 ) {
				if( (tmp = getDist(addr - 4)) < dist ) {
					dist = tmp;
					dx = -1;
					dy = 0;
				}
				if( diagonals ) {
					if( addr >= stride && (tmp = getDist(addr - 4 - stride)) < dist ) {
						dist = tmp;
						dx = -1;
						dy = -1;
					}
					if( addr < delta - stride && (tmp = getDist(addr - 4 + stride)) < dist ) {
						dist = tmp;
						dx = -1;
						dy = 1;
					}
				}
			}
			if( x < w - 1 ) {
				if( (tmp = getDist(addr + 4)) < dist ) {
					dist = tmp;
					dx = 1;
					dy = 0;
				}
				if( diagonals ) {
					if( addr >= stride && (tmp = getDist(addr + 4 - stride)) < dist ) {
						dist = tmp;
						dx = 1;
						dy = -1;
					}
					if( addr < delta - stride && (tmp = getDist(addr + 4 + stride)) < dist ) {
						dist = tmp;
						dx = 1;
						dy = 1;
					}
				}
			}
			if( y > 0 && (tmp = getDist(addr - stride)) < dist ) {
				dist = tmp;
				dx = 0;
				dy = -1;
			}
			if( addr < delta - stride && (tmp = getDist(addr + stride)) < dist ) {
				dist = tmp;
				dx = 0;
				dy = 1;
			}
			if( dx|dy == 0 ) break;
			x += dx;
			y += dy;
		}
		return path;
	}
	
	public function debugPath() {
		if( pixels != null ) {
			pixels.position = delta;
			bmp.setPixels(bmp.rect, pixels);
		}
		return bmp;
	}
	
	public function getDistance( x, y ) {
		x = Std.int(x / div);
		y = Std.int(y / div);
		if( x < 0 || y < 0 || x >= w || y >= h )
			throw "assert";
		var p = delta + ((x + y * w) << 2);
		var m = pixels[p] | (pixels[p + 1] << 8);
		if( m != mark )
			return -1;
		p += 2;
		var d = (pixels[p] | (pixels[p + 1] << 8)) * div;
		return diagonals ? (d >> 1) : d;
	}
	
	function initPixels() {
		if( pixels == null ) {
			pixels = bmp.getPixels(bmp.rect);
			pixels.length += delta;
			mark = 0x80;
		}
		mark++;
		flash.Memory.select(pixels);
	}
	
	public function getRecall( x, y, ?allowBits = 0 ) {
		x = Std.int(x / div);
		y = Std.int(y / div);
		if( x < 0 || y < 0 || x >= w || y >= h )
			throw "assert";
		initPixels();
		var stack = new flash.Vector<Int>();
		var bitMask = 0xFF - allowBits;
		var total = 0;
		this.bitMask = bitMask;
		stack.push(x);
		stack.push((x + y * w) << 2);
		stack.push(1);
		var distDelta = diagonals ? 2 : 1;
		var minDist = DMAX, minAddr = -1;
		while( true ) {
			var read = -1, write = stack.length - 1;
			if( write < 0 ) break;
			while( read < 3000 && read < write ) {
				var x = stack[++read];
				var addr = stack[++read];
				var dist = stack[++read];
				var infos = delta + addr;
				total++;
				if( flash.Memory.getUI16(infos) == mark && flash.Memory.getUI16(infos + 2) <= dist )
					continue;
				flash.Memory.setI16(infos, mark);
				flash.Memory.setI16(infos + 2, dist);
				if( flash.Memory.getByte(addr) & bitMask == 0 ) {
					if( dist < minDist ) {
						minDist = dist;
						minAddr = addr;
					}
					continue;
				}
				dist += distDelta;
				if( dist >= minDist )
					continue;
				if( x > 0 ) {
					stack[++write] = x - 1;
					stack[++write] = addr - 4;
					stack[++write] = dist;
				}
				if( x < w - 1 ) {
					stack[++write] = x + 1;
					stack[++write] = addr + 4;
					stack[++write] = dist;
				}
				if( addr >= stride ) {
					stack[++write] = x;
					stack[++write] = addr - stride;
					stack[++write] = dist;
				}
				if( addr < delta - stride ) {
					stack[++write] = x;
					stack[++write] = addr + stride;
					stack[++write] = dist;
				}
				if( diagonals ) {
					dist++;
					if( dist >= minDist )
						continue;
					if( x > 0 ) {
						if( addr >= stride ) {
							stack[++write] = x - 1;
							stack[++write] = addr - 4 - stride;
							stack[++write] = dist;
						}
						if( addr < delta - stride ) {
							stack[++write] = x - 1;
							stack[++write] = addr - 4 + stride;
							stack[++write] = dist;
						}
					}
					if( x < w - 1 ) {
						if( addr >= stride ) {
							stack[++write] = x + 1;
							stack[++write] = addr + 4 - stride;
							stack[++write] = dist;
						}
						if( addr < delta - stride ) {
							stack[++write] = x + 1;
							stack[++write] = addr + 4 + stride;
							stack[++write] = dist;
						}
					}
				}
			}
			read++;
			stack.splice(0, read);
		}
		statsPixels = total;
		return (minDist == DMAX) ? null : { x : ((minAddr % stride) >> 2) * div, y : Std.int(minAddr / stride) * div, dist : (minDist * div) >> (diagonals?1:0) };
	}
	
	public function inverse() {
		var pixels = bmp.getPixels(bmp.rect);
		flash.Memory.select(pixels);
		var p = 0;
		while( p < delta ) {
			flash.Memory.setByte(p, 0xFF - flash.Memory.getByte(p));
			p++;
			flash.Memory.setByte(p, 0xFF - flash.Memory.getByte(p));
			p+=3;
		}
		pixels.position = 0;
		bmp.setPixels(bmp.rect, pixels);
		this.pixels = null;
	}
	
	public function fillHole() {
		initPixels();
		var stack = new flash.Vector<Int>();
		stack.push(w >> 1);
		stack.push(h >> 1);
		var border = false;
		
		while( true ) {
			var read = -1, write = stack.length - 1;
			if( write < 0 ) break;
			while( read < 3000 && read < write ) {
				var x = stack[++read];
				var y = stack[++read];
				var addr = (x + y * w) << 2;
				if( flash.Memory.getByte(addr) != 0 ) continue;
				flash.Memory.setByte(addr, 0xFF);
				if( x > 0 ) {
					stack[++write] = x - 1;
					stack[++write] = y;
				} else border = true;
				if( x < w - 1 ) {
					stack[++write] = x + 1;
					stack[++write] = y;
				} else border = true;
				if( addr >= stride ) {
					stack[++write] = x;
					stack[++write] = y - 1;
				} else border = true;
				if( addr < delta - stride ) {
					stack[++write] = x;
					stack[++write] = y + 1;
				} else border = true;
			}
			read++;
			stack.splice(0, read);
		}
				
		for( dx in -4...4 )
			for( dy in -4...4 ) {
				if( dx * dx + dy * dy > 16 ) continue;
				var x = (w >> 1) + dx;
				var y = (h >> 1) + dy;
				flash.Memory.setByte((x + y * w) << 2, 0xFF);
			}

		pixels.position = 0;
		bmp.setPixels(bmp.rect, pixels);
		this.pixels = null;
		return !border;
	}
	
	public function calculatePath( x, y, ?allowBits = 0 ) {
		x = Std.int(x / div);
		y = Std.int(y / div);
		if( x < 0 || y < 0 || x >= w || y >= h )
			throw "assert";
		initPixels();
		var stack = new flash.Vector<Int>();
		var bitMask = 0xFF - allowBits;
		var total = 0;
		this.bitMask = bitMask;
		stack.push(x);
		stack.push((x + y * w) << 2);
		stack.push(1);
		var distDelta = diagonals ? 2 : 1;
		while( true ) {
			var read = -1, write = stack.length - 1;
			if( write < 0 ) break;
			while( read < 3000 && read < write ) {
				var x = stack[++read];
				var addr = stack[++read];
				var dist = stack[++read];
				var infos = delta + addr;
				total++;
				if( flash.Memory.getUI16(infos) == mark && flash.Memory.getUI16(infos + 2) <= dist )
					continue;
				flash.Memory.setI16(infos, mark);
				flash.Memory.setI16(infos + 2, dist);
				if( flash.Memory.getByte(addr) & bitMask != 0 )
					continue;
				dist += distDelta;
				#if debug
				// this will result into a negative distance
				if( dist >= DMAX ) throw "assert";
				#end
				if( x > 0 ) {
					stack[++write] = x - 1;
					stack[++write] = addr - 4;
					stack[++write] = dist;
				}
				if( x < w - 1 ) {
					stack[++write] = x + 1;
					stack[++write] = addr + 4;
					stack[++write] = dist;
				}
				if( addr >= stride ) {
					stack[++write] = x;
					stack[++write] = addr - stride;
					stack[++write] = dist;
				}
				if( addr < delta - stride ) {
					stack[++write] = x;
					stack[++write] = addr + stride;
					stack[++write] = dist;
				}
				if( diagonals ) {
					dist++;
					if( x > 0 ) {
						if( addr >= stride ) {
							stack[++write] = x - 1;
							stack[++write] = addr - 4 - stride;
							stack[++write] = dist;
						}
						if( addr < delta - stride ) {
							stack[++write] = x - 1;
							stack[++write] = addr - 4 + stride;
							stack[++write] = dist;
						}
					}
					if( x < w - 1 ) {
						if( addr >= stride ) {
							stack[++write] = x + 1;
							stack[++write] = addr + 4 - stride;
							stack[++write] = dist;
						}
						if( addr < delta - stride ) {
							stack[++write] = x + 1;
							stack[++write] = addr + 4 + stride;
							stack[++write] = dist;
						}
					}
				}
			}
			read++;
			stack.splice(0, read);
		}
		statsPixels = total;
	}
	
}