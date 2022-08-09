package mt.bumdum9;


class RGB {//}

	var r:Int;
	var g:Int;
	var b:Int;
	
	public function new(r:Int, g:Int, b:Int) {
		this.r = r;
		this.g = g;
		this.b = b;
	}
	
	public function getInt() 	return (r << 16) | (g << 8 ) | b
	
	
//{
}


class HSL {//}

	var hue:Float;
	var sat:Float;
	var lum:Float;
	
	public function new(hue, sat=1.0, lum=.5) {
		this.hue = hue;
		this.sat = sat;
		this.lum = lum;
	}
	
	public function toRGB() {
		
			var h = hue;
			
			var r:Float;
			var g:Float;
			var b:Float;

			if(lum==0){
				r=g=b=0;
			}else{
				if(sat == 0){
					r = g = b = lum;
				}else {
					
					var t2 = (lum<=0.5)? lum*(1+sat):lum+sat-(lum*sat);
					var t1 = 2 * lum - t2;
					var t3 = [h + 1 / 3, h, h - 1 / 3];
					var clr = [0.0, 0.0, 0.0];
					
					for( i in 0...3 ) {
						
						if(t3[i] < 0)	t3[i] += 1;
						if(t3[i] > 1)	t3[i] -= 1;

						if(6 * t3[i] < 1)			clr[i] = t1 + (t2 - t1) * t3[i] * 6;
						else if(2 * t3[i] < 1)		clr[i] = t2;
						else if(3 * t3[i] < 2)		clr[i] = (t1 + (t2 - t1) * ((2 / 3) - t3[i]) * 6);
						else						clr[i] = t1;
							
					}
					
					r = clr[0];
					g = clr[1];
					b = clr[2];
				}
			}
			return new RGB(Std.int(r*255),Std.int(g*255),Std.int(b*255));
		
	}
	
	
//{
}
