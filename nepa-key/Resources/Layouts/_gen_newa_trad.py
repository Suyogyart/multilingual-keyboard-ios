#!/usr/bin/env python3
"""One-off: np-trad*.json -> newa-trad*.json using same Devanagari→Newa mapping as NepaliTransliterator.devaToNewa."""
import json
import os

TRIPLES = [
    ("\u0919\u094d\u0939", chr(0x11413)),
    ("\u091e\u094d\u0939", chr(0x11419)),
    ("\u0930\u094d\u0939", chr(0x1142D)),
]

SINGLE = {}
def m(a, b):
    SINGLE[chr(a)] = chr(b)

pairs = [
    (0x0905, 0x11400), (0x0906, 0x11401), (0x0907, 0x11402), (0x0908, 0x11403),
    (0x0909, 0x11404), (0x090A, 0x11405), (0x090B, 0x11406), (0x090C, 0x11408),
    (0x090F, 0x1140A), (0x0910, 0x1140B), (0x0913, 0x1140C), (0x0914, 0x1140D),
    (0x0915, 0x1140E), (0x0916, 0x1140F), (0x0917, 0x11410), (0x0918, 0x11411),
    (0x0919, 0x11412), (0x091A, 0x11414), (0x091B, 0x11415), (0x091C, 0x11416),
    (0x091D, 0x11417), (0x091E, 0x11418), (0x091F, 0x1141A), (0x0920, 0x1141B),
    (0x0921, 0x1141C), (0x0922, 0x1141D), (0x0923, 0x1141E), (0x0924, 0x1141F),
    (0x0925, 0x11420), (0x0926, 0x11421), (0x0927, 0x11422), (0x0928, 0x11423),
    (0x092A, 0x11425), (0x092B, 0x11426), (0x092C, 0x11427), (0x092D, 0x11428),
    (0x092E, 0x11429), (0x092F, 0x1142B), (0x0930, 0x1142C), (0x0932, 0x1142E),
    (0x0935, 0x11430), (0x0936, 0x11431), (0x0937, 0x11432), (0x0938, 0x11433),
    (0x0939, 0x11434), (0x0933, 0x1142F),
    (0x093E, 0x11435), (0x093F, 0x11436), (0x0940, 0x11437), (0x0941, 0x11438),
    (0x0942, 0x11439), (0x0943, 0x1143A), (0x0944, 0x1143B), (0x0947, 0x1143E),
    (0x0948, 0x1143F),
    (0x094B, 0x11440), (0x094C, 0x11441), (0x094D, 0x11442), (0x0901, 0x11443),
    (0x0902, 0x11444), (0x0903, 0x11445), (0x093C, 0x11446), (0x0950, 0x11449),
    (0x0964, 0x1144B), (0x0965, 0x1144C),
    (0x0966, 0x11450), (0x0967, 0x11451), (0x0968, 0x11452), (0x0969, 0x11453),
    (0x096A, 0x11454), (0x096B, 0x11455), (0x096C, 0x11456), (0x096D, 0x11457),
    (0x096E, 0x11458), (0x096F, 0x11459),
    (0x0960, 0x11407), (0x0961, 0x11409), (0x0962, 0x1143C), (0x0963, 0x1143D),
]
for a, b in pairs:
    m(a, b)


def deva_to_newa(text: str) -> str:
    scalars = list(text)
    i = 0
    out = []
    while i < len(scalars):
        matched = False
        if i + 3 <= len(scalars):
            tri = "".join(scalars[i : i + 3])
            for key, val in TRIPLES:
                if tri == key:
                    out.append(val)
                    i += 3
                    matched = True
                    break
        if matched:
            continue
        s = scalars[i]
        out.append(SINGLE.get(s, s))
        i += 1
    return "".join(out)


def convert_val(v):
    if isinstance(v, str):
        return deva_to_newa(v) if any("\u0900" <= c <= "\u097F" or "\uA8E0" <= c <= "\uA8FF" for c in v) else v
    if isinstance(v, list):
        return [convert_val(x) for x in v]
    if isinstance(v, dict):
        return {k: convert_val(val) for k, val in v.items()}
    return v


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    for src_name, code in [
        ("np-trad.json", "newa-trad"),
        ("np-trad-numbers.json", "newa-trad-numbers"),
        ("np-trad-symbols.json", "newa-trad-symbols"),
    ]:
        src = os.path.join(base, src_name)
        with open(src, encoding="utf-8") as f:
            data = json.load(f)
        data["languageCode"] = code
        data = convert_val(data)
        dst = os.path.join(base, src_name.replace("np-trad", "newa-trad"))
        with open(dst, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print("Wrote", dst)


if __name__ == "__main__":
    main()
