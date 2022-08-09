class Mc extends MovieClip{//}
// 	

	static function setColor(mc:MovieClip,col){
		var c = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		}
		var o = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:c.r-255,
			gb:c.g-255,
			bb:c.b-255,
			ab:0
		}
		var color = new Color(mc)
		color.setTransform(o)
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


















