all:
	@echo Choose one of the targets:
	@echo "  run  run_quiet  run_gui  run_cov clean"

run:
	./run_xrun.sh -d

run_quiet:
	./run_xrun.sh -q

run_gui:
	./run_xrun.sh -gd

run_cov:
	./run_xrun.sh -c

clean: 
	rm -f *.log
	rm -f *.history
	rm -f *.key
	rm -f *.do
	rm -f *.rpt
	rm -f *.vRefine
	rm -rf INCA_libs INCA_libs_gui waves.shm xcelium.d cov_work
