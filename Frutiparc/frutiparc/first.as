/*----------------------------------------------

			FRUTIPARC FIRST

----------------------------------------------*/

if(this != _root){
	logText = "";
	
	baseMcw = 1024;
	baseMch = 768;

	flLoading=true;

	StageResize = new Object()
	StageResize.onResize = function(){

		_global.mcw = Stage.width;
		_global.mch = Stage.height;
		_root._x = (baseMcw-mcw)/2;
		_root._y = (baseMch-mch)/2;
		main.onResize();
		if(flLoading){
			updateLoadingSize();
		};
	}
	Stage.addListener(StageResize);
	StageResize.onResize();

	
	//icon.loadMovie("../frutiparc/icons/iconGFX.swf");
}