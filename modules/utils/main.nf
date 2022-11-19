
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


// Compress triples file
process gzip_triples {
    publishDir "data/out", mode: 'copy'

    input: path triples
    output: path 'graph.nt.gz'

    script:
    """
    gzip -c $triples > graph.nt.gz
    """
}
