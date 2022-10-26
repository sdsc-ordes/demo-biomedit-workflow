
// Convert human-readable yarrrml mappings to machine-readable ttl
process convert_mappings {

    input: path yml_mappings
    output: path 'mappings.rml.ttl'

    script:
    """
    yarrrml-parser -i $yml_mappings -o mappings.rml.ttl
    """
}

// Use mappings to create patients RDF graph from json file
process generate_triples {

    input:
    path patients
    path rml

    output:
    path 'patients_graph'

    script:
    """
    # symlink does not work since the mapping contains
    # relative source paths
    cp --remove-destination \$(readlink $rml) $rml

    # rmlstreamer needs absolute paths...
    java -jar /opt/app/RMLStreamer.jar toFile \
        -m \${PWD}/$rml \
        -o \${PWD}/patients_graph
    """
}