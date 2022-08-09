
System.security.allowDomain("*");
System.security.allowInsecureDomain("*");

// System.security.allowDomain("www.dinocard.net");
// System.security.allowDomain("data.dinocard.net");

// System.security.allowInsecureDomain("www.dinocard.net");
// System.security.allowInsecureDomain("data.dinocard.net");


pMax = 2;

/*
car="0;1;2;1;0;1;2"
//*/
//	[ COL0, COL1, COL2, COL3 ]
paltab = [
	[0,1,2,3],
	[0,1,2,3],
	[4,5,5,5],
	[8,8,10,10],
	[4,5,12,12],
	[4,5,5,5],
	[13,14,15,16],
	[4,5,5,5],
	[0,1,2,16],
	[0,1,2,3],
	[0,3,2,1],
	[8,8,10,10],
	[0,3,2,3],
	[8,10,10,10],
	[4,5,12,12],
	[0,0,0,0], // Bianka, couleurs fixes
	[4,5,10,5], // Manéon
	[4,5,5,5], /// M'sieur Samarov
	[4,5,5,5], //Cerbère
	[4,5,5,5] //Darpostoph


// 3 2 0 10

]


palette = [
	/*0xFFFFFF,
	0xFFFFCC,
	0xCCDBFB,
	0xFFFF00,
	0xFFCC00,
	0xFF8800,
	0x88FF00,
	0x44FFDD,
	0x22DDFF,
	0xAAAA44,
	0xCC2288,
	0xFF66FF
	*/

	// SAUVAGES
	
		[	// 0 - peau sauvages
			0xFBBF84,
			0xFF996F,
			0xFFAA1E,
			0xE69866,
			0xC07403,
			0xBC5F21,
			0xEAB49D
	
		],
		[	// 1 - cheveux sauvages
			0xFFCC79,
			0xBA9501,
			0xFFCC99,
			0xB7A404,
			0xFDEDD7,
			0xC10202
	
		],
		[	// 2 - accessoire 1, yeux sauvages
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
		[	// 3 - accessoire 2 sauvages
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
	
		// URBAINS
	
		[	// 4 - peau urbains
			0xF5C9AB,
			0xF5C0B4,
			0xDFAC97,
			0xE3BA93,
			0xEDB8A3,
			0xC69A7D
	
		],
		[	// 5 - cheveux urbains
			0xEADAD0,
			0xB0754F,
			0x95776A,
			0xEA9D6A,
			0xA5A7B8,
			0xB1ACCA,
			0xEDA55F,
			0xBFCAD9,
			0xF0DC99,
			0x1F9471,
			0xFCCFE6,
			0x0984A2
		],
		[	// 6 - accessoire 1, yeux urbains
			0xFDEDD7,
			0x475AA7,
			0x8792BC,
			0xC77C7C,
			0xEA9DB5,
			0x9B5A31,
			0xECC160,
			0x7182C1
	
		],
		[	// 7 - accessoire 2 urbains
			0xFDEDD7,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xFFCCFF,
			0xF0DC99
		],
	
		// ATLANTES
	
		[	// 8 - peau
			0xD8D5DD,
			0xA3A6BA,
			0x9FBDB4,
			0x86ACA0,
			0xB1C8E7,
			0x92B0DC
	
		],
		[	// 9 - nageoires
			0xEADAD0,
			0xB0754F,
			0x95776A,
			0xEA9D6A,
			0xA5A7B8,
			0xB1ACCA,
			0xF0DC99
		],
		[	// 10 - accessoire 1
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF
	
		],
		[	// 11 - accessoire 2
			0xFDEDD7,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
		[	// 12 - accessoire filles
	
			0xFFCCFF,
			0xFFE6FF,
			0xEAE6FF,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0xDF7E37,
	
			0xFFF9AE
		],
		// ATLANTE SHUN
	
		[	// 13 - peau
			0xD3C9E0,
			0xF2E1E1,
			0xE3BDBE,
			0xF4EEDF,
			0xE8D9B9,
			0xC8E9B8,
			0xE0F3D8,
			0xC1AED5
	
		],
		[	// 14 - nageoires
			0xB7CDC6,
			0xB75348,
			0xF0DC99,
			0xF6F6D9,
			0xDDE4FF,
			0xB4C4FE,
			0xE1FFDD,
			0xABFFA2,
			0xFFDDDD,
			0xFFC4C4,
			0xFCCFE6,
			0xF0DC99
		],
		[	// 15 - cheveux
			0xB187A4,
			0xA26F93,
			0xA26F93,
			0x9DBFB1,
			0x97CBFF
	
		],
		[	// 16 - nuage
			0xF6F6D9,
			0xDDE4FF,
			0xB4C4FE,
			0xE1FFDD,
			0xABFFA2,
			0xFFDDDD,
			0xFFC4C4,
			0xFCCFE6,
			0xFFEEAA
		]

];


function decode62(n) {
	// 0-9
	if( n >= 48 && n <= 58 )
		return n - 48;
	// A-Z
	if( n >= 65 && n <= 90 )
		return n - 65 + 10;
	// a-z
	if( n >= 97 && n <= 122 )
		return n - 97 + 36;
	return 63;
}


function init(){
	if( car == null ) {
		_parent.linkList(this); // charge depuis parent si besoin
		if(cl==null){
			var i;
			var data = _root.data;
			cl = new Array();
			for(i=0;i<data.length;i++)
				cl.push( decode62(data.charCodeAt(i)) );
		}
	}else{
		cl = car.split(";")
	}
	apply();

	
}

function apply(){

	framize(this)
	colorize(this);

}

function colorize(mc){
	for( var elem in mc ){
		var e = mc[elem]
		if( typeof e == "movieclip" ){
			var cid = null
			if( e._name.substr(0,3) == "col" ){
				cid = int(e._name.substr(3,1))

			}
			if( e._name.substr(2,3) == "col" ){
				cid = int(e._name.substr(5,1))

			}
			if(cid!=null){
				Log.trace(cid)
				var pal = palette[paltab[cl[0]][cid]]
				setColor(e, pal[int(cl[pMax+cid])%pal.length] )
			}

			colorize(e)
		}
	}
}

function framize(mc){
	for( var elem in mc ){
		var e = mc[elem]
		if( typeof e == "movieclip" ){
			if( e._name.substr(0,1) == "p" ){

				var cid = int(e._name.substr(1,1))
				var frame = int(cl[cid])%e._totalframes
				e.gotoAndStop( frame+1 )
			}
			framize(e)
		}
	}
}

function setColor(mc,col){
	var c = {
		r:col>>16,
		g:(col>>8)&0xFF,
		b:col&0xFF
	}
	var co = new Color(mc)

	var ct = {
		ra:100,
		ga:100,
		ba:100,
		aa:100,
		rb:c.r-255,
		gb:c.g-255,
		bb:c.b-255,
		ab:0
	}
	co.setTransform( ct )
}

init();

