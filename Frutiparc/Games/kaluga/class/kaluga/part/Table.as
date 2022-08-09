class kaluga.part.Table extends kaluga.Part{//}

	// CONSTANTES
	var slotWidth:Number = 72//82;
	var cutWidth:Number = 51//61;
	var slotHeight:Number = 36//50;
	var cutHeight:Number = 15//20;
	
	var slotSpace:Number = 6;
	
	// PARAMETRES
	var stats:Array;
	
	//VARAIBLES
	var depthRun:Number;
	
	
	function Table(){
		this.init();
	}

	function init(){
		//_root.test+="[part.Table] init() stats("+this.stats+")\n"
		super.init();
		this.depthRun = 0;
		this.display();
	}
	
	function display(){
		
		this.clear();
		var max = this.stats.length;
		var margin = (this.box.w-(max*(this.slotWidth+this.slotSpace)))/2
		
		
		
		for(var i=0; i<max; i++){
			
			var player = this.stats[i];

			// X
			var x = margin+i*(this.slotWidth+this.slotSpace);
			if(i==max-1)x+=this.slotSpace;
			
			// ICONES
			var d = this.depthRun++
			this.attachMovie( "partTableTzIcon", "icon"+i, d )
			var mc = this["icon"+i]

			mc._x = x
			mc.gotoAndStop(player.id+1)
			
			// RESULTS
			var list = player.results;
			for( var e=0; e<list.length; e++ ){
				var slotInfo = list[e];
				var y = 24 +e*this.slotHeight;
				this.drawSlot(x,y,slotInfo);
			};
			
			// SUM
			var y = 24+list.length*this.slotHeight+8
			this.drawSum(x,y,list);
			
			
		};
	}
	
	function drawSlot(x,y,slotInfo){
		//_root.test += "drawSlot()\n";
		
		var h = this.slotHeight/2
		
		this.lineStyle(1,0xBAD595);
		this.moveTo( x, y );
		// CADRE
		this.lineTo( x+this.slotWidth,		y 			);
		this.lineTo( x+this.slotWidth,		y+this.slotHeight 	);
		this.lineTo( x,				y+this.slotHeight	);
		this.lineTo( x,				y			);
		
		// CROSS
		this.moveTo( x+this.cutWidth,		y			);
		this.lineTo( x+this.cutWidth,		y+this.cutHeight	);
		this.moveTo( x,				y+this.cutHeight	);
		this.lineTo( x+this.slotWidth,		y+this.cutHeight	);		
		
		
		var pos,tf,dy;
		
		tf = {
			font:"President",
			size:12,
			color:0xBAD595		
		}
		dy = 0
		pos = {
			x:x,
			y:y+dy,
			w:this.cutWidth,
			h:this.cutHeight
		}
		this.createField( slotInfo.base,pos,"center",tf )
		//
		tf = {
			font:"Verdana",
			size:10,
			bold:true,
			color:0xBAD595		
		}
		dy = -1		
		pos = {
			x:x+this.cutWidth,
			y:y+dy,
			w:this.slotWidth-this.cutWidth,
			h:this.cutHeight
		}
		this.createField( slotInfo.coef,pos,"center",tf )
		//
		tf = {
			font:"President",
			size:18,
			embedFonts:false,
			//bold:true,
			color:0x637C32	
		}
		dy = -1
		//	
		pos = {
			x:x,
			y:y+this.cutHeight+dy,
			w:this.slotWidth,
			h:this.slotHeight-this.cutHeight
		}
		this.createField( slotInfo.score,pos,"center",tf )	
	}
	
	function drawSum(x,y,list){
		
		// CADRE
		this.moveTo( x,				y					)
		this.lineTo( x+this.slotWidth,		y 					);
		this.lineTo( x+this.slotWidth,		y+this.slotHeight-this.cutHeight 	);
		this.lineTo( x,				y+this.slotHeight-this.cutHeight 	);
		this.lineTo( x,				y					);	
		
		var sum = 0
		for( var i=0; i<list.length; i++ ){
			sum += list[i].score;
		}
		
		//
		var pos,tf,dy;
		tf = {
			font:"President",
			size:18,
			embedFonts:false,
			color:0x637C32	
		}
		dy = -1
		//	
		pos = {
			x:x,
			y:y+dy,
			w:this.slotWidth,
			h:this.slotHeight-this.cutHeight
		}
		this.createField( sum,pos,"center",tf )		
	}
	
	function createField(text,pos,align,textFormat){
		var mc = this;
		var depth = this.depthRun++;
		return super.createField(mc,text,pos,depth,align,textFormat);
	}
	
	
	
//{	
	
}











