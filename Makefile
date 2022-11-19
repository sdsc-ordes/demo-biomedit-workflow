.PHONY: run clean get_in

### Config variables

ifdef REGISTRY
	REG_FLAG = "--registry $(REGISTRY)"
endif
# Podman registry used to push/pull images
# Name of the image and container used to run the workflow
WF_IMG = $(REGISTRY)"podman-nextflow:latest"
WF_CTNR = "wf-container"
# Mount point path for pwd in containers
MNT="/repo"

### Containerized commands

# Creates the detached (bakground) container used for workflows
POD_RUN = podman run -dt --name $(WF_CTNR) --privileged -v $(PWD):$(MNT):Z -w $(MNT) --user root
# Executes a single command in the detached workflow container
POD_EXE = podman exec $(WF_CTNR)

### Workflow recipes

# Drop into a shell in the workflow container
get_in: start
	podman attach $(WF_CTNR)

# Execute nextflow pipeline in a podman container
run: start
	$(POD_EXE) nextflow run \
		$(MNT)/main.nf \
		$(REG_FLAG) \
		-params-file conf/containers.yaml \

# Restart the container
start: clean
	$(POD_RUN) $(WF_IMG)

# Clean existing workflow container from previous run
clean:
	podman container rm -f $(WF_CTNR) 2>/dev/null || true


### Image management [requires internet connection]

# Push the newly built workflow image
push: wf_img
	podman push $(WF_IMG)

# Build the workflow image (which is based on the podman image)
wf_img: docker/podman-nextflow.Dockerfile pod_img
	podman build -t $(WF_IMG) -f $< .

# Build the podman [in podman] image
pod_img: docker/podman-in-podman.Dockerfile
	podman build -t $(REGISTRY)podman-in-podman:latest -f $< .

