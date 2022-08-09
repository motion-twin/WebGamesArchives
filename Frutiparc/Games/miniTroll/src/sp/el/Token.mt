class sp.el.Token extends sp.Element{//}
	
	// CONSTANTE
	var flGroupable:bool;
	var type:int;
	var special:int;
	var group:Group;
	var col:Color;
	
	var bm:MovieClip;
	
	
	function new(){
		et = 0;
		super();
		special = 0;
		flGroupable = true;
		link = "token";
		/*
		colorList = [
			{ r:255,	g:20,	b:0 	},
			{ r:255,	g:190,	b:0 	},
			{ r:20,		g:200,	b:0 	},
			{ r:100,		g:0,	b:200 	}
		
		]

		colorList = [
			0xFF3300,
			0xFFCC00,
			0x33DD00,
			0x00DDFF,
			0x8800DD
		
		]
		*/
	}

	function init(){
		super.init();
		//setType(type)
	}

	function updateSkin(){
		super.updateSkin()
		//
		var mc = downcast(skin).skin
		Mc.setColor(mc,Cs.colorList[type])
		Mc.modColor(mc,1,25)
		
		
		skin.stop()
		Std.cast(skin).skin.stop()
		
		if(special!=null)setSpecial(special);
		
	}	
		
	function setType(t){
		type = t
		//skin.gotoAndStop(string(t+1))
		updateSkin();
	}
	
	function setSpecial(n){
		
		switch(special){	// WAS
			case 0:
				break;
			case 1:		// POINT
				bm.removeMovieClip();
				break;
			case 2:		// ARMURE
				break;			

		}		
		
		special = n
		
		switch(special){	// WILL
			case 0:
				flGroupable = true;
				skin.gotoAndStop("1")
				Std.cast(skin).skin.gotoAndStop("1")
				break;
			case 1:		// POINT
				flGroupable = true;
				bm = Std.attachMC( Std.cast(skin).skin, "mcBlackMarble", 5 )
				bmEnlight();
			
				break;
			case 2:		// ARMURE
				flGroupable = false;
				skin.gotoAndStop("20")
				Std.cast(skin).skin.gotoAndStop("20")
				/*
				var col = new Color(Std.cast(skin).skin.d);
				var light = 880
				var o = {
					ra:100,
					ga:100,
					ba:100,
					aa:100,
					rb:light,
					gb:light,
					bb:light,
					ab:0,
				}
				col.setTransform(o)
				*/
				break;
			case 3:		// ETOILE
				flGroupable = true;
				bm = Std.attachMC( Std.cast(skin).skin, "mcTokenStar", 5 )				
				bmEnlight();
				break;

		}
	}
	
	
	
	function blast(){
		super.blast();
		switch(special){
			case 2:
				setSpecial(0);
				roundBlink();
				break;
		}
	}
	
	function isolate(){
		Std.cast(skin).skin.gotoAndStop("1")
		skin.gotoAndStop("1")
		setSpecial(special)
		group.removeElement(this);
		
	}
	
	function bmEnlight(){
		var col = new Color(bm);
		var light = 100
		var o = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:light,
			gb:light,
			bb:light,
			ab:0,
		}
		col.setTransform(o)	
	}
	
	// FX
	function fxCrystal(){
		for( var i=0; i<10; i++ ){
			var sp = Cs.game.newPart("partElementCrystal",null);
			sp.x = x+Cs.game.ts*0.5
			sp.y = y+Cs.game.ts*0.5
			var a = Math.random()*6.28
			var p = 2+Math.random()*6
			sp.vitx = Math.cos(a)*p
			sp.vity = Math.sin(a)*p
			sp.vitr = (Math.random()*2-1)*10
			sp.timer = 5+Math.random()*10
			sp.scale = 20+Math.random()*50
			sp.init();
			
			sp.skin._rotation = Math.random()*360

			//var token:sp.el.Token = downcast(e)
			Mc.setColor(sp.skin, Cs.colorList[type])
			Mc.modColor(sp.skin, 1, 60)

		}	
	}
	
	function explode(){
		super.explode();
		fxCrystal();
	}
	
	
	
//{
}




