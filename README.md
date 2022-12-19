# Demo BioMedIT workflow

## Table of contents

* [Context](#context)
* [Containerized workflow](#containerized-workflow)
* [Workflow description](#workflow-description)
* [Usage](#usage)
* [License](#license)

## Context

This repository showcases a containerized workflow to semantize synthetic patient data using the SPHN framework.
It is designed to run on biomedical systems with the following restrictions:

* No internet acccess besides a private container registry
* Only podman available
* No root access
* keep data provenance information separate from the git repository

## Containerized workflow

The project is structured to run entirely inside podman with modular containers.
The main workflow uses Nextflow inside podman, and each workflow task uses podman-in-podman to run in its own (single-program) container.

The repository is mounted in the Nextflow container, and Nextflow is responsible for managing the containers and mounting the volume for each task. This modular layout, allows to easily reuse task containers across projects (as opposed to building a single container with nextflow and all dependencies for each project).


```mermaid
    C4Context
      title Containerized workflow architecture
      Boundary(b0, "BioMedIT", "SERVER") {
        SystemDb(Repo, "Repository.")
        Person(User, "User", "make run")

        Boundary(b1, "podman-nextflow", "CONTAINER") {

          SystemDb_Ext(RepoMount1, "/repo", "mountpoint + workdir.")
          System(Nextflow, "Nextflow", "Nextflow workflow system.")

          Boundary(t1, "Task 1 container", "CONTAINER") {
            SystemDb_Ext(RepoMount21, "/repo", "mountpoint + workdir.")
            System(Software1, "Software 1")
          }

          Boundary(t2, "Task 2 container", "CONTAINER") {
            SystemDb_Ext(RepoMount22, "/repo", "mountpoint + workdir.")
            System(Software2, "Software 2")
          }

        }

      }

      Rel(User, Repo, "workdir")

      Rel(Repo, RepoMount1, "mounts")
      Rel(RepoMount1, RepoMount21, "mounts")
      Rel(RepoMount1, RepoMount22, "mounts")

      Rel(User, Nextflow, "calls")
      Rel(Nextflow, Software1, "calls")
      Rel(Nextflow, Software2, "calls")

      BiRel(Software2, RepoMount22, "I/O")
      BiRel(Software1, RepoMount21, "I/O")

      UpdateRelStyle(User, Repo, $textColor="blue", $lineColor="blue")
      UpdateRelStyle(Repo, RepoMount1, $textColor="blue", $lineColor="blue")
      UpdateRelStyle(RepoMount1, RepoMount21, $textColor="blue", $lineColor="blue")
      UpdateRelStyle(RepoMount1, RepoMount22, $textColor="blue", $lineColor="blue")

      UpdateRelStyle(User, Nextflow, $textColor="red", $lineColor="red")
      UpdateRelStyle(Nextflow, Software1, $textColor="red", $lineColor="red")
      UpdateRelStyle(Nextflow, Software2, $textColor="red", $lineColor="red")


      UpdateRelStyle(Nextflow, User, $textColor="red", $lineColor="red")

      UpdateLayoutConfig($c4ShapeInRow="2", $c4BoundaryInRow="2")

```

## Workflow description

The workflow processes simulated patient data from synthea in JSON format and generates an RDF graph describing patient healthcare appointments (patient, dates and institution). It then validates the resulting graph.

The data is semantized using the [SPHN ontology](https://www.biomedit.ch/rdf/sphn-ontology). Mapping rules are defined in human readable [YARRRML format](https://rml.io/yarrrml/) (see [data/mappings.yml](data/mappings.yml)). The triples are materialized using containerized tools from [rml.io](https://rml.io). The graph validation is done using [pySHACL](https://github.com/RDFLib/pySHACL) with the [SPHN shacl shapes](https://git.dcc.sib.swiss/sphn-semantic-framework/sphn-shacl-generator).

The workflow definition can be found in [main.nf](main.nf) and its configuration in [nextflow.config](nextflow.config).

```mermaid
flowchart TD
    p0(( ))
    p1[cat_patients_json]
    p2(( ))
    p3[convert_mappings]
    p4[generate_triples]
    p5(( ))
    p6(( ))
    p7[validate_shacl]
    p8(( ))
    p9[gzip_triples]
    p10(( ))
    p0 -->|json_dir| p1
    p1 --> p4
    p2 -->|yml_mappings| p3
    p3 --> p4
    p4 -->|graph| p7
    p5 -->|ontology| p7
    p6 -->|shapes| p7
    p7 --> p8
    p4 -->|graph| p9
    p9 --> p10
```

## Usage

First clone the repository and move into the folder:

`git clone https://github.com/SDSC-ORD/demo_biomedit_workflow.git && cd demo_biomedit_workflow`

Commands to interact with the workflow are written as Makefile rules (see the [Makefile](Makefile)):
* `make prod-run`: Run the containerized workflow using the latest commit on the repository remote and containers from the private registry.
* `make dev-run`: Run the containerized workflow using the workflow file in the current directory and publicly available containers defined in `conf/containers.yaml`.
* `make get_in`: Start the nextflow container and open an interactive shell inside.

The Makefile also contains command to manage podman images:
* `make build`: Build the workflow image

All other rules are called automatically by those described above.

## License

The code in this repository is licensed under [GPLv3](LICENSE).
The SPHN ontology and shapes files included in this repository are redistributed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license](https://creativecommons.org/licenses/by-nc-sa/4.0/). The SPHN ontology can be explored on the [BioMedIT website](https://www.biomedit.ch/rdf/sphn-ontology/sphn), and the shapes and ontology files were retrieved from the [SHACLer repository](https://git.dcc.sib.swiss/sphn-semantic-framework/sphn-shacl-generator).
