class ac.Dialog extends Action{//}

	var index:float;
	var timer:float;
	var data:DataDialog;

	var avatar:{ >MovieClip, field:TextField, img:{>MovieClip, trg:MovieClip}}
	
	function new(d){
		super(d)
		data = downcast(d);
	}
	
	function init(){
		super.init();
		var pl = Cs.game.getPlayer(data.$pid);
		if(data.$pid==null)pl = Cs.game.playerList[Std.random(2)];
		
		Cs.game.mcPlasma.fader = []
		Cs.game.fadeBg(50)
		
		index = 0
		
		var my = 80
		avatar = downcast(Cs.game.dm.attach("mcDialogBouille",Game.DP_PART))
		avatar._x = pl.avatar.x - 20
		avatar._y = my + pl.dside*(Cs.mch-2*my)
		Cs.loadAvatar(avatar.img)
		
		var cl = pl.data.$avatar.duplicate();
		if(data.$exp!=null)cl[1]=data.$exp;
		
		downcast(avatar.img).cl = cl
		//avatar.field.text = data.$text
		Cs.glow(avatar.field,3,8,0)
		
		timer = 20
	}
	
	function update(){
		super.update();

		index += 0.5;
		timer -= Timer.tmod;
		
		var str = data.$text.slice(0,int(index))
		if(index%4>2)str += "$_".substring(1)
		avatar.field.text = str
		
		if(timer<0 && Cs.game.flClick){
			if(index<data.$text.length){
				index = data.$text.length
				Cs.game.flClick = false
			}else{
				Cs.game.fadeBg(0);	
				avatar.removeMovieClip();			
				kill();
			}
		}
	}

	function kill(){
		//Log.clear()
		
		super.kill()
	}


//{
}