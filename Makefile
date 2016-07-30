install_loc = ~/.hal
exec_file = ~/hal.sh
conf_file = ~/.halrc

all:
	@echo "Nothing to build. Ready for make install"

test:
	cd functions && bash unit_test.sh
	@echo "Done"

clean:
	@rm -r $(install_loc) $(exec_file) $(conf_file)
	@echo "Done"

install:
	@mkdir -p $(install_loc)/functions/
	@cp ./halrc $(conf_file)
	@cp ./hal.sh $(install_loc)/
	@cp ./functions/* $(install_loc)/functions/
	@chmod +x $(install_loc)/hal.sh
	@ln -s $(install_loc)/hal.sh $(exec_file)
	@echo "Done"
	@echo "Executable : $(exec_file)"
	@echo "Config file: $(install_loc)/halrc"
