class Cs{//}

	
	static var mcw = 300
	static var mch = 300
	
	static var game:Game;
	
	static var C0 = KKApi.const(0);
	static var C5 = KKApi.const(5);
	static var C10 = KKApi.const(10);
	static var C30 = KKApi.const(30);
	static var C50 = KKApi.const(50);
	static var C100 = KKApi.const(100);
	static var C120 = KKApi.const(120);
	static var C200 = KKApi.const(200);
	static var C300 = KKApi.const(300);
	static var C1000 = KKApi.const(1000);
	static var C5000 = KKApi.const(5000);	
	static var C8000 = KKApi.const(8000);
	
	static function setPercentColor( mc, prc, col ){	
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new Color(mc)
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
		co.setTransform( ct );
	}	
	
	static function mm(a,b,c){
		return Math.min(Math.max(a,b),c);
	}
	
	static function colToObj32(col){
		return {
			a:col>>>24
			r:(col>>16)&0xFF,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	
	static function glow(mc,d,s,col){
		var fl = new flash.filters.GlowFilter();
		fl.blurX = d;
		fl.blurY = d;
		fl.color = col;
		fl.strength = s
		var a = mc.filters
		a.push(fl)
		mc.filters = a
		
	}	

	static function sMod(n,mod){
		if(n>=mod)n-=mod;
		if(n<0)n+=mod;
		return n;
	}
	static function objToCol(o){
			return (o.r << 16) | (o.g<<8 ) | o.b
	}		
		
//{	
}