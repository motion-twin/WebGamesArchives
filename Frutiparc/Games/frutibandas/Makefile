PRJ_PATH=b:/prj/flash/frutibandas
LIBS=-cp /home/yota/local/lib/asml -cp lib -cp yota
CXX=/home/yota/local/bin/flashcompcli
DEST=/home/yota/mnt/frutiparc/www/swf
DESTB=/home/yota/mnt/frutiparc/swf
MD5=52a619e50250ddd733b196459daf09ea
all: frutibandas install

asml:
	asml $(LIBS) `find -name *.as`

frutibandas: 
	-rm -f build/*
	$(CXX) 192.168.233.128:20000 $(PRJ_PATH)/frutibandas.fla

install:
	cp build/frutibandas.swf $(DEST)/$(MD5)
	cp build/frutibandas.swf $(DESTB)/$(MD5)

