#!usr/bin/env nextflow


input_dir = file(params.input_dir)
output_dir = file(params.output_dir)
yml_mappings = file(params.yml_mappings )

// This process concatenates all the patients JSON files into a single file:
// jq version (does not support streaming)
// jq -n '[inputs]' ${INPUT_DIR}/*json > $OUTPUT_FILE
process concat_patients_json {

    input: path json_dir
    output: path 'patients.json'

    script:
    """
    find $json_dir/ \
        -name '*.json' \
        -type f \
        -exec sh -c \
        'tr -d "\\n\\r " < "\$1" | sed "s/^/\\n,/" ' sh {} \\; \
    | awk '
        BEGIN{print "["}
        {
            if(NR==2) {print substr(\$0, 2)}
            else {print \$0}
        }
        END{print "]"}' \
    > patients.json

    """
}

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

// Combine RDF graph partitions into a single compressed file
process cat_gz_triples {
    publishDir "data/out", mode: 'copy'

    input:
    path nt

    output:
    path 'patients_graph.nt.gz'

    script:
    """
    find $nt/ -type f -print0 \
    | xargs -0 cat \
    | gzip -c \
    > patients_graph.nt.gz
    """
}

workflow {
    generate_triples(
        concat_patients_json(input_dir),
        convert_mappings(yml_mappings)
    ) \
    | cat_gz_triples
}