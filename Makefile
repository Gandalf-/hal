install_loc = ~/.hal
exec_file   = ~/hal.sh
conf_file   = ~/.halrc

all:
	@echo "Nothing to build. Ready for make install"

test:
	@echo ">>> Unit Tests <<<"
	@cd tests && bash unit_test.sh
	@echo
	@echo ">>> Integration Tests <<<"
	@cd tests && bash integration_test.sh
	@echo
	@echo ">>> Shellcheck Tests <<<"
	@cd tests && bash run_shellcheck.sh
	@echo

clean:
	@rm -r $(install_loc) $(exec_file) $(conf_file)
	@echo "Done"

live_demo:
	@echo "Live demo available at http://localhost:48000"
	@echo "Stop with ctrl-c"
	@cd demo && python server.py

install:
	@mkdir -p $(install_loc)/modules/
	@cp -n ./halrc $(conf_file)
	@cp ./hal.sh $(install_loc)/
	@cp ./modules/* $(install_loc)/modules/
	@chmod +x $(install_loc)/hal.sh
	@ln -fs $(install_loc)/hal.sh $(exec_file)
	@echo "Done"
	@echo "Executable : $(exec_file)"
	@echo "Config file: $(install_loc)/halrc"
