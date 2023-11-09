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
