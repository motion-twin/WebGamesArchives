/*------------------------------------------

				LECTEUR

------------------------------------------*/

// col.setColor(_global.generalPalette[_parent._parent._parent._parent.faceColor])
// FEMC.setColor(col,_global.generalPalette[_parent._parent._parent._parent.faceColor])

//test="000"
#include "../code62.as"


function initCode(){
	carMax = 6+5
	emoteEyeMax = 5
	emoteMouthMax = 6
	//famId= 0;

	// COOKIES
	so = SharedObject.getLocal("frutibouille");
	car = so.data.car
	if( car == undefined ){
		car=new Array()
		for(var i=0; i<=carMax; i++){
			car[i]=0;
		}
		so.data.car = car
	}
	
	// CARACTERES
	
	//car[0]=0;
	for(var i=1; i<=carMax; i++){
		//car[i]=0;
		
		attachMovie("permuteur","permuteur"+i, 100+i)
		var mc = this["permuteur"+i]
		mc._x = 82+50*i;
		mc._y = 55;
		mc.id=i;
	}

	// ACTIONS
	//actionList=["stop","parler","rire","mdr","langue","rougir","regard","sifflote","gum"]

	loadFamily("famille0")
	

	/*
	if( so.data.str == undefined ) so.data.str = "0000000000000000000000";
	applyString(so.data.str)
	*/
	
};

function displayAction(){
	//var actionList = frutibouille.actionList;
	for(var i=0; i<frutibouille.actionList.length; i++){
		attachMovie("action","action"+i, 200+i)
		var mc = this["action"+i]
		mc._x = 5 + (i%5)*100;
		mc._y = 152 + Math.floor(i/5)*30
		mc.id=i;
		mc.nom=frutibouille.actionList[i].name
	}
	
}

function loadFamily(nom){
	
	if(Key.isDown(Key.SPACE)){
		for(var i=0; i<=carMax; i++){
			car[i] = 0
		}
	}
	
	familyInput.text = nom;
	this.createEmptyMovieClip("frutibouille",1)
	frutibouille._x = 5;
	frutibouille._y = 5;
	var mcl = new MovieClipLoader()
	var listener = new Object();
	litener.obj = this;
	listener.onLoadInit = function(mc) {
		this.flLoadInit=true;
		if(this.flLoadComplete){
			initBouille();
			displayAction();
		}
	}
	listener.onLoadComplete = function(mc){
		this.flLoadComplete=true;
		if(this.flLoadInit)initBouille();
	}
	listener.onLoadStart = function(mc){
		//_root.test+="coucou\n"
	}
	mcl.addListener	(listener)
	//mcl.loadClip("../"+nom+"/"+nom+".swf",frutibouille, frutibouille);	
	mcl.loadClip("s:/fbouille/"+nom+".swf",frutibouille, frutibouille);	
}

function initBouille(){
	//_root.test+="initBouille\n"
	frutibouille.gotoAndStop("end")
	applyString()
	frutibouille.updateInfo()
	for(var i=1; i<=carMax; i++){
		var mc = this["permuteur"+i]
		mc.palette = frutibouille.info[i].palette
		//_root.test +="max"+frutibouille.info[i].max
		if(mc.palette){
			//_root.test+="mc.palette("+mc.palette+")"
			mc.gotoAndStop(2);
			FEMC.setColor(mc.col,mc.palette[car[i]])
		}else{
			mc.gotoAndStop(1);
		}
		
	}
	attachMovie("fond","mask",2)
	frutibouille.setMask(mask)
	mask._x=5;
	mask._y=5;

}

function applyString(){

	s = new String();
	for(var i=0; i<=carMax; i++){
		var s2 = car[i].encode62();
		if(s2.length<2)s2="0"+s2
		s += s2;	
	}
	frutibouille.apply(s);
	frutibouille.updateInfo();
	frutibouille.action(0);
	_root.test = ">"+s
	
	
	
	
	//-------------- SPECIAL LECTEUR -----------------
	for(var i=1; i<=carMax; i++){
		var mc = this["permuteur"+i]
		if(mc.palette){
			//_root.test+="l"
			FEMC.setColor(mc.col,mc.palette[car[i]])
		}else{
			mc.txt = car[i]
		}
	}
	//------------------------------------------------

}

MovieClip.prototype.setColor = function(o){
	if(o.r){
		if(o.a==undefined)o.a=255;
		var col ={
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:o.r-255,
			gb:o.g-255,
			bb:o.b-255,
			ab:o.a-255
		}		
	}else{
		col=o;
	}

	this.customColor = new Color(this);
	this.customColor.setTransform(col);
	
};



_global.generalPalette = [
	{r:255,	g:231,	b:206	},	// SKIN
	{r:252,	g:220,	b:216	},
	{r:251,	g:200,	b:190	},
	{r:250,	g:180,	b:164	},	// SKIN DARK
	{r:230,	g:155,	b:80	},
	{r:215,	g:125,	b:60	},
	{r:200,	g:100,	b:40	},	
	{r:160,	g:100,	b:45	},	// SKIN BLACK
	{r:138,	g:87,	b:37	},
	{r:108,	g:68,	b:30	},	
	{r:75,	g:48,	b:20	},	
	{r:230,	g:215,	b:150	},	// SKIN YELLOW
	{r:220,	g:200,	b:115	},
	{r:210,	g:185,	b:80	},	
	{r:180,	g:230,	b:125	},	// FRUTIGREEN
	{r:150,	g:215,	b:55	},
	{r:130,	g:200,	b:32	},
	{r:120,	g:185,	b:25	},
	{r:110,	g:170,	b:20	},
	{r:230,	g:125,	b:125	},	// RED	
	{r:220,	g:85,	b:85	},
	{r:210,	g:55,	b:55	},
	{r:190,	g:30,	b:30	},
	{r:110,	g:160,	b:225	},	// BLUE
	{r:80,	g:130,	b:210	},
	{r:50,	g:105,	b:175	},
	{r:150,	g:100,	b:200	},	// MAUVE
	{r:121,	g:61,	b:182	},
	{r:95,	g:55,	b:150	},
	{r:250,	g:225,	b:60	},	// MEGA JAUNE
	{r:230,	g:200,	b:10	},
	{r:215,	g:183,	b:9	},
	{r:250,	g:160,	b:50	},	// ORANGE
	{r:230,	g:120,	b:10	},
	{r:200,	g:100,	b:9	},
	{r:255,	g:200,	b:217	},	// ROSE
	{r:254,	g:171,	b:197	},
	{r:253,	g:140,	b:183	},
	{r:173,	g:183,	b:197	},	// GRIS BLEU
	{r:150,	g:160,	b:180	},	
	{r:110,	g:125,	b:150	},
	{r:205,	g:200,	b:172	},	// GRIS BRONZE
	{r:185,	g:177,	b:142	},	
	{r:162,	g:152,	b:104	},
	{r:169,	g:202,	b:168	},	// GRIS VERT
	{r:143,	g:185,	b:142	},	
	{r:113,	g:167,	b:112	},
	{r:147,	g:179,	b:210	},	// GRIS AZUR
	{r:117,	g:158,	b:198	},	
	{r:96,	g:142,	b:189	},		
	{r:55,	g:190,	b:180	},	// TURQUOISE DE MERDE
	{r:50,	g:155,	b:155	},	
	{r:255,	g:245,	b:245	}	// BLANC
	
];
