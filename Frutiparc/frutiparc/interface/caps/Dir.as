class caps.Dir extends Capsule{//}
		

	function Dir(){
		this.init()
	}

	function init(){
		//_root.test+="initDir\n"
		this.style = this.tree.treeStyle[Math.min(this.getLevel(),this.tree.treeStyle.length-2)+1];
		//_root.test+="this.level: "+this.level+"\n"
		//_root.test+="size : "+this.style.ts.textFormat.size+"\n"
		super.init();
	}

	function initBullet(){
		super.initBullet()
		//_root.test+="fuckinShit ! ("+this.box.bulletFrame+")\n"
		if(this.box.bulletFrame!=undefined){
			this.bullet.gotoAndStop(this.box.bulletFrame);
		}else{
			this.bullet.gotoAndStop(Math.min(this.getLevel(),this.tree.treeStyle.length-2)+2);
		}	
		
	}

	function initBut(){
		super.initBut();
		this.but.setButtonMethod("onPress",this.tree,"toggleDir",this);
	}
//{
}

