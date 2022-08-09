/* HACK
url = "http://www.dinocard.net/swf/avatar.swf"
face = "3;0;2;3;4"
// */



function init(){
	System.security.allowDomain("*");
	System.security.allowInsecureDomain("*");
	createEmptyMovieClip("base",0);
	
	if(flip == 2){
		base._xscale = -100;
		base._x = 60;
	}
	
	
	mcl = new MovieClipLoader();
	mcl.onLoadComplete = avatarLoaded
	mcl.onLoadInit = avatarLoaded
	mcl.loadClip(url,base)
}
function avatarLoaded(mc){
	if(mc.loadId==null)mc.loadId = 0
	mc.loadId++
	if(mc.loadId==2){
		initAvatar(mc);
	}
}

function initAvatar(){
	base.cl = face.split(";")
	base.apply();
};



init();