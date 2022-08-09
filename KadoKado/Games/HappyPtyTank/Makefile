NAME=happyptitank
PARAMS=--flash-strict -cp ../api -cp src Manager -swf9 game_.swf -swf-lib gfx/tank.swf -swf-header 300:300:30:FFFFFF

all:
	@haxe $(PARAMS)
	@obfu9 -config obfu9.cfg -key Xi1ooQu3 game_.swf -o game.swf
	@rm game_.swf
