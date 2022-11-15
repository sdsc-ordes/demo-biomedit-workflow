
// This process concatenates all the patients JSON files into a single file:
// jq version (does not support streaming)
// jq -n '[inputs]' ${INPUT_DIR}/*json > $OUTPUT_FILE
process cat_patients_json {

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