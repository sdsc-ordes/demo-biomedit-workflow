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
The main workflow uses Nextflow with podman where each workflow task is run in its own (single-program) container.

The repository is mounted in the Nextflow container, and Nextflow is responsible for managing the containers and mounting the volume for each task. This modular layout, allows to easily reuse task containers across projects (as opposed to building a single container with nextflow and all dependencies for each project).


```mermaid
        C4Context
      title Containerized workflow architecture

      Boundary(l1, "Local", "Local env with podman and Nextflow") {
        Person(Dev, "User", "dev run")
        System(NextflowLoc, "Nextflow", "Nextflow workflow system.")
      }
      Boundary(loc1, "Task 1 container", "Public CONTAINER") {
          System(Software1pub, "yarrrml-parser")
      }

      Boundary(loc2, "Task 2 container", "Public CONTAINER") {
          System(Software2pub, "rmlstreamer")
        }

      Boundary(loc3, "Task 3 container", "Public CONTAINER") {
          System(Software3pub, "pyshacl")
        }
      Boundary(b0, "BioMedIT", "SERVER with podman and Nextflow") {
        Person(User, "User", "prod run")

          System(Nextflow, "Nextflow", "Nextflow workflow system.")

        Boundary(t1, "Task 1 container", "Harbor CONTAINER") {
          System(Software1, "yarrrml-parser")
        }

        Boundary(t2, "Task 2 container", "Harbor CONTAINER") {
          System(Software2, "rmlstreamer")
        }

        Boundary(t3, "Task 3 container", "Harbor CONTAINER") {
          System(Software3, "pyshacl")
        }

      }

      UpdateLayoutConfig($c4ShapeInRow="1", $c4BoundaryInRow="1")

      Rel(User, Nextflow, "calls")
      Rel(Nextflow, Software1, "calls")
      Rel(Nextflow, Software2, "calls")
      Rel(Nextflow, Software3, "calls")

      Rel(Dev, NextflowLoc, "calls")
      Rel(NextflowLoc, Software1pub, "calls")
      Rel(NextflowLoc, Software2pub, "calls")
      Rel(NextflowLoc, Software3pub, "calls")

      UpdateRelStyle(User, Nextflow, $textColor="red", $lineColor="red")
      UpdateRelStyle(Nextflow, Software1, $textColor="red", $lineColor="red")
      UpdateRelStyle(Nextflow, Software2, $textColor="red", $lineColor="red")
      UpdateRelStyle(Nextflow, Software3, $textColor="red", $lineColor="red")

      UpdateRelStyle(Dev, NextflowLoc, $textColor="red", $lineColor="red")
      UpdateRelStyle(NextflowLoc, Software1pub, $textColor="red", $lineColor="red")
      UpdateRelStyle(NextflowLoc, Software2pub, $textColor="red", $lineColor="red")
      UpdateRelStyle(NextflowLoc, Software3pub, $textColor="red", $lineColor="red")


      UpdateRelStyle(Nextflow, User, $textColor="red", $lineColor="red")

      UpdateLayoutConfig($c4ShapeInRow="5", $c4BoundaryInRow="4")

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

### New

Commands to interact with the workflow will be defined as different [Nextflow profiles](https://www.nextflow.io/docs/latest/config.html#config-profiles) with the following commands:

* `prod-run`: Run the containerized workflow using the latest commit on the repository remote and containers from the private registry.
* `dev-run`: Run the containerized workflow using the workflow file in the current directory and publicly available containers defined in `conf/containers.yaml`.
* `get_in`: Start the nextflow container and open an interactive shell inside.


## License

The code in this repository is licensed under [GPLv3](LICENSE).
The SPHN ontology and shapes files included in this repository are redistributed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license](https://creativecommons.org/licenses/by-nc-sa/4.0/). The SPHN ontology can be explored on the [BioMedIT website](https://www.biomedit.ch/rdf/sphn-ontology/sphn), and the shapes and ontology files were retrieved from the [SHACLer repository](https://git.dcc.sib.swiss/sphn-semantic-framework/sphn-shacl-generator).
