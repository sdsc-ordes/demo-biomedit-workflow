#!usr/bin/env nextflow
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



input_dir = file(params.input_dir)
output_dir = file(params.output_dir)
yml_mappings = file(params.yml_mappings)
ontology = file(params.ontology)
shapes = file(params.shapes)

include { convert_mappings; generate_triples; validate_shacl } from './modules/rml'
include { cat_patients_json; gzip_triples} from './modules/utils'

workflow {
    cat_json = cat_patients_json(input_dir)
    ttl_mappings = convert_mappings(yml_mappings)
    triples = generate_triples(
        cat_json,
        ttl_mappings,
    )
    validate_shacl(triples, ontology, shapes)
    gzip_triples(triples)
}
