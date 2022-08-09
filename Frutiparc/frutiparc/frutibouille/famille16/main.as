groumph = 0

function applyColor(mc) {
	FEMC.setColor(mc,_global.generalPalette[faceColor]);
}

function apply( s ){
	//_global.debug("frutibouille -> apply("+s+")")
	//s=""
	//_root.test += "FB> apply string:"+s+" face("+face+") face.ca("+face.ca+")\n"

	eyeId		= s.substring(2, 4 ).decode62();
	eyeSc		= s.substring(4, 6 ).decode62();
	hairId		= s.substring(6, 8 ).decode62();
	mouthId		= s.substring(8, 10).decode62();
	faceColor	= s.substring(10,12).decode62();
	secondColor	= s.substring(12,14).decode62();

	accId		= s.substring(14,16).decode62();
	accSecId	= s.substring(16,18).decode62();
	accColor1	= s.substring(18,20).decode62();
	accColor2	= s.substring(20,22).decode62();
	accColor3	= s.substring(22,24).decode62();

	//thirdColor	= s.substring(14,16).decode62();


	with(face){

		ca.gotoAndStop(hairId+1);
		cb.gotoAndStop(hairId+1);
		ca.c.gotoAndStop(accId+1);
		cb.c.gotoAndStop(accId+1);
		ca.c.acc.gotoAndStop(accSecId+1);
		ca.c.acc2.gotoAndStop(accSecId+1);
		cb.c.acc.gotoAndStop(accSecId+1);
		//
		oa.gotoAndStop(eyeId+1);
		ob.gotoAndStop(eyeId+1);
		oa.o.p.gotoAndStop(eyeSc+1);
		ob.o.p.gotoAndStop(eyeSc+1);
		//
		b.gotoAndStop(mouthId+1);
		b.b.stop();
		//_root.test+="b._currentframe("+b._currentframe+")\n"
		//_root.test+="b.b._currentframe("+b.b._currentframe+")\n"
	}

	// Visage
	FEMC.setColor(	face.pa.col,		_global.generalPalette[faceColor]	)
	FEMC.setColor(	face.pb.col,		_global.generalPalette[faceColor]	)
	FEMC.setColor(	face.b.b.col.col,	_global.generalPalette[faceColor]	)

	// Cheveux
	FEMC.setColor(	face.ca.c.col,		_global.generalPalette[secondColor]	)
	FEMC.setColor(	face.ca.c.col3,		_global.generalPalette[faceColor]	)
	FEMC.setColor(	face.cb.c.col,		_global.generalPalette[secondColor]	)
	FEMC.setColor(	face.cb.c.col3,		_global.generalPalette[faceColor]	)

	// Accessoire
	if(face.ca.c.acc._visible){
		FEMC.setColor(	face.ca.c.acc.col,	_global.generalPalette[accColor1]	)
		FEMC.setColor(	face.ca.c.acc.col2,	_global.generalPalette[accColor2]	)
		FEMC.setColor(	face.ca.c.acc.col3,	_global.generalPalette[accColor3]	)
		FEMC.setColor(	face.cb.c.acc.col,	_global.generalPalette[accColor1]	)
		FEMC.setColor(	face.cb.c.acc.col2,	_global.generalPalette[accColor2]	)
		FEMC.setColor(	face.cb.c.acc.col3,	_global.generalPalette[accColor3]	)
	}
	if(face.ca.c.acc2._visible){
		FEMC.setColor(	face.ca.c.acc2.col,	_global.generalPalette[accColor1]	)
		FEMC.setColor(	face.ca.c.acc2.col2,	_global.generalPalette[accColor2]	)
		FEMC.setColor(	face.ca.c.acc2.col3,	_global.generalPalette[accColor3]	)
		FEMC.setColor(	face.cb.c.acc2.col,	_global.generalPalette[accColor1]	)
		FEMC.setColor(	face.cb.c.acc2.col2,	_global.generalPalette[accColor2]	)
		FEMC.setColor(	face.cb.c.acc2.col3,	_global.generalPalette[accColor3]	)
	}
	emote();
	//updateInfo();
}

function emote(){
	//_root.test+="("+emoteMouth+","+emoteEye+")"
	face.b.b.gotoAndStop(emoteMouth+1);
	face.oa.o.gotoAndStop(emoteEye+1);
	face.ob.o.gotoAndStop(emoteEye+1);
}

function updateInfo(){
	//_root.test = "updateInfo:("+(groumph++)+")\n"
	info=[		{name:"famille",	type:"family",		max:255,				palette:0						},
			{name:"yeux",		type:"element",		max:face.oa._totalframes-1,		palette:0						},
			{name:"iris",		type:"element",		max:face.oa.o.p._totalframes-1,		palette:0						},
			{name:"cheveux",	type:"element",		max:face.ca._totalframes-1,		palette:0		},//	control:4		},
			{name:"bouche",		type:"element",		max:face.b._totalframes-1,		palette:0						},
			{name:"couleur1",	type:"color",		max:_global.generalPalette.length-1,	palette:_global.generalPalette				},
			{name:"couleur2",	type:"color",		max:_global.generalPalette.length-1,	palette:_global.generalPalette				},
			{name:"accessoire",	type:"element",		max:face.ca.c._totalframes-1,		palette:0,		control:8			},
			{name:"accessoire2",	type:"element",		max:face.ca.c.acc._totalframes-1,	palette:0						},
			{name:"acc couleur1",	type:"color",		max:_global.generalPalette.length-1,	palette:_global.generalPalette				},
			{name:"acc couleur2",	type:"color",		max:_global.generalPalette.length-1,	palette:_global.generalPalette				},
			{name:"acc couleur3",	type:"color",		max:_global.generalPalette.length-1,	palette:_global.generalPalette				}

	];
	//_root.test+="face.ca.c._totalframes("+face.ca.c._totalframes+")\n"
}

function playAnim(id){
	if(id==undefined)id=1;
	//_root.test += "-"+id;
	if(id==0){
		endAnim();
		flStop = true;
		face.gotoAndStop(1);
		face.oa.o.gotoAndStop(emoteEye+1)
		face.ob.o.gotoAndStop(emoteEye+1)
		//_root.test+="("+face.b.b._currentframe+","
		face.b.b.flMute=true;
		face.b.b.gotoAndStop(emoteMouth+1)
		//_root.test+=face.b.b._currentframe+") emoteMouth("+emoteMouth+")\n"
	}else if(id==1){
		flStop = false;
		face.gotoAndPlay("parle");
		face.oa.o.gotoAndStop(emoteEye+1)
		face.ob.o.gotoAndStop(emoteEye+1)
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("parle"+random(4))

	}else if(id==2){				// RIRE
		flStop = false;
		next = 0;
		face.compt = 4;
		face.gotoAndPlay("rire");
		face.oa.o.gotoAndStop(4)
		face.ob.o.gotoAndStop(4)
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("rire0")

	}else if(id==3){				// MDR
		flStop = false;
		next = 0;
		face.compt = 4;
		face.gotoAndPlay("mdr");
		face.oa.o.gotoAndStop(4)
		face.ob.o.gotoAndStop(4)
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("mdr0")

	}else if(id==4){				// LANGUE
		flStop = false;
		next = 0;
		face.gotoAndPlay("langue");
		face.oa.o.gotoAndStop(2)
		face.ob.o.gotoAndStop(2)
		face.b.b.gotoAndPlay("langue")
		face.b.b.flMute=true;
		face.b.b.compt=10
	}else if(id==5){				// ROUGIR
		flStop = false;
		next = 0;
		face.gotoAndPlay("rougir")
		face.oa.o.gotoAndStop(3)
		face.ob.o.gotoAndStop(3)
		face.b.b.flMute=true;
		face.b.b.gotoAndStop(1)
		face.compt=40
	}else if(id==6){				// REGARD
		flStop = false;
		next = 0;
		var compt = 30
		face.gotoAndPlay("regard");
		face.compt = compt
		face.oa.o.gotoAndPlay("regardG");
		face.ob.o.gotoAndPlay("regardD");
		face.b.b.flMute=true;
		face.b.b.gotoAndStop(emoteMouth+1);
		face.oa.o.compt=compt;
		face.ob.o.compt=compt;
	}else if(id==7){				// SIFFLOTE
		flStop = false;
		next = 0;
		face.gotoAndPlay("sifflote");
		face.oa.o.gotoAndPlay("regardH");
		face.ob.o.gotoAndPlay("regardH");
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("siffle");
		face.compt=5;
		face.b.b.compt=7
		face.oa.o.compt=55
		face.ob.o.compt=face.oa.o.compt;
	}else if(id==8){				// GUM
		flStop = false;
		next = 0;
		face.gotoAndPlay("gum");
		face.oa.o.gotoAndStop(emoteEye+1);
		face.ob.o.gotoAndStop(emoteEye+1);
		face.b.b.flMute=true;
		face.b.b.gotoAndStop("souffle");
	}else if(id==9){				// QUESTION
		flStop = false;
		next = 0;
		face.gotoAndStop("question");
		face.oa.o.gotoAndPlay("regardH");
		face.ob.o.gotoAndPlay("regardH");
		face.compt=3
		face.b.b.flMute=true;
		face.b.b.gotoAndStop(2);
		//face.b.b.gotoAndStop(emoteMouth+1);
		face.oa.o.compt=80
		face.ob.o.compt=face.oa.o.compt;
	}else if(id==10){				//MIAM
		flStop = false;
		next = 0;
		face.compt = 60
		face.gotoAndPlay("miam");
		face.oa.o.gotoAndStop(3);
		face.ob.o.gotoAndStop(3);
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("bave");
	}else if(id==11){				//PLEURE
		flStop = false;
		next = 0;
		face.compt = 4;
		face.gotoAndPlay("pleurer");
		face.oa.o.gotoAndStop("ferme")
		face.ob.o.gotoAndStop("ferme")
		face.b.b.flMute=true;
		face.b.b.gotoAndPlay("rire0");
	}else if(id==12){				//LARME
		flStop = false;
		next = 0;
		face.gotoAndStop("larme");
		face.oa.o.gotoAndStop("triste")
		face.ob.o.gotoAndStop("triste")
		face.b.b.flMute=true;
		face.b.b.gotoAndStop(2);
	};

}







