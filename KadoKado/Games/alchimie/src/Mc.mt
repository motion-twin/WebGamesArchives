class Mc extends MovieClip{//}
// 	


	static function setPercentColor( mc:MovieClip, prc, col ){
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new Color(mc);
		var c  = prc/100
		var ct = {
			ra:int(100-prc),
			ga:int(100-prc),
			ba:int(100-prc),
			aa:100,
			rb:int(c*color.r),
			gb:int(c*color.g),
			bb:int(c*color.b),
			ab:0
		};
		co.setTransform(ct);
	}
	

	/*
	static function noiseColor(mc,max){
		var color = new Color(mc)
		var  o = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:(Math.random()*2-1)*max,
			gb:(Math.random()*2-1)*max,
			bb:(Math.random()*2-1)*max,
			ab:0,
		}
		color.setTransform(o)
	}		
	*/
//{
}


















