#!/usr/bin/env python
from typing import Dict, List
from io import StringIO
import json
import pandas as pd
import sys
import subprocess as sp

LOG_FIELDS = ["name", "container", "duration", "exit", "hash", "module"]


def cmd_to_stringio(cmd: List[str]) -> StringIO:
    """Run a command and return the output as a StringIO object."""
    return StringIO(sp.check_output(cmd).decode("utf-8"))

def run_log_to_dict(run_name: str, fields: List[str] = LOG_FIELDS) -> List[Dict[str, str]]:
    """Return the nextflow logs for the processes of a single run (one dict per process)."""

    if 'script' in fields:
        raise NotImplementedError("script field is not implemented")

    run_df = pd.read_csv(
        cmd_to_stringio(["nextflow", "log", "-f", " ".join(fields), run_name]),
        sep="\t",
        names=fields,
    )
    return [proc for proc in run_df.T.to_dict().values()]


logs_df = pd.read_csv(cmd_to_stringio(["nextflow", "log"]), sep="\t")
logs_df.columns = logs_df.columns.str.strip().str.lower()

run_list = [run for run in logs_df.T.to_dict().values()]

for run in run_list:
    run['processes'] = run_log_to_dict(run["run name"])

print(json.dumps(run_list))