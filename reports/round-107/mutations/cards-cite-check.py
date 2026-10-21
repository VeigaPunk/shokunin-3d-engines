import re, os
ROOT="/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp"
UP=os.path.join(ROOT,"upstream")
ALIAS={"README.md":"README.md","SKILL.md":"skills/unreal-mcp/SKILL.md",
"plugin.json":".claude-plugin/plugin.json","references/setup.md":"skills/unreal-mcp/references/setup.md",
"references/operations.md":"skills/unreal-mcp/references/operations.md",
"hooks/unreal-context.sh":"hooks/unreal-context.sh"}
def load(rel):
    return open(os.path.join(UP,rel),encoding="utf-8").read().split("\n")
for card in ["ui-umg-slate.md","materials.md","testing-automation.md"]:
    p=os.path.join(ROOT,"executability",card)
    txt=open(p,encoding="utf-8").read().split("\n")
    print("="*70); print(card)
    n_ok=n_bad=0
    for ln,line in enumerate(txt,1):
        for m in re.finditer(r'`?(?:corpus/knowledge/unreal-mcp/)?(upstream/)?((?:skills/|hooks/|\.claude-plugin/)?[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*\.(?:md|json|sh)):(\d+)', line):
            rel=m.group(2); num=int(m.group(3))
            if rel.startswith("reports/"): continue
            key=rel if rel in ALIAS else rel
            # resolve qualified
            cand = rel if os.path.exists(os.path.join(UP,rel)) else ALIAS.get(rel)
            if not cand or not os.path.exists(os.path.join(UP,cand)):
                # corpus-level file?
                if os.path.exists(os.path.join(ROOT,rel)): continue
                print(f"  [{ln}] {rel}:{num} -> UNRESOLVABLE"); n_bad+=1; continue
            n=len(load(cand))
            if num>n:
                print(f"  [{ln}] {rel}:{num} -> OUT OF RANGE ({n} lines)"); n_bad+=1
            else: n_ok+=1
    print(f"  resolved-in-range: {n_ok}   problems: {n_bad}")
