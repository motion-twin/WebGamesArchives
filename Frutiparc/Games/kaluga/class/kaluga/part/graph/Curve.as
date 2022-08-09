class kaluga.part.graph.Curve extends kaluga.part.Graph{//}

	
	// VARIABLES
	var color:Object;
	var flNumber:Boolean;
	var flGhost:Boolean;
	var flLine:Boolean;
	var flCurve:Boolean;
	var flNode:Boolean;
	var nodeFrame:Boolean;
	var line:Number;
	var lineBase:Number;
	var lineSuffix:String;
	var maxResult:Number;
	var margin:Number;
	var marginInt:Number;
	var marginUp:Number;
	var list:Array;
	
	// MOVIECLIP
	var nodeLayer:MovieClip;
	var nodeMask:MovieClip;
	
	
	function Curve(){
		this.init();
	}
	
	function init(){
		
		if(this.color==undefined){
			this.color = {
				main:0xF5F8F0,
				curve:0xBAD595,
				line:0xDFEACA,				ghost:0xFF0000
			}
		}
		if(this.flCurve==undefined)this.flCurve=true;
		if(this.marginInt==undefined)this.marginInt=0;
		if(this.marginUp==undefined)this.marginUp=0;
		super.init();
	}
	
	function draw(){
		super.draw()
		
		//var size = ( this.box.w-(this.margin*2 + (this.maxResult-1)*this.marginInt) )/this.maxResult
		
		var pos = {
			x:this.box.x+this.margin,
			y:this.box.y+this.margin,
			w:this.box.w-2*this.margin,
			h:this.box.h-2*this.margin			
		}
		// LINE
		if(this.flLine){
			this.lineStyle(1,this.color.line);
			var coef=this.line;
			var h = this.lineBase
			
			var d = 0;
			while(coef<1){
				d++
				var y = (pos.y+pos.h) - coef*(pos.h-this.marginUp)
				this.moveTo( pos.x,		y	);
				this.lineTo( pos.x+pos.w,	y	);
				var p = {x:pos.x, y:y-14,w:pos.x+50,h:16}
				this.createField( this, h+this.lineSuffix, p, d )
				h+=this.lineBase
				coef+=this.line;
			}
			
		}
		// BOARD
		this.lineStyle(1,this.color.curve);
		this.moveTo( pos.x,	 	pos.y		);
		this.lineTo( pos.x,	 	pos.y+pos.h	);
		this.lineTo( pos.x+pos.w, 	pos.y+pos.h 	);
		this.lineTo( pos.x+pos.w, 	pos.y		);		
		
		//NODE 
		if(this.flNode){
			this.createEmptyMovieClip("nodeLayer",67);
			/*
			this.attachMovie("mask","nodeMask",68);
			this.nodeMask._x = pos.x
			this.nodeMask._y = pos.y
			this.nodeMask._width = pos.w
			this.nodeMask._height = pos.h
			this.nodeLayer.setMask(this.nodeMask);
			*/
		}
		
		// MAIN
		if(this.flCurve){
			this.lineStyle(1,this.color.curve);
			this.moveTo( pos.x+this.marginInt,		pos.y+pos.h	)
			this.beginFill(this.color.main);
		}
		
		var step = (pos.w-this.marginInt*2)/(this.list.length-1);
		
		for( var i=0; i<this.list.length; i++ ){
			
			var data = list[i];
			//_root.test+="data("+data.value+","+data.ghost+")\n"
			var x = pos.x + this.marginInt + i*step
			var y = pos.y+pos.h - (data.value*(pos.h-this.marginUp))
			if(this.flCurve){			
				this.lineTo( x,	y )
			};
			if(this.flNode){
				var d = i+100
				this.nodeLayer.attachMovie("node","node"+d,100+d);
				var mc = this.nodeLayer["node"+d]
				mc._x = x;
				mc._y = y;
				mc.gotoAndStop(this.nodeFrame)
			};
		};
		if(this.flCurve){
			this.lineTo( pos.x+(pos.w-this.marginInt),	pos.y+pos.h)
			this.endFill();
		}
		
		//GHOST
		if(this.flGhost){
			//this.lineStyle(1,this.color.ghost,20);
			//this.moveTo( pos.x,		pos.y+pos.h	)
			for( var i=0; i<this.list.length; i++ ){
				var data = list[i];
				var x = pos.x + this.marginInt + i*step
				var y = pos.y+pos.h - (data.ghost*(pos.h-this.marginUp))
				if(this.flNode){
					var d = i
					this.nodeLayer.attachMovie("node","node"+d,d);
					var mc = this.nodeLayer["node"+d]
					mc._x = x;
					mc._y = y;
					mc._alpha = 20;
					mc.gotoAndStop(this.nodeFrame)
				}				
				
			}
		}
		
	}

	
//{	
}