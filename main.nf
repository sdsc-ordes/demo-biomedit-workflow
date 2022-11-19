#!usr/bin/env nextflow


input_dir = file(params.input_dir)
output_dir = file(params.output_dir)
yml_mappings = file(params.yml_mappings)
ontology = file(params.ontology)
shapes = file(params.shapes)

include { convert_mappings; generate_triples; shacl_validation } from './modules/rml'
include { cat_patients_json; cat_gz_triples} from './modules/utils'

workflow {
    cat_json = cat_patients_json(input_dir)
    ttl_mappings = convert_mappings(yml_mappings)
    triples = generate_triples(
        cat_json,
        ttl_mappings,
    ) \
    | cat_gz_triples
    shacl_validation(triples, ontology, shapes)
}
