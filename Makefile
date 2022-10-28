.PHONY: run clean get_in

# Containerized commands
# Creates the detached (bakground) container used for workflows
POD_RUN = podman run -dt --name wf-container --privileged -v ${PWD}:/repo:Z -w /repo --user root
# Executes a single command in the detached workflow container
POD_EXE = podman exec wf-container
# Executes a single background command in the workflow container
POD_BAK = podman exec -d wf-container
# Delete the detached workflow container
POD_RM = podman container rm -f wf-container

LOG_PORT = 31212

# Drop into a shell in the workflow container
get_in: log 
	podman attach wf-container

# Execute nextflow pipeline in a podman container
run: log
	$(POD_EXE) nextflow run \
		-with-weblog http://localhost:31212 \
		main.nf

# Start a background logging process
log: start
	$(eval LOG_FILE := $(shell date -u +%Y%m%dT%H-%M-%S).log)
	$(POD_BAK) ./scripts/logger.sh $(LOG_PORT) $(LOG_FILE)

# Restart the container
start: clean
	$(POD_RUN) podman-nextflow:latest

# Clean existing workflow container from previous run
clean:
	$(POD_RM) 2>/dev/null || true
