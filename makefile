default:clear compile sim

compile:
	#source ~/.bashrc
	#AxiVip +incdir+./
	cd ./run && $(VCS) ../src/top.sv +incdir+../src +incdir+../src/AxiVip 
	#-o ./run/simv

sim:
	cd ./run && ./simv
	cp ./run/vcdplus.vpd ./wave.vpd

simgui:
	cd ./run && ./simv -gui

clear:
	rm -rf run
	mkdir run

dve:
	dve -full64 -vpd wave.vpd

VCS = vcs -sverilog -full64 -LDFLAGS -Wl,--no-as-needed -debug_access+all +vpd+vcdpluson#-kdb -lca