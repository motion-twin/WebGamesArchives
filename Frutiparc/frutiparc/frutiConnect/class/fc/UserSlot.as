class fc.UserSlot extends MovieClip{//}
	
	// CONSTANTES
	var linkWidth:Number = 18
	
	// VARIABLES
	var flEndLine:Boolean;
	//var link:Number;
	var emptyName:String;
	var size:Object;
	//var user:Object;
	var endIconList:Array;
	var info:Object;

	// MOVIECLIPS
	var square:MovieClip;
	var field:TextField;	
	var but:MovieClip;
	
	// REFERENCES
	var panel:fc.Panel;
	

		
	function UserSlot(){
		this.init();
	};
	
	function init(){
		//_root.test+="userSlotInit\n"
		if(this.size==undefined)this.size = {w:120,h:20}
		this.initTextField();
		this.initStatus();
	};

	function initTextField(){
		var tf = new TextInfo();
		tf.textFormat.color = 0xFFFFFF;
		tf.textFormat.bold = true;
		tf.textFormat.size = 12;
		tf.fieldProperty.selectable =false;
		tf.pos = { x:this.size.h+2, y:0, w:this.size.w-this.size.h, h:this.size.h };
		tf.attachField(this,"field",10);
		// Button
		this.attachMovie("transp","but",22)
		this.but._x = this.size.h+2
		this.but._xscale = this.size.w-this.size.h			
		this.but._yscale = this.size.h
		this.but.onPress = function(){
			this._parent.clickField();
		};
	}
	
	function initStatus(){
		this.createEmptyMovieClip("square",1)
		this.square.onPress = function(){
			this._parent.requestGameInfo();
		}
	}
		
	function updateUser( info ){	//o = {type, user, link, endIconList}	user :{name, status, game, waitList}
		this.info = info
		/*
		_root.test += " info :\n"
		for(var elem in info){
			_root.test+="-"+elem+" = "+info[elem]+"\n";
		}
		_root.test += " user :\n"
		for(var elem in info.user){
			_root.test+="-"+elem+" = "+info.user[elem]+"\n";
		}
		*/
		//if( this.info.link == undefined ) this.info.link = 1;
		
		if( this.info.type == frusion.Context.JOIN_TYPE ){
			this.field.textColor = this.panel.col.lighter;
			this.setText(this.emptyName);
		}else if( this.info.type == frusion.Context.USER_TYPE ) {
			this.field.textColor = 0xFFFFFF;
			this.setText(this.info.user.name);
		}else if( this.info.type == frusion.Context.EMPTY_TYPE ) {
			
		}
		
		// ICONLISTUPDATE
		this.cleanEndIconList();
		if( this.info.endIconList.length > 0 ){
			for( var i=0; i<this.info.endIconList.length; i++ ){
				//_root.test+="createIcon\n"
				var icon = this.info.endIconList[i]
				this.attachMovie(icon.link,"icon"+i,100+i)
				var but = this["icon"+i]
				but._x = this.size.w-20*i
				but.c = icon.callback
				but.onPress = function(){
					this.c.obj[this.c.method](this.c.args);
				}
				this.endIconList.push()
			};
		}
		this.updateStatus()
		
	}
	
	function cleanEndIconList(){
		while(this.endIconList.length>0)this.endIconList.pop().removeMovieClip();
	}
	
	function updateSize(){
		this.clear();
		this.field._width = this.size.w-this.size.h;
		if(this.flEndLine){
			var n = this.panel.lineHeight;
			var pos = {x:0, y:this.size.h-n, w:this.size.w, h:n }
			FEMC.drawSquare(this,pos,0xFFFFFF)
		}
	}
	
	function setText(text){
		this.field.text = text
	}
	
	function updateStatus(){
		//_root.test+="this.info.link("+this.info.link+")\n"
		this.square.clear();
		if( this.info.type != frusion.Context.EMPTY_TYPE){
			var n = this.panel.lineHeight;
			// BLANC
			var pos = {x:0, y:0, w:this.size.h, h:this.size.h };
			FEMC.drawSquare(this.square,pos,0xFFFFFF);
			// CARRE COULEUR
			if(this.info.link>0){
				var pos = {x:0, y:0, w:this.size.h-n, h:(this.size.h*this.info.link)-n };
				FEMC.drawSquare( this.square, pos, this.panel.root.colorSet[this.info.user.status].main );
			}
		}
	}
	
	function requestGameInfo(){
		this.panel.root.manager.requestGameInfo(this.info.user.gameId);
	}
	
	function clickField(){
		if(this.info.type == frusion.Context.JOIN_TYPE){
			this.panel.root.manager.dropIn(this.info.game);
		}else if( this.info.type == frusion.Context.USER_TYPE ) {
			this.panel.root.manager.selectPlayer(this.info.user);
		}else{
		
		}
	}
	
	function kill(){
		this.removeMovieClip();
	}
	
	
//{
}