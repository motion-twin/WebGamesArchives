class miniwave.Msg extends MovieClip{//}

	var type:Number;
	var timer:Number;
	var alpha:Number;
	var ta:Number;
	
	var list:Array;
	
	
	var cb:Object;
	//var step:Number;
	
	var game:miniwave.Game
	

	function Msg(){
		this.init();
	}
	
	function init(){
				
		this._alpha = 0;
		this.alpha = 0;
		this.ta = 100;
		
		this.initField();
		
		this._y = ( this.game.mng.mch - this._height )/2;
	}
	
	function initField(){
		this.gotoAndStop(this.type+1)
		for( var i=0; i<this.list.length; i++ ){
			this["field"+i].text = this.list[i]
			//_root.test+="<"+this["fied"+i]+"> <"+this.list[i]+">\n"
		}
	}
	
	function update(){
		this.alpha = this.alpha*0.8 + this.ta*0.2;
		this._alpha = this.alpha;
		
		if( this.timer != undefined ){
			if( this.timer < 0 ){
				this.ta = 0;
				delete this.timer;
			}else{
				this.timer -= Std.tmod;
			}
		}
		
		
		if( this.ta == 0 && this.alpha <1 ){
			this.cb.obj[this.cb.method](this.cb.args);
			this.removeMovieClip();
		}
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
//{
}