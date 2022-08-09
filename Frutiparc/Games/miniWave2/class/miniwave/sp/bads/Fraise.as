class miniwave.sp.bads.Fraise extends miniwave.sp.Bads {//}

	function Fraise(){
		this.init();
	}
	
	function init(){
		this.type = 0;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.endUpdate();
	}
	
	
	
//{
}