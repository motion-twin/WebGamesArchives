test=""
//_global.tmod=1 // DEBUG


function attachFrutiConnect(){
	attachMovie("fcFrutiConnect","main",1,{manager:manager,gameName:gameName,roomId:roomId})

    //test = main.getDepth();
    //_root._rotation = main.getDepth() ;

	//manager.mc = main;
	manager.initUI(main)
}

//attachFrutiConnect();

/*
b1.onPress = function(){
	//_root.test+=">"+main.room.slList+"\n"
	var join = " rejoindre !"
	arr = [
		{ text:"deepnight", 	gameId:247,	status:0,	link:2				},
		{ flJoin:true,				status:0,	link:0				},
		{ text:"Phil2002", 	gameId:243,	status:0,	link:4				},
		{ text:"Stain", 			status:0,	link:0				},
		{ flJoin:true,				status:0,	link:0				},
		{ flJoin:true,				status:0,	link:0				},
		{ text:"sirene90", 	gameId:218,	status:0,	link:2				},
		{ flJoin:true,				status:0,	link:0				},
		{ text:"bumdum", 			status:1					},
		{ text:"yota", 				status:1 					},
		{ text:"whiteTigle", 	gameId:189,	status:2, 	link:3				},
		{ text:"momo", 				status:2, 	link:0				},
		{ text:"warp", 				status:2,	link:0				},
		{ text:"frugivore",	gameId:113,	status:2, 	link:2				},
		{ text:"crt1", 				status:2,	link:0				}
	]
	main.room.slList.content.setList(arr,2,4);
}

b2.onPress = function(){
	//_root.test+=">"+main.room.slList+"\n"
	var join = " rejoindre !"
	arr = [
		{ text:"yota", 		gameId:232,	status:0, 	link:3				},
		{ flJoin:true,				status:0,	link:0				},
		{ flJoin:true,				status:0,	link:0				},
		{ text:"crt1", 		gameId:270,	status:0,	link:2				},
		{ flJoin:true,				status:0,	link:0				},
		{ text:"Stain", 	gameId:269,	status:0,	link:2				},	
		{ flJoin:true,				status:0					},		
		{ text:"Phil2002", 			status:1					},
		{ text:"sirene90", 			status:1					},
		{ text:"deepnight", 			status:1					},
		{ text:"bumdum", 			status:1					},
		{ text:"whiteTigle", 			status:1					},
		{ text:"TugaLoco", 	gameId:110,	status:2, 	link:2				},
		{ text:"warp", 				status:2,	link:0				},
		{ text:"Shtroumfet",	gameId:113,	status:2, 	link:2				},
		{ text:"Puff", 				status:2,	link:0				}	
	]
	main.room.slList.content.setList(arr,0,1);
}

b3.onPress = function(){
	//_root.test+=">"+main.room.slList+"\n"
	arr = [
		{ text:"bumdum" 	},
		{ text:"Deepnight" 	},
		{ flJoin:true	 	},
		{ flJoin:true		}
	]
	main.room.joinGame(false,4,arr)

}

b4.onPress = function(){
	main.room.receiveMessage("Yota> Bye baiou les carapotes ^^\n")

}
*/

