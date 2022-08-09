class kaluga.part.graph.Bar extends kaluga.part.Graph{//}

	// CONSTANTES
	var tSide:Number = 20
	var tSpace:Number = 5
	
	
	// VARIABLES
	var color:Object;
	var flNumber:Boolean;
	var flTriangle:Boolean;
	var margin:Number;
	var marginInt:Number;
	var list:Array;
	
	
	function Bar(){
		
		this.init();
	}
	
	function init(){
		_root.test += "[ PART GRAPH BAR ] init()\n"
		if(this.color==undefined){
			this.color = {
				main:0xF5F8F0,
				line:0xBAD595
			}
		}
		super.init();
		
	}
	
	function draw(){
		super.draw()
		var size = ( this.box.w-(this.margin*2 + (this.list.length-1)*this.marginInt) )/this.list.length
		for( var i=0; i<this.list.length; i++ ){
			var data = list[i];
			var h = data.value*(box.h-margin*2)
			if(this.flTriangle and h>this.tSide){
				this.createEmptyMovieClip( "bar"+i, i )
				var mc = this["bar"+i]
				mc.lineStyle(1,this.color.line);
				mc.beginFill(this.color.main);
				var pos = {
					x: this.box.x + this.margin + i*(size+this.marginInt),
					y: this.box.y + this.box.h - this.margin ,
					w: size,
					h: h
				}
				mc.moveTo( pos.x,	pos.y		);
				if(this.flTriangle){
					mc.lineTo( (pos.x+pos.w)-this.tSide,	pos.y		);
					mc.lineTo( pos.x+pos.w,			pos.y-this.tSide);
				}else{
					mc.lineTo( pos.x+pos.w,	pos.y		);
					
				}
				mc.lineTo( pos.x+pos.w,	pos.y-pos.h	);
				mc.lineTo( pos.x,	pos.y-pos.h	);
				mc.lineTo( pos.x,	pos.y		);
				mc.endFill();
				
				// TRIANGLE
				mc.lineStyle(1,this.modCol(data.color,-40));
				mc.beginFill(data.color);			
				if(this.flTriangle){
					mc.moveTo( pos.x+pos.w,					pos.y				);
					mc.lineTo( pos.x+pos.w,					(pos.y+this.tSpace)-this.tSide	);
					mc.lineTo( (pos.x+pos.w+this.tSpace)-this.tSide,	pos.y				);
					mc.lineTo( pos.x+pos.w,					pos.y				);
					mc.endFill();
				}
				// NUMBER
				if(this.flNumber and h>20){
					var p = { x:pos.x, y:pos.y-pos.h, w:pos.w, h:20 }
					this.createField( mc, data.num, p, 1, "center" )
				}
			}
		}		
	}

	
//{	
}












