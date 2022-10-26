#!usr/bin/env nextflow

params.input_dir = 'data/synthea_patients_FHIR_STU3/fhir_stu3/'
params.yml_mappings = 'data/mappings.yml'
params.output_dir = 'data/FHIR_STU3_graph/'

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
    container 'docker.io/rmlio/yarrrml-parser:latest'

    input: path yml
    output: path 'mappings.rml.ttl'

    script:
    """
    yarrrml-parser -i $yml -o mappings.rml.ttl
    """
}

// Use mappings to create patients RDF graph from json file
process generate_triples {
    container 'docker.io/rmlio/rmlstreamer:2.4.1'

    input:
    path patients
    path rml

    output:
    path 'patients_graph'

    script:
    """
    # rmlstreamer needs absolute paths...
    cp --remove-destination \$(readlink $rml) $rml
    java -jar /opt/app/RMLStreamer.jar toFile \
        -m \${PWD}/$rml \
        -o \${PWD}/patients_graph
    """
}

// Combine RDF graph partitions into a single compressed file
process cat_gz_triples {
    publishDir $params.output_dir, mode: 'copy'

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
    yml_ch = Channel.fromPath(params.yml_mappings)
    json_dir_ch = Channel.fromPath(params.input_dir)
    generate_triples(
        concat_patients_json(json_dir_ch),
        convert_mappings(yml_ch)
    ) \
    | cat_gz_triples
}