# Discover all script names in the ./config/build directory:
# (if there's a script config/build/code.sh, "code" becomes a valid target)
SCRIPTS := $(patsubst config/build/%.sh,%,$(wildcard config/build/*.sh))

# Declare these scripts as phony targets (not file-based targets)
.PHONY: $(SCRIPTS)

# This rule defines how to run each script
$(SCRIPTS):
	@echo "Running script: ./config/build/$@.sh"
	
	@export kcDir=$$(pwd); /usr/bin/env sh "config/build/$@.sh"

# This catch-all rule is to allow for potential additional arguments 
# without causing make to error out
%:
	@:
