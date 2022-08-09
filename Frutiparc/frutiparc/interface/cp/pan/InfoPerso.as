
class cp.pan.InfoPerso extends cp.Panel{

	var list:Array;
	
	/*-----------------------------------------------------------------------
		Function: InfoPerso()
		constructeur
	------------------------------------------------------------------------*/	
	function InfoFrutiz(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		this.list = [
			{name: Lang.fv("frutizInfo.firstname"), value:"Benjamin" },
			{name: Lang.fv("frutizInfo.lastname") , value:"Soulé"    },
			{name: Lang.fv("frutizInfo.age")      , value:"25"       },
			{name: Lang.fv("frutizInfo.gender")   , value:"Masculin" },
			{name: Lang.fv("frutizInfo.town")     , value:"Bordeaux" }
		];		
		super.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: genContent()
	------------------------------------------------------------------------*/	
	function genContent(){
		var bonus;
		for(var i=0;i<this.list.length;i++){
			var o = this.list[i];
			var mc = this.genNamedInput(o.name,o.value,this.width-10)
			mc._x = 5;
			mc._y = 10+bonus+22*i;
			if(i==1)bonus+=8;
		}	
	}
	
}

