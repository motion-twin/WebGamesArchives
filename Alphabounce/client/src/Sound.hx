
typedef Snd  = {link:String,so:flash.Sound};

class Sound{//}

	static var MUTE = true;
	static var un:Array<String> = [];

	static var list:Array<Snd> = [];


	static public function init(){

	}

	static public function play(link,?vol){
		if(MUTE)return;

		var so = getSound(link);



		for( lnk in un )if(lnk == link)return;
		un.push(link);



		var so = new flash.Sound(null);
		so.attachSound(link);
		so.start(0.,1);

		if(vol!=null)so.setVolume(vol);

	}


	static public function loop(link,?vol){
		if(MUTE)return;

		var so = new flash.Sound(null);
		so.attachSound(link);
		so.start(0,999999);

		if(vol!=null)so.setVolume(vol);
	}


	static public function update(){
		un = [];
	}

	static public function getSound(link){
		for( snd in list )if(snd.link==link)return snd.so;

		//trace("attach");

		var so = new flash.Sound(null);
		so.attachSound(link);
		list.push( {link:link,so:so} );

		return so;
	}

//{
}













