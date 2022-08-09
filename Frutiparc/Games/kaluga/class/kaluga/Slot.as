class kaluga.Slot extends MovieClip{//}

	// PARAMETRES
	var mng:kaluga.Manager
	function Slot(){
		//_root._alpha=20
		//this.init();
	}
	function init(){
		//if(mng==undefined)_root.test+="error\n";
	}
	function kill(){
		//_root.test+="[Slot]kill() 1!\n"
		this.mng.removeSlot(this);
		//_root.test+="[Slot]kill() 2!\n"
		this.removeMovieClip()
		//_root.test+="[Slot]kill() 3!\n"
	}
//{	
}