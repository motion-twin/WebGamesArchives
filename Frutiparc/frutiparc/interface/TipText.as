class TipText extends MovieClip{//}

	// CONSTANTES
	var mx:Number = 5;
	var my:Number = 2;
	
	
	// PARAMETRES
	var doc:XML;
	var pageObj:Object;
		// OPTIONELS
		var width:Number;	// def:100
		var height:Number;	// def:40
		var cx:Number;		// 0 - 0.5 - 1		def:0
		var cy:Number;		// 0 - 0.5 - 1		def:0
		
		var dx:Number;
		var dy:Number;
	

	
	// VARIABLES
	//var flDoc:Boolean;
	var style:Object;
	var mcDoc:cp.Document;
	var alpha:Number;
	var aid:Number;

	
	function TipText(){
		this.init();
	}
	
	function init(){
		//_root.test+="[TipText]init()\n"
		
		/* HACK TEST
		this.pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			big:true,
			lineList:[]		
		}
		this.pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							text: "bonjour.fr propose 300.000 petites annonces de particuliers et de professionnels (voitures d’occasion, annonces immobilieres, offres d’emploi, occasions "
						}
					}
				]
			}
		);
		//*/
		this.initDefault();
		this.initDoc();
		//this.flDoc = false;
		this.alpha = 0
		this._alpha = 0
		this.aid = setInterval(this,"updateAlpha",25)
		//*
	}
	
	function initDefault(){
		if( this.width == undefined )		this.width = 120;
		if( this.cx == undefined )		this.cx = 0;
		if( this.cy == undefined )		this.cy = 0;
		if( this.dx == undefined )		this.dx = 0;
		if( this.dy == undefined )		this.dy = 20;
		if(this.style==undefined)		this.style = Standard.getWinStyle();
	}
	
	function initPos(){
		this._x = _xmouse - (this.width  * this.cx) + this.dx;
		this._y = _ymouse - (this.height * this.cy) + this.dy;
		this.recal();
	}
	
	function drawBackground(w,h){

		
		this.dropShadow();
		
		var col = _global.colorSet.green
		
		// CONTOUR
		var info ={
			outline:1,
			inline:2,	
			curve:6,
			color:{
				main:		col.light,
				inline:		col.light,
				outline:	col.darker
			}
		}
		var p = {x:0,y:0,w:this.width,h:this.height};
		FEMC.drawCustomSquare(this,p,info,true)
		
		//INSIDE
		var m = 4
		var p = { x:m, y:m, w:this.width-2*m, h:this.height-2*m };

		var info = {
			inline:1,
			outline:2,
			curve:3,
			color:{
				main:		col.main,
				inline:		col.shade,
				outline:	col.dark
			}	
		}		
		FEMC.drawCustomSquare(this,p,info,true)
		
		
	};
	
	function recal(){
		if( this._x+this.width > _global.mcw ){
			this._x = _global.mcw-this.width
		}
		if( this._x < 0 ){
			this._x = 0
		}
		if( this._y+this.height > _global.mch ){
			this._y = _global.mch-this.height
		}
		if( this._y < 0 ){
			this._y = 0
		}
	}
	
	function initDoc(){
		//this.flDoc = true;
		var ws = Standard.getWinStyle();
		var initObj={
			//flTrace:true,
			pageObj:this.pageObj,
			doc:this.doc,
			docStyle:Standard.getDocStyle(ws.frDir)
		};
		
		this.attachMovie( "cpDocument", "mcDoc", 10, initObj );

		this.mcDoc._x = mx
		this.mcDoc._y = my
		this.mcDoc.extWidth = this.width-2*this.mx;
		this.mcDoc.updateSize();
		
		//
		this.height = this.mcDoc.getHeight()+this.my*2;
		
		this.initPos();
		this.drawBackground();
		this.mcDoc._visible = false;
		//
	}
	
	function kill(){
		if(this.aid!=undefined)clearInterval(this.aid);
		this.removeMovieClip();
	}
	
	function updateAlpha(){
		//_root.test+="updateAlpha\n"
		if( !this.mcDoc._visible && this.alpha>99 ){
			this.alpha = 100
			this.mcDoc._visible = true
			clearInterval(this.aid)
			delete this.aid;
			//this.initDoc();
		}
		this.alpha = this.alpha*0.6 + 100*0.4
		this._alpha = this.alpha
		this._xscale = this.alpha
		this._yscale = this.alpha		
		
	}
	
	function dropShadow(){

		//_root.test+="graph\n"
		var ray = 10//18
		var inside = 5
		var colIn = 0 //0xFFFFFF 0x5E8921
		var colOut = 0 //0xFFFFFF 
		var alphaIn = 50
		var alphaOut = 0		
		var pos = {
			x: inside,
			y: inside,
			w: this.width - inside,
			h: this.height - inside
		}
		var g = {
			type:"radial",
			colors:[ colIn, colOut ],
			alphas:[ alphaIn, alphaOut ],
			ratios:[ 0, 0xFF ]
		}
		// CORNER A :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.y-ray, w:2*ray, h:2*ray, r:0}
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.x,	pos.y-ray	)
		this.lineTo(	pos.x,	pos.y	)
		this.lineTo(	pos.x-ray,	pos.y	)
		this.lineTo(	pos.x-ray,	pos.y-ray	)
		this.endFill();
		// CORNER B :
		var matrix={ matrixType:"box", x:pos.w-ray, y:pos.y-ray, w:2*ray, h:2*ray, r:0}
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.w,		pos.y-ray	)
		this.lineTo(	pos.w,		pos.y	)
		this.lineTo(	pos.w+ray,	pos.y	)
		this.lineTo(	pos.w+ray,	pos.y-ray	)
		this.endFill();		
		// CORNER C :
		var matrix={ matrixType:"box", x:pos.w-ray, y:pos.h-ray, w:2*ray, h:2*ray, r:0}
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.w,		pos.h	)
		this.lineTo(	pos.w,		pos.h+ray	)
		this.lineTo(	pos.w+ray,	pos.h+ray	)
		this.lineTo(	pos.w+ray,	pos.h	)
		this.endFill();
		// CORNER D :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.h-ray, w:2*ray, h:2*ray, r:0}
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.x-ray,	pos.h		)
		this.lineTo(	pos.x,		pos.h		)
		this.lineTo(	pos.x,		pos.h+ray	)
		this.lineTo(	pos.x-ray,	pos.h+ray	)
		this.endFill();

		var g = {
			type:"linear",
			colors:[ colOut, colIn ],
			alphas:[  alphaOut, alphaIn ],
			ratios:[ 0, 0xFF ]
		}
		// LINE A :
		var matrix={ matrixType:"box", x:pos.x, y:pos.y-ray, w:pos.w, h:ray, r:Math.PI/2 }
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.x,		pos.y-ray	)
		this.lineTo(	pos.w,		pos.y-ray	)
		this.lineTo(	pos.w,		pos.y	)
		this.lineTo(	pos.x,		pos.y	)
		this.endFill();
		// LINE B :
		var matrix={ matrixType:"box", x:pos.w, y:pos.y, w:ray, h:pos.h, r:Math.PI }
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.w,		pos.y		)
		this.lineTo(	pos.w+ray,	pos.y		)
		this.lineTo(	pos.w+ray,	pos.h		)
		this.lineTo(	pos.w,		pos.h		)
		this.endFill();		
		// LINE C :
		var matrix={ matrixType:"box", x:pos.x, y:pos.h, w:pos.w, h:ray, r:-Math.PI/2 }
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.x,		pos.h		)
		this.lineTo(	pos.w,		pos.h		)
		this.lineTo(	pos.w,		pos.h+ray		)
		this.lineTo(	pos.x,		pos.h+ray		)
		this.endFill();		
		// LINE D :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.y, w:ray, h:pos.h, r:0 }
		this.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.moveTo(	pos.x-ray,		pos.y		)
		this.lineTo(	pos.x,		pos.y		)
		this.lineTo(	pos.x,		pos.h		)
		this.lineTo(	pos.x-ray,		pos.h		)
		this.endFill();			
		
		
		
	}
	
	
	
	
	
//{	
}