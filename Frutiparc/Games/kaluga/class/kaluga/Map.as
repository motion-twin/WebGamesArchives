class kaluga.Map extends MovieClip{//}
	
	// CONSTANTES
	var dp_scroller:Number = 650;
	var lineMax:Number = 30
	var scrollGroundHeight:Number = 30
	var groundLevel:Number = 10;
	var distance:Number = 50
	var zoomCoef:Number = 4;
	var bitmapWidth:Number = 1000;
	var rulerStep:Number = 200
	
	// VARIABLES
	var flScroll:Boolean;
	var flRuler:Boolean;
	var height:Number;
	var width:Number;
	var linkGround:String;
	var mapUrl:String;
	var lineList:Array;
	var groundLabel:String;
	var scrollerInfo:Object;
	
	// REFERENCE
	var game:kaluga.Game;
	var rulerCompteurList:Array;
	
	// MovieClip
	var mcl:Object;
	var bg:MovieClip;
	var scroller:MovieClip;
	var ground:MovieClip;
	var ruler:MovieClip;
	
	function Map(){
		this.init();
	}
	
	function init(){
		this.initDefault();
		this.initGround();
		if(this.scrollerInfo!=undefined){
			this.initScroller();
		}
		

	}
	
	function initDefault(){
		if( this.width == undefined ) this.width = kaluga.Cs.mcw;
		if( this.height == undefined ) this.height = kaluga.Cs.mch;
		if( this.groundLabel == undefined ) this.groundLabel = "base";
	}
	
	function initScroller(){
		//_root.test+="initScroller()\n"
		
		this.createEmptyMovieClip("scroller",this.dp_scroller);
		this.scroller.createEmptyMovieClip("line",10)
		
		var o = this.scrollerInfo
		
		// DEFAULT
		if( o.ecart == undefined )	o.ecart = 400;
		if( o.startPoint == undefined )	o.startPoint = 1400;
		if( o.largeur == undefined )	o.largeur = 10;
		if( o.coef == undefined )	o.coef = 0.1;
		
		// INIT SQUARE
		this.scroller.attachMovie("scrollerBg","bg",2);
		this.scroller.bg._xscale = kaluga.Cs.mcw
		this.scroller.bg._yscale = this.scrollerInfo.height
		this.scroller._y = kaluga.Cs.mch-(this.groundLevel+this.scrollerInfo.height);
		/*
		this.scroller.beginFill(0x88DD00)
		this.scroller.lineTo( kaluga.Cs.mcw, 0 )
		this.scroller.lineTo( kaluga.Cs.mcw, o.height )
		this.scroller.lineTo( 0, o.height )
		this.scroller.lineTo( 0, 0 )
		this.scroller._y = kaluga.Cs.mch-(this.groundLevel+this.scrollerInfo.height);
		this.scroller.endFill();
		*/
		
		
		// INIT LIST
		o.list= new Array();
		for( var i=o.startPoint; i<this.width; i+=o.ecart ){
			var p = { x:i, r:o.largeur }
			//if(i==0)p.r*=1.5;
			o.list.push(p)
		}		

	}
		
	function initGround(){
		this.game.attachMovie("groundBar","mcGround",this.game.dp_ground)
		this.game.mcGround._y = kaluga.Cs.mch
		this.game.mcGround.gotoAndStop(this.groundLabel)
	}

	function initRuler(startPoint){
		this.flRuler = true;
		this.rulerCompteurList = new Array()
		this.createEmptyMovieClip( "ruler", 200 );
		this.ruler.attachMovie( "ruler", "r", 1 );
		for(var i=0; i<6; i++){
			this.ruler.attachMovie( "rulerCompteur", "c"+i, 10+i);
			var mc = this.ruler["c"+i];
			mc._x = i*this.rulerStep;
			this.rulerCompteurList.push(mc)
		}
		this.ruler.startPoint = startPoint;
		
		
	};
		
	function update(){
		if(this.scrollerInfo!=undefined){
			updateScroller();
		}
		
		
		if(this.flRuler){
			this.ruler._x = this.game.mapDecal.x%this.rulerStep;
			var d = Math.floor((-this.ruler.startPoint-this.game.mapDecal.x)/this.rulerStep);
			if( d != this.ruler.d ){
				for(var i=0; i<this.rulerCompteurList.length; i++){
					var mc = this.rulerCompteurList[i];
					mc.field.text = (i+d)*200
				}
			}
			this.ruler.d = d
		}
		if(this.flScroll){
			this.ground._y = this.game.mapDecal.y + (this.height-this.groundLevel)
		}
			
	}
		
	function loadBackground(url,flResize){
		this.createEmptyMovieClip("bg",2)
		var mcl = new MovieClipLoader();
		mcl.game = this.game
		//_root.test+="mcl.loadClip("+url+","+this.bg+") mcl("+mcl.loadClip+")\n"
		mcl.loadClip(url,this.bg);
		mcl.onLoadStart = function(mc){
			//_root.test+="loadStart\n"
		}
		mcl.onLoadComplete = function(mc){
			//_root.test+="loadComplete ("+this.game.initGame+")\n"
			this.game.initGame();
		}
		mcl.onLoadError = function(mc,error){
			_root.test+="loadError("+error+","+mc+")\n"
		}		
		
		
	}
	
	function updateScroller(){
	
		// CLEAN
		this.scroller.line.clear();
		
		// DRAW
		var list = this.scrollerInfo.list;
		//var c = this.scrollerInfo.coef
		var h = this.scrollerInfo.height;
		var dx = this.game.mapDecal.x;
		for( var i=0; i<list.length; i++ ){
			var p = list[i];
			
			var x = kaluga.Cs.mch/2 + ( p.x + dx ) * this.scrollerInfo.coef
			//_root.test ="c("+this.scrollerInfo.coef+")\n"
			var a = {
				x:x-p.r*this.scrollerInfo.coef,
				y:0
			}
			var b = {
				x:x+p.r*this.scrollerInfo.coef,
				y:0
			}
			var x = p.x+dx
			var c = {
				x:x+p.r,
				y:h
			}
			var d = {
				x:x-p.r,
				y:h
			}
			/*
			if(i==(list.length-1)){
		
				_root.test = "drawLine ("+a.x+","+a.y+")\n"
				_root.test += "         ("+b.x+","+b.y+")\n"
				_root.test += "         ("+c.x+","+c.y+")\n"
				_root.test += "         ("+d.x+","+d.y+")\n"
					
			}
			*/
			this.clip(a,b,d,c,0,kaluga.Cs.mcw)
				this.drawLine(a,b,c,d)
		}
	}
	
	function drawLine(a,b,c,d){

		this.scroller.line.beginFill( 0xFFFFFF );
		this.scroller.line.moveTo( a.x, a.y )
		this.scroller.line.lineTo( b.x, b.y )
		this.scroller.line.lineTo( c.x, c.y )
		this.scroller.line.lineTo( d.x, d.y )
		this.scroller.line.endFill();	
		
	}

	function clip(p1,p2,p3,p4,min_x,max_x) {  
		if( p3.x < min_x && p4.x < min_x ) { 
			var a = (p2.y - p4.y) / (p2.x - p4.x);  
			var b = p2.y - a * p2.x;  
			var dx = p3.x - p4.x;  
			var p3x = Math.min(min_x,p1.x); 
			p3.x = p3x;  
			p3.y = p3x * a + b;  
			p4.x = min_x;  
			p4.y = (min_x - dx) * a + b;  
			return p1.x < min_x && p2.x < min_x;
		} else if( p3.x > max_x && p4.x > max_x )  {  
			var a = (p1.y - p3.y) / (p1.x - p3.x);  
			var b = p1.y - a * p1.x;  
			var dx = p3.x - p4.x;  
			var p3x = Math.max(max_x,p1.x);  
			p3.x = p3x;  
			p3.y = p3x * a + b;  
			p4.x = max_x; 
			p4.y = (max_x - dx) * a + b;  
			return p1.x > max_x && p2.x > max_x;
		} else
			return false;
	}
	
	
	
	
	
//{	
}