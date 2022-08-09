class kaluga.AnimLoader extends kaluga.Slot{//}

	// CONSTANTES
	
	// PARAMETRES
	var width:Number;
	var height:Number;
	var link:String;
	
	// VARIABLES

	// REFERENCES

	// MOVIECLIP
	var mcl:MovieClipLoader;
	//var mask:MovieClip;
	var anim:MovieClip;
	var loading:MovieClip;
	
	function AnimLoader(){
		this.init();
	}
	
	function init(){
		_root.test += "[AnimLoader] init("+link+")\n"
		this.initLoad();
		
		this.onPress = function(){
			this.mng.backToMenu();
			
		}
		
		
	}
	
	function initLoad(){
		this.attachMovie("loadingAnim","loading",12)
		this.createEmptyMovieClip("anim",10)
		//this.createEmptyMovieClip("cadre",4)
		this.anim.createEmptyMovieClip("mc",1)
		this.anim.mc.createEmptyMovieClip("mc",1)
		this.anim.createEmptyMovieClip("mask",2)
		
		var x = (kaluga.Cs.mcw-this.width)/2
		var y = (kaluga.Cs.mch-this.height)/2
		var pos = { x:0, y:0, w:this.width, h:this.height }
		kaluga.MC.drawSquare( this.anim.mask, pos, 0xFF0000 );
		
		var d = 6
		var col = [0x9DBE5F,0xBAD595]
		for( var i=2; i>0; i--){
			var pos = {
				x:-i*d,
				y:-i*d,
				w:i*d*2 + this.width,
				h:i*d*2 + this.height
			}
			kaluga.MC.drawSquare( this.anim, pos, col[2-i] );
		}
		
		this.anim._x = x;
		this.anim._y = y;
		this.anim.mc.setMask(this.anim.mask);
		
		// LOADING
		this.loading._x = kaluga.Cs.mcw/2
		this.loading._y = kaluga.Cs.mch/2
					
		// MCL
		this.mcl = new MovieClipLoader();
		var listener = new Object();
		listener.obj = this
		listener.onLoadComplete = function(){
			this.obj.loading.removeMovieClip();
		}
		listener.onLoadProgress = function(mc,l,t){
			this.obj.loading.b._xscale = 100 * (l/t);
		}		
		this.mcl.addListener(listener)
		
		var name  = this.mng.client.getFileInfos(this.link).name
		this.mcl.loadClip( name, this.anim.mc.mc );
		
	};
	
	// SLOT

	function update(){
		//_root.test+="o"

	}	

	function kill(){
		super.kill();
	}	
		
//{	
}




