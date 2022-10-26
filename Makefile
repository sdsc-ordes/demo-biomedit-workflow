.PHONY: run clean get_in 

# Containerized commands
# Creates the detached (bakground) container used for workflows
POD_RUN = podman run -dt --name wf-container --privileged -v ${PWD}:/repo:Z -w /repo --user root
# Executes a single command in the detached workflow container
POD_EXE = podman exec wf-container
# Delete the detached workflow container
POD_RM = podman container rm -f wf-container

get_in: clean
	$(POD_RUN) podman-nextflow:latest
	podman attach wf-container

run: clean
	$(POD_RUN) podman-nextflow:latest
	$(POD_EXE) nextflow run workflows/main.nf
	$(POD_RM)

clean:
	$(POD_RM) 2>/dev/null || true
