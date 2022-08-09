class Mc extends MovieClip{//}
// 	

	// COMPATIBILITE
	static function setPColor(mc,col:int,percent:float){

		//mc = Std.cast(mc)
		
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		}

		
		if(mc.colorObject==null){
			mc.colorObject = {
				actual:{
					col:{r:0,g:0,b:0},
					percent:100
				},
				col:null
			}
			mc.colorObject.col = new Color(mc)
		}
	
		if(color!=null)mc.colorObject.actual = { col:color, percent:percent };
		
		var act = mc.colorObject.actual
		
		var coef = (100-act.percent)/100
		var r = Math.round(act.col.r * coef)
		var g = Math.round(act.col.g * coef)
		var b = Math.round(act.col.b * coef)
		
		
		var tr = {
			ra:Math.round(act.percent),
			ga:Math.round(act.percent),
			ba:Math.round(act.percent),
			aa:100,	
			rb:r,
			gb:g,
			bb:b,
			ab:0
		}

		mc.colorObject.col.setTransform(tr)
		
	};
	
	
	static function setColor(mc:MovieClip,col){
		var mco = downcast(mc)
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
		var mco = downcast(mc)
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
		
		var mco = downcast(mc)
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
		
	static function shapeHitTest( mc, x , y ){
		return mc.hitTest(x,y,true)
	}	
	
	
//{
}