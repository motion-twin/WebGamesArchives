/*-----------------------------------------

			FRUTIBOUILLE

-----------------------------------------*/


//#include "../code62.as"



// FONCTIONS STANDARDS
function apply( s ){

	//_root.test = s

	eyeId       = s.substring(2, 4 ).decode62();
	eyeSc       = s.substring(4, 6 ).decode62();
	hairId      = s.substring(6, 8 ).decode62();
	hairSc      = s.substring(8, 10).decode62();
	mouthId     = s.substring(10,12).decode62();
	faceColor   = s.substring(12,14).decode62();
	secondColor = s.substring(14,16).decode62();
	thirdColor  = s.substring(16,18).decode62();

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
		//b.b.color.gotoAndStop(faceColor+1)
	}

	face.pa.col.setColor( 		_global.generalPalette[faceColor]	)
	face.pb.col.setColor( 		_global.generalPalette[faceColor]	)
	face.b.b.col.col.setColor( 	_global.generalPalette[faceColor]	)
	face.ca.c.col.setColor( 	_global.generalPalette[secondColor]	)
	face.ca.c.col2.setColor( 	_global.generalPalette[thirdColor]	)
	face.ca.c.col3.setColor( 	_global.generalPalette[faceColor]	)
	face.cb.c.col.setColor( 	_global.generalPalette[secondColor]	)
	face.cb.c.col2.setColor( 	_global.generalPalette[thirdColor]	)
	face.cb.c.col3.setColor( 	_global.generalPalette[faceColor]	)



	emote();

}
function emote(){
	face.b.b.gotoAndStop(emoteMouth+1);
	face.oa.o.gotoAndStop(emoteEye+1);
	face.ob.o.gotoAndStop(emoteEye+1);
}
function applyEmote( id ){
	emoteEye = emoteList[id][0];
	emoteMouth = emoteList[id][1];
	emote();
}
function updateInfo(){

	info=[		{type:"family",		max:255,				palette:0			},
			{type:"element",	max:face.oa._totalframes,		palette:0			},
			{type:"element",	max:face.oa.o.p._totalframes,		palette:0			},
			{type:"element",	max:face.ca._totalframes,		palette:0			},
			{type:"element2",	max:face.ca.c._totalframes,		palette:0			},
			{type:"element",	max:face.b._totalframes,		palette:0			},
			{type:"color",		max:_global.generalPalette.length,	palette:_global.generalPalette	},
			{type:"color",		max:_global.generalPalette.length,	palette:_global.generalPalette	},
			{type:"color",		max:_global.generalPalette.length,	palette:_global.generalPalette	}
	];
	/*
	info={
		{
			name:"crane",
			id:null,
			sup:[
				{name:"couleur de peau"
				id:
				}
			]
		},
		{
			name:"bouche"

		},
		{
			name:"yeux"

		},
		{
			name:"cheuveux"

		},
	}
	*/

}
function action(id){

	//_root.test="action "+id;
	if(id==0){
		face.gotoAndStop(1);
		face.oa.o.gotoAndStop(emoteEye+1)
		face.ob.o.gotoAndStop(emoteEye+1)
		face.b.b.gotoAndStop(emoteMouth+1)
	}else if(id==1){
		face.gotoAndPlay("parle");
		face.oa.o.gotoAndStop(emoteEye+1)
		face.ob.o.gotoAndStop(emoteEye+1)
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
		face.gotoAndPlay("jutsu");
		face.oa.o.gotoAndPlay("regardG");
		face.ob.o.gotoAndPlay("regardG");
		face.b.b.gotoAndStop(emoteMouth+1);
		face.oa.o.compt=30;
		face.ob.o.compt=face.oa.o.compt;
	}else if(id==7){
		face.gotoAndPlay("sifflote");
		face.oa.o.gotoAndPlay("regardH");
		face.ob.o.gotoAndPlay("regardH");
		face.b.b.gotoAndPlay("siffle");
		face.compt=5;
		face.b.b.compt=7
		face.oa.o.compt=55
		face.ob.o.compt=face.oa.o.compt;
	}else if(id==8){
		face.gotoAndPlay("gum");
		face.oa.o.gotoAndStop(emoteEye+1);
		face.ob.o.gotoAndStop(emoteEye+1);
		face.b.b.gotoAndStop("souffle");
	}else if(id==9){
	}

}

// VARIABLE STANDARD
emoteList = [
	[0,0],
	[1,2],
	[2,1],
	[0,3],
	[3,4],
	[1,4],
	[2,3]
];

actionList = [
	{name:"stop",	iconId:1},
	{name:"parle",	iconId:2},
	{name:"rire",	iconId:3},
	{name:"mdr",	iconId:4},
	{name:"langue",	iconId:5},
	{name:"rougir",	iconId:6},
	{name:"regard",	iconId:7},
	{name:"siffle",	iconId:8},
	{name:"gum",	iconId:9}
];


