class Frog extends Slot{//}

	static var CENTER = 75
	
	var fi:FaerieInfo;
	
	var sList:Array<{>MovieClip,but:Button,bar:MovieClip,symbole:MovieClip,id:int}>
	
	var fieldSpell:TextField;
	var fieldFrog:TextField;
	
	
	function new(){
		dpCursorFront = 6
		dpCursorBack = 4
		super();
	}
	
	function init(){
		super.init();
		fi = Cm.getCurrentFaerie();
		fieldFrog.text = "Salut,\n"+fi.fs.$name+" !\nDis-moi quels sont tes sorts préférés..."
		initSpellBars();

	}

	function maskInit(){
		super.maskInit()
		initButQuit();
	}	
	
	
	function initSpellBars(){
		var x = 99
		var y = 12
		
		var n = 0
		for( var i=0; i<fi.spell.length; i++ ){
			if( fi.spell[i] < 20 )n++
		}
		
		var space = Math.min( 20, (Cs.mch-22)/n )
		
		for( var i=0; i<fi.spell.length; i++ ){
			
			var sid = fi.spell[i]
			if( sid < 20 ){
				var mc = downcast( dm.attach("mcSpellBar",5) )
				mc._x = x
				mc._y = y
				mc.id = sid
				mc.symbole.gotoAndStop(string(sid+1))
				
				if(fi.fs.$spellCoef[sid] == null )fi.fs.$spellCoef[sid] = 10;
				var c = fi.fs.$spellCoef[sid];
				mc.but._x = CENTER + ((c/10)-1)*58
				
				mc.but.onRollOver = callback( this, displaySpell, Spell.newSpell(sid).getName() )
				mc.but.onRollOut = callback( this, clearDisplaySpell )
				
				sList.push(mc)
				y+=space
				
				
				mc.bar.onPress = callback(this,clickBar,mc)
				
				
				
			}
		}
	}
	
	function displaySpell(str){
		//Manager.log(">"+str)
		fieldSpell.text = str
	}
	
	function clearDisplaySpell(){
		fieldSpell.text = ""
	}
	
	
	function clickBar(mc){
		var sp  = 5
		var x = 0

		if(mc._xmouse <mc.but._x){
			x = Math.max( 17, mc.but._x-sp )
		}else{
			x = Math.min(133, mc.but._x+sp )
		}
		mc.but._x = x;
		release(mc.id,x)
	}
	
	function release(id,x){
		
		var c = 1+( x - CENTER )/58

		fi.fs.$spellCoef[id] = int(c*10);
		
	}

	function update(){
		super.update();
		
		
	}
	
//{
}





	