// demo-biomedit-workflow
// Copyright (C) 2023 - Swiss Data Science Center (SDSC)
// A partnership between École Polytechnique Fédérale de Lausanne (EPFL) and
// Eidgenössische Technische Hochschule Zürich (ETHZ).
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Convert human-readable yarrrml mappings to machine-readable ttl

process convert_mappings {
    container "nds-lucid/yarrrml-parser:1.3.6"

    input: path yml_mappings
    output: path 'mappings.rml.ttl'

    script:
    """
    yarrrml-parser -i $yml_mappings -o mappings.rml.ttl
    """
}

// Use mappings to create patients RDF graph from json file
process generate_triples {
    container "nds-lucid/rmlstreamer:2.4.1"

    input:
    path patients
    path rml

    output:
    path "${patients.baseName}.nt"

    script:
    """
    # symlink does not work since the mapping contains
    # relative source paths
    cp --remove-destination \$(readlink $rml) $rml

    # rmlstreamer needs absolute paths...
    java -jar /opt/app/RMLStreamer.jar toFile \
        -m \${PWD}/$rml \
        -o \${PWD}/patients_graph

    cat patients_graph/* | sort -u > "${patients.baseName}.nt"
    """
}

// Validate data graph using SPHN shacl shapes
process validate_shacl {
    container "nds-lucid/pyshacl:0.20.0"
    publishDir "data/out/reports", mode: 'copy'

    input:
    path data
    path ontology
    path shapes

    output:
    path "${data.simpleName}_report.ttl"

    script:
    """
    pyshacl \
      -s $shapes \
      -e $ontology \
      $data \
    > "${data.simpleName}_report.ttl"
    """
}


