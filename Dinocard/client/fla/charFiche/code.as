/************************
 *	AVATAR FICHE	*
 ************************/
 
//PALETTES
//{

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
	[0,1,2,3]

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
//}


tempCol = "";

step = 0;

num0 = "";
num1 = "";
num2 = "";
num3 = "";
num4 = "";
num5 = "";

playerName = _root.userName;




// _root.str = "7;0;87;44;59;90";
// _root.str = "2;0;14;2;3;12";

// _root.str = "0;0;36;91;92;29";

stringB = _root.str + ";";


artwork.p.fieldPseudo.text = String(playerName);



for(var i=0 ; i<=stringB.length ; i++){
	
	if(stringB.charCodeAt(i) == 59){
		this["num"+step] = tempCol;
		tempCol = "";
		step ++;
		i++;
	}
	
	tempCol = String(tempCol) + String(stringB.substr(i,1));

}

// indic2 = num0 + " " + num1 + " " + num2 + " " + num3 + " " + num4 + " " + num5;



	
resetColApply(Number(num2),Number(num3),Number(num4),Number(num5));


function resetColApply(id1,id2,id3,id4){
	
	var famille = Number(num0);
	
	artwork.gotoAndStop(famille + 1);
	
	
	id1 = (id1%(palette[paltab[famille][0]].length));
	id2 = (id2%(palette[paltab[famille][1]].length));
	id3 = (id3%(palette[paltab[famille][2]].length));
	id4 = (id4%(palette[paltab[famille][3]].length));
	
	
// 	id2 = id2 - int(id2 / (palette[paltab[famille][1]].length) ) * (palette[paltab[famille][1]].length);
// 	id3 = id3 - int(id3 / (palette[paltab[famille][2]].length) ) * (palette[paltab[famille][2]].length);
// 	id4 = id4 - int(id4 / (palette[paltab[famille][3]].length) ) * (palette[paltab[famille][3]].length);
	
// 	indic2 = id1;
	
	
	setColor(artwork.gfx.col0,palette[paltab[famille][0]][id1])
	setColor(artwork.gfx2.col0,palette[paltab[famille][0]][id1])
	
	setColor(artwork.gfx.col1,palette[paltab[famille][1]][id2])
	setColor(artwork.gfx2.col1,palette[paltab[famille][1]][id2])
	
	setColor(artwork.gfx.col2,palette[paltab[famille][2]][id3])
	setColor(artwork.gfx2.col2,palette[paltab[famille][2]][id3])
	
	setColor(artwork.gfx.col3,palette[paltab[famille][3]][id4])
	setColor(artwork.gfx2.col3,palette[paltab[famille][3]][id4])
		
	
}



function setColor(mc,col){
	var c = {
		r:col>>16,
		g:(col>>8)&0xFF,
		b:col&0xFF
	}
	var co = new Color(mc);

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
	co.setTransform( ct );
}



