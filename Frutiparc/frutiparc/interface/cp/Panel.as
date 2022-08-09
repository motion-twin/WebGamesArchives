
//-------- CP*PANEL*Class (ABSTRAIT) -----------


class cp.Panel extends Component{

	//var flBackGround:Boolean;
	//var mainStyleName:String;

	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/		
	function init(){
		if(this.flBackground==undefined) this.flBackground=true;
		if(this.mainStyleName==undefined) this.mainStyleName = "content3";
		super.init();
	}
	/*-----------------------------------------------------------------------
		Function: genNamedInput(name,value,long,min)
		Créé un nom suivit d'un champs d'input.
		Attributes:
		- name : String Nom du champs
		- value : String Valeur du champs
		- long : Number Longueur totale
		- min : Number* Longueur minimum du nom de champs.
	
	------------------------------------------------------------------------*/
	function genNamedInput(name,value,long,min){
		//this.depth++;
		var d = this.getNextHighestDepth()
		this.content.createEmptyMovieClip("slot"+d,d)
		
		var slot = this.content["slot"+d];
		var style =  this.win.style[this.mainStyleName]
		
		var ti = new TextInfo();
		ti.textFormat.color= style.color.text
		ti.textFormat.bold = true;
		
		var mc = ti.attachField(slot,"nameField",1);
		mc.text = name+" : ";
		var w = Math.max(min/*70*/,mc.textWidth+5);
		mc._width = w;
		mc._height = 16;
		
		ti.textFormat.color=style.color.textDark;
		ti.textFormat.bold = false;	
		
		var mc = ti.attachField(slot,"valueField",2);
		mc.text = value;
		mc._x = w+5
		mc._width = long-(w+5)
		mc._height = 16
		
		slot.initDraw()
		var pos = {x:w,y:0,w:long-w,h:16}
		slot.drawSmoothSquare(pos,style.color.inLine,7)
		
		return slot;		
	}
}




