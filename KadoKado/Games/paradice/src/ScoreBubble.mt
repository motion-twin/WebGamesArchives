class ScoreBubble extends Part{//}

	//static var TEXTCOLOR = [0xFF0000,0x00FF00,0x0000FF]
	static var TEXTCOLOR = [0x81E842,0xBAAAF0,0xF7BA91,0x96C6F3,0xF1F081]
	
	var field:TextField;
	var bubble:TextField;
	var cx:float;
	
	var sc:float;
	var dec:float;
	var ec:float;
	var decSpeed:float;
	
	
	function new(mc){
		Cs.game.sbList.push(this)
		super(mc);
		field = downcast(root).field;
		bubble = downcast(root).bubble;
		//fadeType = 0
		cx = 1
		
		sc = 10;
		dec = Math.random()*628
		decSpeed = 81
		
		ec = 30
		
	}
	
	function update(){
		super.update()
		
		sc = Math.min(Math.pow(sc*2,Timer.tmod),100)
		dec = (dec+decSpeed*Timer.tmod)%628;
		
		decSpeed *= Math.pow(0.9,Timer.tmod)
		ec *= Math.pow(0.95,Timer.tmod)
		
		bubble._xscale = ( 100 + Math.cos(dec*0.01)*ec ) * cx
		bubble._yscale = 100 + Math.sin(dec*0.01)*ec
		
		
		
	}
	
	function setScore(sc,col){
		field.textColor = TEXTCOLOR[col] 
		field.text = string(sc)
		var w = field.textWidth+24
		cx = w/32
		bubble._width = w
	}

	function kill(){
		Cs.game.sbList.remove(this)
		super.kill();
	}
	
//{	
}