class fc.menu.Slot extends MovieClip{//}

	// CONSTANTES
	var line:Number 	= 2
	var titleHeight:Number 	= 32
	
	// PARAMETRES
	var flActive:Boolean;
	var players:Number;
	var games:Number;
	var id:Number;
	var name:String;
	var width:Number;
	var height:Number;
	// REFERENCES
	var root:FrutiConnect;
	
	// MOVIECLIPS;
	var but:MovieClip;
	var fieldName:TextField;
	var fieldPlayers:TextField;
	var fieldPlayersNb:TextField;
	var fieldGames:TextField;
	var fieldGamesNb:TextField;

	
	function Slot(){
		this.init()
	}
	
	function init(){
		this.display();
	}
	
	function display(){
		this.clear();
		var col;
		if(this.flActive){
			col = [
				this.root.colorSet[1].main,
				this.root.colorSet[0].main,
				this.root.colorSet[2].main
			];
		}else{
			col = [
				0xDDDDDD,
				0xDDDDDD,
				0xDDDDDD
			];		
		}
		
		
		// DRAW
		
		var pos = { x:0, y:0, w:this.width, h:this.titleHeight }
		FEMC.drawSquare(this,pos,col[0]);
		//_root.test+="this.root.colorSet[1]("+this.root+")\n"
		//FEMC.drawSquare(this,{ x:0, y:0, w:220, h:100 },0xFF0000);
		var w = (this.width-this.line)/2
		var h = this.height-(this.titleHeight+this.line)
		var pos = { x:0, y:this.titleHeight+this.line, w:w, h:h }
		FEMC.drawSquare(this,pos,col[1]);
		var pos = { x:w+this.line, y:this.titleHeight+this.line, w:w, h:h }
		FEMC.drawSquare(this,pos,col[2]);
		
				
		// FIELDS
			// BASES
			var ti = new TextInfo();
			ti.textFormat.color = 0xFFFFFF;
			ti.textFormat.font ="Alien Encounters Solid"
			ti.fieldProperty.selectable =false;
			ti.fieldProperty.embedFonts = true;
			var h2 = (this.height-(this.titleHeight))
			
			// TITLE
			ti.textFormat.align ="center"
			ti.textFormat.size = 24;
			ti.pos = { x:0, y:0, w:this.width, h:this.titleHeight };
			ti.attachField(this,"fieldName",8);
			this.fieldName.text = this.name;
			this.fieldName._y = (this.titleHeight- this.fieldName.textHeight)/2
			
			// JOUEURS
			var by = 1
			ti.textFormat.align ="left"
			ti.textFormat.size = 14;
			ti.pos = { x:0, y:this.titleHeight+this.line+by, w:w, h:h2 };
			ti.attachField(this,"fieldPlayers",9);
			this.fieldPlayers.text = "Joueurs";
			
			ti.textFormat.align ="right"
			ti.attachField(this,"fieldPlayersNb",10);
			this.fieldPlayersNb.text = String(this.players);
			
			// GAMES
			ti.textFormat.align ="left"
			ti.pos.x = w+this.line
			ti.attachField(this,"fieldGames",11);
			this.fieldGames.text = "Parties";

			ti.textFormat.align ="right"
			ti.attachField(this,"fieldGamesNb",12);
			this.fieldGamesNb.text = String(this.games);
	
		
		//
		this.attachMovie("transp","but",13)
		this.but.onPress = function (){
			_parent._parent.joinRoom(_parent.id)
		}
		this.but._xscale =	this.width;
		this.but._yscale =	this.height;		

		
	}
	
	
//{	
}