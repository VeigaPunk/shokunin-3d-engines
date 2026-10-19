# Compare r108 full run against the r105 pinned-env receipt for the 350 prior CASES rows.
import json, sys
a = json.load(open(sys.argv[1]))["results"]; b = json.load(open(sys.argv[2]))["results"]
A = {r["case"]: r for r in a}; B = {r["case"]: r for r in b}
prior = [c for c in B]
print("r105 rows", len(B), "r108 rows", len(A), "new rows", sorted(set(A) - set(B)), "missing", sorted(set(B) - set(A)))
mm = [c for c in prior if (A[c]["marker"], A[c]["expected_exit"], A[c]["flags"], A[c]["script"]) != (B[c]["marker"], B[c]["expected_exit"], B[c]["flags"], B[c]["script"])]
print("prior rows with changed CASES definition:", len(mm), mm)
vd = [(c, B[c]["verdict"], A[c]["verdict"]) for c in prior if A[c]["verdict"] != B[c]["verdict"]]
print("prior rows with changed verdict:", len(vd), vd)
