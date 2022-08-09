class miniwave.sp.bads.Prune extends miniwave.sp.Bads {//}

	var limit:Number = 60;
	
	function Prune(){
		this.init();
	}
	
	function init(){
		this.type = 9;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.endUpdate();
	}
	
	function hitSide(){
		//_root.test+="this.game.mch("+this.game+")\n"
		super.hitSide();
		var  y = this.game.mng.mch-this.limit
		while( y>this.y ){
			if(this.game.isFree( this.x, y )){
				this.ty = y;
				break;
			}
			y -= 24;
		}		

	}
	
//{
}