/*-----------------------------------------

			FRUTIBOUILLE

-----------------------------------------*/

/* SPEC

	1 eyeId
	2 eyeSc
	3 hairId
	4 hairSc
	5 noseId
	6 faceColor
	7 secondColor
	8 thirdColor

*/

colorList=[

	[
		{r:252,	g:220,	b:216,	a:100	},
		{r:251,	g:200,	b:190,	a:100	},
		{r:250,	g:180,	b:164,	a:100	},
		{r:230,	g:155,	b:80,	a:100	},
		{r:215,	g:125,	b:60,	a:100	},
		{r:200,	g:100,	b:40,	a:100	},
		{r:160,	g:100,	b:45,	a:100	},
		{r:138,	g:87,	b:37,	a:100	},
		{r:108,	g:68,	b:30,	a:100	},
		{r:75,	g:48,	b:20,	a:100	},
		{r:230,	g:215,	b:150,	a:100	},
		{r:220,	g:200,	b:115,	a:100	},
		{r:210,	g:185,	b:80,	a:100	},
		{r:110,	g:160,	b:225,	a:100	},
		{r:80,	g:130,	b:210,	a:100	},
		{r:230,	g:125,	b:125,	a:100	},
		{r:220,	g:70,	b:70,	a:100	},
		{r:180,	g:230,	b:125,	a:100	},
		{r:150,	g:215,	b:55,	a:100	},
		{r:150,	g:100,	b:200,	a:100	},
		{r:95,	g:55,	b:150,	a:100	},
		{r:55,	g:190,	b:180,	a:100	},
		{r:50,	g:155,	b:155,	a:100	},
		{r:250,	g:225,	b:60,	a:100	},
		{r:230,	g:200,	b:10,	a:100	},
		{r:250,	g:160,	b:50,	a:100	},
		{r:230,	g:120,	b:10,	a:100	},
		{r:150,	g:160,	b:180,	a:100	},
		{r:110,	g:125,	b:150,	a:100	},
		{r:0,	g:0,	b:0,	a:100	},
		{r:0,	g:0,	b:0,	a:100	}

	],
	[
		{r:160,	g:100,	b:45,	a:100	},
		{r:138,	g:87,	b:37,	a:100	},
		{r:108,	g:68,	b:30,	a:100	},
		{r:75,	g:48,	b:20,	a:100	},
		{r:250,	g:240,	b:175,	a:100	},
		{r:243,	g:225,	b:112,	a:100	},
		{r:236,	g:211,	b:40,	a:100	},
		{r:200,	g:175,	b:18,	a:100	},
		{r:230,	g:125,	b:125,	a:100	},
		{r:220,	g:70,	b:70,	a:100	},
		{r:250,	g:160,	b:50,	a:100	},
		{r:230,	g:120,	b:10,	a:100	},
		{r:240,	g:240,	b:240,	a:100	},
		{r:200,	g:200,	b:200,	a:100	},
		{r:160,	g:160,	b:160,	a:100	},
		{r:120,	g:120,	b:120,	a:100	},
		{r:110,	g:160,	b:225,	a:100	},
		{r:80,	g:130,	b:210,	a:100	},
		{r:47,	g:95,	b:175,	a:100	},
		{r:180,	g:230,	b:125,	a:100	},
		{r:150,	g:215,	b:55,	a:100	},
		{r:130,	g:185,	b:40,	a:100	},
		{r:255,	g:213,	b:223,	a:100	},
		{r:255,	g:185,	b:203,	a:100	},
		{r:250,	g:140,	b:180,	a:100	},
		{r:202,	g:160,	b:223,	a:100	},
		{r:185,	g:130,	b:215,	a:100	},
		{r:160,	g:92,	b:194,	a:100	},
		{r:0,	g:0,	b:0,	a:100	},
		{r:0,	g:0,	b:0,	a:100	},
		{r:0,	g:0,	b:0,	a:100	}

	],
	[
		{r:230,	g:125,	b:125,	a:100	},
		{r:220,	g:70,	b:70,	a:100	},
		{r:250,	g:160,	b:50,	a:100	},
		{r:230,	g:120,	b:10,	a:100	},
		{r:240,	g:240,	b:240,	a:100	},
		{r:200,	g:200,	b:200,	a:100	},
		{r:160,	g:160,	b:160,	a:100	},
		{r:120,	g:120,	b:120,	a:100	},
		{r:110,	g:160,	b:225,	a:100	},
		{r:80,	g:130,	b:210,	a:100	},
		{r:47,	g:95,	b:175,	a:100	},
		{r:180,	g:230,	b:125,	a:100	},
		{r:150,	g:215,	b:55,	a:100	},
		{r:130,	g:185,	b:40,	a:100	},
		{r:255,	g:213,	b:223,	a:100	},
		{r:255,	g:185,	b:203,	a:100	},
		{r:250,	g:140,	b:180,	a:100	},
		{r:202,	g:160,	b:223,	a:100	},
		{r:185,	g:130,	b:215,	a:100	},
		{r:160,	g:92,	b:194,	a:100	},
		{r:0,	g:0,	b:0,	a:100	},
		{r:0,	g:0,	b:0,	a:100	},
		{r:0,	g:0,	b:0,	a:100	}

	]
];


function apply( s ){

	//_root.test = s
	
	eyeId =			parseInt( s.substring(2,4),		16 );
	eyeSc = 		parseInt( s.substring(4,6),		16 );
	hairId = 		parseInt( s.substring(6,8),		16 );
	hairSc = 		parseInt( s.substring(8,10),	16 );
	mouthId =		parseInt( s.substring(10,12),	16 );
	faceColor =		parseInt( s.substring(12,14), 	16 );
	secondColor =	parseInt( s.substring(14,16), 	16 );
	thirdColor = 	parseInt( s.substring(16,18), 	16 );
	
	with(face){

		ca.gotoAndStop(hairId+1);
		cb.gotoAndStop(hairId+1);
		ca.c.gotoAndStop(hairSc+1);
		cb.c.gotoAndStop(hairSc+1);
		//
		oa.gotoAndStop(eyeId+1);
		ob.gotoAndStop(eyeId+1);
		oa.o.p.gotoAndStop(eyeSc+1);
		ob.o.p.gotoAndStop(eyeSc+1);
		//
		b.gotoAndStop(mouthId+1);
		b.b.color.gotoAndStop(faceColor+1)
	}

	setColor(face.pa.col, 		faceColor,		0	)
	setColor(face.pb.col,  		faceColor,		0	)
	setColor(face.b.b.col.col,  faceColor,		0	)
	setColor(face.ca.c.col, 	secondColor,	1	)
	setColor(face.ca.c.col2, 	thirdColor,		2	)
	setColor(face.cb.c.col, 	secondColor,	1	)
	setColor(face.cb.c.col2, 	thirdColor,		2	)

	emote();
	
}

function emote(){
	face.b.b.gotoAndStop(emoteMouth+1);
	face.oa.o.gotoAndStop(emoteEye+1);
	face.ob.o.gotoAndStop(emoteEye+1);
}


function genInfo(){

	carInfo=[	{max:255,						palette:0		},
				{max:face.oa._totalframes,		palette:0		},
				{max:face.oa.o.p._totalframes,	palette:0		},
				{max:face.ca._totalframes,		palette:0		},
				{max:face.ca.c._totalframes,	palette:0		},
				{max:face.b._totalframes,		palette:0		},
				{max:colorList[0].length,		palette:1		},
				{max:colorList[1].length,		palette:2		},
				{max:colorList[2].length,		palette:3		}
	];
	
}

function action(id){

	_root.test="action "+id;
	if(id==0){
		face.gotoAndStop(1);
		emote();
	}else if(id==1){
		face.gotoAndPlay("parle");
		face.b.b.gotoAndPlay("parle0")
	}else if(id==2){
		face.gotoAndPlay("rire");
		face.oa.o.gotoAndStop(4)
		face.ob.o.gotoAndStop(4)
		face.b.b.gotoAndPlay("rire0")
	}else if(id==3){
		face.gotoAndPlay("mdr");
		face.oa.o.gotoAndStop(4)
		face.ob.o.gotoAndStop(4)
		face.b.b.gotoAndPlay("mdr0")
	}else if(id==4){
		face.gotoAndPlay("langue");
		face.oa.o.gotoAndStop(2)
		face.ob.o.gotoAndStop(2)
		face.b.b.gotoAndPlay("langue")
		face.b.b.compt=10
	}else if(id==5){
		face.gotoAndPlay("rougir")
		face.oa.o.gotoAndStop(3)
		face.ob.o.gotoAndStop(3)
		face.b.b.gotoAndStop(1)
		face.compt=40
	}else if(id==6){
	}else if(id==7){
	}else if(id==8){
	}else if(id==9){
	}

}


_global.setColor = function(mc,id,palette){
	
	//_root.test+="setCol"+mc+"\n"
	if(palette==null)palette=0;
	var o ={
		ra:colorList[palette][id].a,
		ga:colorList[palette][id].a,
		ba:colorList[palette][id].a,
		aa:100,
		rb:colorList[palette][id].r-255,
		gb:colorList[palette][id].g-255,
		bb:colorList[palette][id].b-255,
		ab:0	
	}
	mc.customColor = new Color(mc)
	mc.customColor.setTransform(o)

}