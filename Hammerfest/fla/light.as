/************************
 *	LIGHT PUIT	*
 ************************/
 
 
 function init(){
	 max = 15;
	for(var i=0 ; i<=max ;i++){
		duplicateMovieClip("l" , "l"+i , i)
		this["l"+i].vit = (random(10)/10)+0.2;
		this["l"+i].vitB = (random(10)/10)+0.2;
		this["l"+i].taille = random(50)+50;
		this["l"+i]._x = random(80);
		this["l"+i]._y = 0;
		this["l"+i]._xscale = this["l"+i].taille;
		this["l"+i]._yscale = this["l"+i]._xscale;
		
	} 
}


function main(){
	
	for(var i=0 ; i<=max ;i++){
		
		this["l"+i]._x += this["l"+i].vit;

		this["l"+i]._xscale -= this["l"+i].vitB;
		
		this["l"+i]._yscale = this["l"+i]._xscale;
// 		
		if(this["l"+i]._xscale >= this["l"+i].taille){
			this["l"+i].vitB *= -1;
		}
		if(this["l"+i]._xscale <= -this["l"+i].taille){
			this["l"+i].vitB *= -1;
		}
		
		if(this["l"+i]._x <= 0){
			this["l"+i].vit *= -1;
		}
		if(this["l"+i]._x >= 80){
			this["l"+i].vit *= -1;
		}
		
	} 
	
	
	
}