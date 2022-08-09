class kaluga.Panel extends MovieClip{//}
	
	// CONSTANTES
	var mcw:Number = 464;
	var mch:Number = 344;
	var margin:Object;
	
	//var label:String;
	//var flBut:Boolean;
	var list:Array;
	var depth:Number;
	var pageNum:Number;
	var updateList:Array;

	
	// REFERENCES
	var game:kaluga.Game
	
	// MOVIECLIP
	var nextBut:Button;
	var illus:MovieClip;
	var mcPage:MovieClip;
	var fieldTitle:TextField;
	var fieldText:TextField;
	
	
	function Panel(){
		this.init();
	}
	
	function init(){
		//_root.test+="[panel] init();\n"
		this.margin = {
			x:{ min:20, ratio:0.5 },
			y:{ min:30, ratio:1 }
		}
		//var flBut = false;
		this.depth = 0;
		this.pageNum = 0;
		
		//BUT
		this.attachMovie("transp","nextBut",4)
		this.nextBut.onPress = function(){
			this._parent.nextPage();
		}		
		this.nextBut._xscale = this.mcw;
		this.nextBut._yscale = this.mch;		
		//
		this.setPage()
	}
	
	function setPage(){
		
		var page = this.list[this.pageNum]
		//_root.test+="setPage()\n"
		/*
		for(var elem in page ){
			_root.test+="-"+elem+" : "+page[elem]+"\n"
		}
		*/
		if( page == "menu" ){
			this.game.mng.backToMenu();
			return;
		}else if( page == "kill" ){
			this.game.mng.client.closeService()
		}
		
		this._parent.gotoAndStop(1)
		//
		this.updateList = new Array();
		this.createEmptyMovieClip("mcPage",10)
		//
		
		//_root.test+="label("+page.label+")\n"
		if(page.label==undefined){
			this.gotoAndStop("empty");
		}else{
			this.gotoAndStop(page.label);
		}
		var y=this.margin.y.min*this.margin.y.ratio
		for(var i=0; i<page.list.length; i++){
			var part = page.list[i]
			y += this.setPart(part,y);
		}
		/*
		if(this.pageNum<this.list.length-1){
			if(!this.flBut && page.wait == undefined ){
				

			}
		}else{
			if(!this.flBut){
				this.nextBut._visible = false // == sale
			}
		}
		*/
		
		this.nextBut._visible = (page.wait == undefined) && (this.pageNum<this.list.length-1)
		
		
				
	}
	
	function setPart(part,y){
		switch(part.type){
			case "bigScore":
				var d = this.depth++
				this.mcPage.attachMovie( "partBigScore", "part"+d, d, part )
				var mc = this.mcPage["part"+d]
				mc._y = y
				return 42;
			case "littleScore":
				var d = this.depth++
				this.mcPage.attachMovie( "partLittleScore", "part"+d, d, part )
				var mc = this.mcPage["part"+d]
				mc.fieldTitle.text = part.title;
				mc.fieldScore.text = part.score;
				mc._y = y
				return 22;			
			case "title":
				var d = this.depth++
				this.mcPage.attachMovie( "partTitle", "part"+d, d, part )
				var mc = this.mcPage["part"+d]
				mc.field.text = part.title;
				mc._y = y
				return 42;
			case "stats":
				var d = this.depth++
				this.mcPage.attachMovie( "partStats", "part"+d, d, part )
				var mc = this.mcPage["part"+d]
				mc._y = y
				this.updateList.push(mc)
				return part.box.h+12;	
			case "graph":
				_root.test = "[PANEL] attach Graph\n"
				var d = this.depth++
				this.mcPage.attachMovie( part.gfx, "part"+d, d, part )
				var mc = this.mcPage["part"+d]
				_root.test += " -mc : "+mc+"\n"
				mc._y = y
				return part.box.h+12;
			case "msg":
				this.fieldTitle.text = part.title;
				this.fieldText.text = part.msg;
				return this.fieldText.textHeight + 40;
			case "congrat":
				this._parent.gotoAndStop(2)
				this.fieldText.text = part.text
				this.fieldText._y = 60 + (80-this.fieldText.textHeight)/2
				this.illus.gotoAndStop(part.id+1)
				return 100;
			case "ladder":
				//_root.test+="ladder!\n"
				this._parent.gotoAndStop(3)
				this.fieldText.text = part.text
				this.fieldText._y = 60 + (80-this.fieldText.textHeight)/2
				
				//this.illus.gotoAndStop(8)
				this.illus.p0.gotoAndStop(part.list[0].id+1)
				this.illus.p1.gotoAndStop(part.list[1].id+1)
				this.illus.p2.gotoAndStop(part.list[2].id+1)
				
				return 100;				
			case "but":
				var d = this.depth++
				this.mcPage.attachMovie( "partBut", "part"+d, d, part )
				var mc = this.mcPage["part"+d]
 				mc._y = y
				return 28;
			case "table":
				var d = this.depth++
				this.mcPage.attachMovie( "partTable", "part"+d, d, part )
				//_root.test="mc("+mc+")\n"
				var mc = this.mcPage["part"+d]
 				mc._y = y
				return part.box.h+12;
			case "margin":
				return part.value;
			
		}
	}
	
	function nextPage(){
		//_root.test+="nextPage\n"
		this.pageNum++
		this.setPage();
	}
	
	function update(){
		//_root.test="[Page]update() \n"
		for( var i=0; i<this.updateList.length; i++ ){
			this.updateList[i].update();
		}
		var page = this.list[this.pageNum]
		if(page.wait!=undefined){
			//_root.test+=" flag ("+page.wait.o[page.wait.v]+") \n"
			if(!page.wait.o[page.wait.v])this.nextPage();
			
		}
		
		
	}
	
	
	
	
//{	
}






