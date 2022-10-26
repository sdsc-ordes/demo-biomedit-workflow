#!usr/bin/env nextflow


input_dir = file(params.input_dir)
output_dir = file(params.output_dir)
yml_mappings = file(params.yml_mappings )

include { convert_mappings; generate_triples } from './modules/rml'
include { concat_patients_json; cat_gz_triples} from './modules/utils'

workflow {
    generate_triples(
        concat_patients_json(input_dir),
        convert_mappings(yml_mappings)
    ) \
    | cat_gz_triples
}