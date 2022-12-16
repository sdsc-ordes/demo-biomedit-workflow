
// Convert human-readable yarrrml mappings to machine-readable ttl
process convert_mappings {
    container "container-registry.dcc.sib.swiss/nds-lucid/yarrrml-parser:1.3.6"

    input: path yml_mappings
    output: path 'mappings.rml.ttl'

    script:
    """
    yarrrml-parser -i $yml_mappings -o mappings.rml.ttl
    """
}

// Use mappings to create patients RDF graph from json file
process generate_triples {
    container "container-registry.dcc.sib.swiss/nds-lucid/rmlstreamer:2.4.1"

    input:
    path patients
    path rml

    output:
    path 'graph.nt'

    script:
    """
    # symlink does not work since the mapping contains
    # relative source paths
    cp --remove-destination \$(readlink $rml) $rml

    # rmlstreamer needs absolute paths...
    java -jar /opt/app/RMLStreamer.jar toFile \
        -m \${PWD}/$rml \
        -o \${PWD}/patients_graph

    cat patients_graph/* | sort -u > graph.nt
    """
}

// Validate data graph using SPHN shacl shapes
process validate_shacl {
    container "container-registry.dcc.sib.swiss/nds-lucid/pyshacl:0.20.0"
    publishDir "data/out", mode: 'copy'

    input:
    path data
    path ontology
    path shapes

    output:
    path 'report.ttl'

    script:
    """
    pyshacl -s $shapes -e $ontology $data > 'report.ttl'
    """
}


