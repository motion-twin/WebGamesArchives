class Mc extends MovieClip{//}
// 	

	
	static function setColor(mc:MovieClip,col){
		var mco = Std.cast(mc)
		if( mco.colorObject == null )initColor(mco);
		var c = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		}
		mco.colorTransform = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:c.r-255,
			gb:c.g-255,
			bb:c.b-255,
			ab:0
		}
		mco.colorObject.setTransform( mco.colorTransform )
	}
	
	static function modColor(mc:MovieClip,coef,inc){
		var mco = Std.cast(mc)
		if( mco.colorObject == null )initColor(mco);
		
		mco.colorTransform.ra *= coef;
		mco.colorTransform.ga *= coef;
		mco.colorTransform.ba *= coef;
		mco.colorTransform.rb += inc;
		mco.colorTransform.gb += inc;
		mco.colorTransform.bb += inc;

				
		mco.colorObject.setTransform( mco.colorTransform )
	}
	
	static function initColor(mco){
		mco.colorObject = new Color(mco)
		mco.transform  = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:0,
			gb:0,
			bb:0,
			ab:0
		}
	}	
	
	static function setPercentColor( mc:MovieClip, prc, col ){
		
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		
		var mco = Std.cast(mc)
		if( mco.colorObject == null )initColor(mco);
		
		var c  = prc/100
		mco.colorTransform = {
			ra:int(100-prc),
			ga:int(100-prc),
			ba:int(100-prc),
			aa:100,
			rb:int(c*color.r),
			gb:int(c*color.g),
			bb:int(c*color.b),
			ab:0
		};
		mco.colorObject.setTransform( mco.colorTransform );
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


















