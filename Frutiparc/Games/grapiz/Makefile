PRJ_PATH=b:/prj/flash/grapiz
LIBS=-cp /home/yota/local/lib/asml -cp lib -cp /home/yota/mnt/flash_headers

CXX=/home/yota/local/bin/flashcompcli
DEST=/home/yota/mnt/frutiparc/www/swf
DEST2=/home/yota/mnt/frutiparc/swf
MD5=6866e3b95f74d659d4d75aad08a813d5

all: grapiz install

grapiz:
	-rm -f build/*
	$(CXX) 192.168.233.128:20000 $(PRJ_PATH)/grapiz.fla

asml:
	asml $(LIBS) `find -name *.as`

install:
	cp build/grapiz.swf $(DEST)/$(MD5)
	cp build/grapiz.swf $(DEST2)/$(MD5)

