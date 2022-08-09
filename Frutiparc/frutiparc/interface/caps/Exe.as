class caps.Exe extends Capsule{//}

	function Exe(){
		this.init()
	}
	
	function init(){
		//_root.test+="initExe\n"
		this.style = this.tree.treeStyle[0]
		super.init();
	}
	
	function initBullet(){
		super.initBullet()
		if(this.box.bulletFrame!=undefined){
			this.bullet.gotoAndStop(this.box.bulletFrame);
		}else{
			this.bullet.gotoAndStop(1)
		}	
	}
	
	function initBut(){
		super.initBut();
		this.but.setButtonMethod("onPress",this.box.action.obj,this.box.action.method,this.box.action.args);	
	}
	
	function execute(){
	
	}
//{	
}

