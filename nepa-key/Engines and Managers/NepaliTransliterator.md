# NepaliTransliterator

[`NepaliTransliterator.swift`](file:///Users/srt/Projects/XcodeProjects/multilingual-keyboard-ios/nepa-key/Engines%20and%20Managers/NepaliTransliterator.swift) is a stateless, pure-Swift transliteration and phonetic conversion engine. It converts Roman (Latin alphabet) text into Devanagari script (Nepali) and Nepal Lipi (Newa script), handles smart typing suggestions with phonetic heuristics and dictionary prefix matches, and provides digit and punctuation conversions.

Origin: Ported from Callijatra's web transliterator (`transliterate.html` / `NepaliTransliterator.kt`).

---

## 1. Architecture Overview

`NepaliTransliterator` is declared as an uninhabited `enum` (the Swift namespace pattern), preventing instantiation and exposing only static methods and data structures:

```
[ Roman Keyboard Input (Buffer) ]
              │
              ▼
   NepaliTransliterator.transliterate()
   ├── Rule matching (greedy longest prefix)
   └── Consonant / Vowel / Diacritic State Machine
              │
              ├──▶ [ Devanagari Output (नेपाली) ]
              │
              ▼ (optional)
   NepaliTransliterator.devaToNewa()
   ├── Triple-scalar ligature matching (ङ्ह, ञ्ह, र्ह)
   └── Direct scalar mapping (vowels, consonants, matras, digits)
              │
              └──▶ [ Nepal Lipi Output (नेपाल लिपि / Newa) ]
```

---

## 2. Core Transliteration Engine (`transliterate(_:)`)

### Character Classification Types
The engine classifies transliteration rules into three types:
- `consonant` (`1`): Base consonants (क, ख, ग, ...) and multi-character consonant clusters (क्ष, ज्ञ, त्र, ...).
- `vowel` (`2`): Independent vowels (अ, आ, इ, ई, ...) which become dependent vowel signs (matras: ा, ि, ी, ...) when preceded by a consonant.
- `diacritic` (`3`): Signs such as Anusvara (`ं`), Visarga (`ः`), Chandrabindu (`ँ`), or explicit Halanta/Virama (`्`).

### The Virama & Matra State Machine
In Devanagari, every consonant has an inherent vowel sound `/a/`. When writing phonetically:
1. **Consonant + Consonant (Clustering/Conjuncts):**
   - When a consonant is encountered while `prevConsonant == true`, the engine automatically injects a `virama` (हलन्त `\u{094D}`) between them:
     - `k` + `t` → `क्` + `त` = `क्त`
2. **Consonant + Vowel (Matra Application):**
   - When a vowel rule matches while `prevConsonant == true`, the engine looks up `matraMap`:
     - If the vowel is `अ` (`\u{0905}`), `matraMap` returns `""` (empty string). This cancels the inherent halanta without adding an extra symbol: `k` (`क`) + `a` → `क`.
     - For other vowels, the independent vowel is replaced with its dependent matra: `k` (`क`) + `i` (`इ`) → `कि` (`क` + `ि`).
     - Resets `prevConsonant = false`.
3. **Independent Vowels:**
   - If a vowel appears at the beginning of a word or after another vowel/diacritic (`prevConsonant == false`), the independent vowel character is output directly:
     - `a` → `अ`, `aa` → `आ`, `i` → `इ`.
4. **Diacritics:**
   - Appended directly to the output string; resets `prevConsonant = false`.

---

## 3. Rule Matching & Priority

Rules are matched greedily using **longest prefix matching** (`matchRule(_:at:)`):
- The `rules` array is deliberately sorted from longest Roman string to shortest within phonetic groups.
- Iteration checks `tail.hasPrefix(r.roman)`. The first matching rule wins.

### Mapping Categories

| Category | Roman Input | Devanagari Output | Unicode Scalar(s) | Type |
| :--- | :--- | :--- | :--- | :--- |
| **3-Char Conjuncts** | `ksh`, `Ksh`, `X`, `x` | क्ष | `\u{0915}\u{094D}\u{0937}` | Consonant |
| | `chh` | छ | `\u{091B}` | Consonant |
| **Vocalic Vowel** | `rri` | ऋ | `\u{090B}` (matra `\u{0943}`) | Vowel |
| **Digraph Consonants** | `kh`, `Kh` | ख | `\u{0916}` | Consonant |
| | `gh`, `Gh` | घ | `\u{0918}` | Consonant |
| | `ch` | च | `\u{091A}` | Consonant |
| | `Ch` | छ | `\u{091B}` | Consonant |
| | `jh`, `Jh`, `z` | झ | `\u{091D}` | Consonant |
| | `Th` | ठ | `\u{0920}` | Consonant (Retroflex aspirated) |
| | `Dh` | ढ | `\u{0922}` | Consonant (Retroflex aspirated) |
| | `th` | थ | `\u{0925}` | Consonant (Dental aspirated) |
| | `dh` | ध | `\u{0927}` | Consonant (Dental aspirated) |
| | `ph`, `Ph`, `f`, `F` | फ | `\u{092B}` | Consonant |
| | `bh`, `Bh`, `B` | भ | `\u{092D}` | Consonant |
| | `sh` | श | `\u{0936}` | Consonant (Palatal) |
| | `Sh` | ष | `\u{0937}` | Consonant (Retroflex) |
| | `s`, `S` | स | `\u{0938}` | Consonant (Dental) |
| | `ng`, `Ng` | ङ | `\u{0919}` | Consonant |
| | `nh`, `Nh` | ञ | `\u{091E}` | Consonant |
| | `hm` | ह्म | `\u{0939}\u{094D}\u{092E}` | Consonant |
| | `hn` | ह्न | `\u{0939}\u{094D}\u{0928}` | Consonant |
| | `lh`, `Lh`, `L` | ळ | `\u{0933}` | Consonant |
| | `tr`, `Tr` | त्र | `\u{0924}\u{094D}\u{0930}` | Consonant |
| | `gn`, `Gn`, `Z` | ज्ञ | `\u{091C}\u{094D}\u{091E}` | Consonant |
| | `Q` | क्व | `\u{0915}\u{094D}\u{0935}` | Consonant |
| **Case Distinction** | `T` vs `t` | ट vs त | `\u{091F}` vs `\u{0924}` | Retroflex vs Dental |
| | `D` vs `d` | ड vs द | `\u{0921}` vs `\u{0926}` | Retroflex vs Dental |
| | `N` vs `n` | ण vs न | `\u{0923}` vs `\u{0928}` | Retroflex vs Dental |
| **Vowels & Diphthongs**| `a` / `aa`, `A` | अ / आ | `\u{0905}` / `\u{0906}` | Vowel |
| | `i` / `ii`, `ee`, `I`| इ / ई | `\u{0907}` / `\u{0908}` | Vowel |
| | `u` / `uu`, `oo`, `U`| उ / ऊ | `\u{0909}` / `\u{090A}` | Vowel |
| | `e` / `ai`, `E` | ए / ऐ | `\u{090F}` / `\u{0910}` | Vowel |
| | `o` / `au`, `O` | ओ / औ | `\u{0913}` / `\u{0914}` | Vowel |
| **Diacritics** | `M` | Anusvara (ं) | `\u{0902}` | Diacritic |
| | `H` | Visarga (ः) | `\u{0903}` | Diacritic |
| | `~` | Candrabindu (ँ)| `\u{0901}` | Diacritic |
| | `\|` | Virama/Halanta (्)| `\u{094D}` | Diacritic |

---

## 4. Matra Mapping (`matraMap`)

When a vowel follows a consonant, it transforms into its corresponding matra sign:

| Independent Vowel | Dependent Matra | Character | Name |
| :---: | :---: | :---: | :--- |
| `अ` (`\u{0905}`) | `""` | *(none)* | Inherent vowel (cancels halanta) |
| `आ` (`\u{0906}`) | `\u{093E}` | `ा` | Aakar |
| `इ` (`\u{0907}`) | `\u{093F}` | `ि` | Hrasva Ikar |
| `ई` (`\u{0908}`) | `\u{0940}` | `ी` | Dirgha Ikar |
| `उ` (`\u{0909}`) | `\u{0941}` | `ु` | Hrasva Ukar |
| `ऊ` (`\u{090A}`) | `\u{0942}` | `ू` | Dirgha Ukar |
| `ए` (`\u{090F}`) | `\u{0947}` | `े` | Ekar |
| `ऐ` (`\u{0910}`) | `\u{0948}` | `ै` | Aikar |
| `ओ` (`\u{0913}`) | `\u{094B}` | `ो` | Okar |
| `औ` (`\u{0914}`) | `\u{094C}` | `ौ` | Aukar |
| `ऋ` (`\u{090B}`) | `\u{0943}` | `ृ` | Rrikar |

---

## 5. Candidate Suggestions & Heuristics (`suggestionTexts(for:limit:)`)

The transliterator generates a ranked list of suggestions for dynamic typing in the suggestion bar:

1. **Exact Rule Transliteration:** Transliterates the raw input buffer (e.g., `namaste` → `नमस्ते`).
2. **Explicit Halanta Candidate:** Transliterates `buffer + "|"` to offer words ending in a pure consonant without an implied vowel (e.g., `nepal` vs `nepal|`).
3. **Nasal Variations:**
   - If buffer ends in `n`, `m`, `N`, or `M`, generates a candidate with Anusvara (`ं`, `\u{0902}`).
   - If buffer ends in `n` or `N`, also generates a candidate with Candrabindu (`ँ`, `\u{0901}`).
4. **Vowel Alternates:**
   - Swaps short/long vowel pairs at the end of the buffer:
     - `a` ↔ `aa`
     - `i` ↔ `ii` (and `ee` → `ii`)
     - `u` ↔ `uu` (and `oo` → `uu`)
     - `e` ↔ `ai`
     - `o` ↔ `au`
5. **Consonant Capitalization Alternates:**
   - Toggles dental/retroflex on trailing characters: `t` ↔ `T`, `d` ↔ `D`, `n` ↔ `N`, `s` ↔ `S`, `b` ↔ `B`, `c` ↔ `C`, `l` ↔ `L`.
6. **Sibilant Alternation:**
   - Toggles `sh` ↔ `Sh` (श ↔ ष).
7. **De-aspiration Heuristic:**
   - If buffer ends in `h` (length ≥ 2), drops `h` to offer the unaspirated variant (e.g., `kh` → `k`).
8. **Dictionary Prefix Matching:**
   - Looks up Devanagari prefixes in `NepaliTransliterationDictionary.devanagariWords` to suggest complete lexicon words matching the typed stem.

---

## 6. Nepal Lipi (Newa) Conversion (`devaToNewa(_:)`)

Converts Devanagari strings into Nepal Lipi (Newa script, Unicode block `U+11400`–`U+1145F`).

### Two-Phase Conversion
1. **3-Scalar Ligature Detection (Triples):**
   - `ङ` + `्` + `ह` (`ङ्ह`) → `𑐓` (`U+11413`, Newa Letter Nyha)
   - `ञ` + `्` + `ह` (`ञ्ह`) → `𑐙` (`U+11419`, Newa Letter Nnyha)
   - `र` + `्` + `ह` (`र्ह`) → `𑐭` (`U+1142D`, Newa Letter Rha)
2. **Single Scalar Replacement:**
   - Comprehensive lookup table mapping:
     - Independent vowels (`अ` → `𑐀`, `आ` → `𑐁`, etc.)
     - Consonants (`क` → `𑐎`, `ख` → `𑐏`, ..., `ह` → `𑐴`, `ळ` → `𑐯`)
     - Dependent vowel signs / matras (`ा` → `𑐵`, `ि` → `𑐶`, etc.)
     - Signs & virama (`्` → `𑑂`, `ँ` → `𑑃`, `ं` → `𑑄`, `ः` → `𑑅`, `ॐ` → `𑑉`)
     - Punctuation (`।` → `𑑋`, `॥` → `𑑌`)
     - Numerals (`०`–`९` → `𑑐`–`𑑙`)

### Newa Suggestions (`suggestionTextsNewa(for:limit:)`)
Transliterates Roman input to Devanagari candidates, transforms each candidate to Newa using `devaToNewa`, and adds prefix matches from `NewaTransliterationDictionary.newaWords`.

---

## 7. Digits and Punctuation

- **Digits:** `devanagariDigit(for:)` maps ASCII `'0'`–`'9'` to Devanagari `'०'`–`'९'` (`\u{0966}`–`\u{096F}`).
- **Punctuation:** `devanagariPunctuation` maps:
  - `.` → `।` (`\u{0964}`, Single Danda / पूर्णविराम)
  - `..` → `॥` (`\u{0965}`, Double Danda)
  - `'` → `ऽ` (`\u{093D}`, Avagraha)
  - `,`, `!`, `?`, `(`, `)`, `-` → Pass-through unchanged.

---

## 8. Ya + Virama (ZWNJ) Autocorrect

To preserve proper letterform and prevent unwanted conjunct ligatures, typing **Ya + Virama** in both Devanagari and Nepal Lipi (Newa) automatically appends a **Zero Width Non-Joiner (ZWNJ, `U+200C`)**:

1. **Nepal Lipi (Newa):**
   - When `"𑐫"` (`\u{1142B}`) is followed by `"𑑂"` (`\u{11442}`), the sequence is replaced with:
     $$\text{"𑐫𑑂"} \implies \text{"𑐫𑑂\u{200C}"} \quad (\text{U+1142B} + \text{U+11442} + \text{U+200C})$$
2. **Devanagari:**
   - When `"य"` (`\u{092F}`) is followed by `"्"` (`\u{094D}`), the sequence is replaced with:
     $$\text{"य्"} \implies \text{"य्\u{200C}"} \quad (\text{U+092F} + \text{U+094D} + \text{U+200C})$$

### Execution Across All Layouts
- **Direct Typing:** In [`KeyboardViewController.swift`](file:///Users/srt/Projects/XcodeProjects/multilingual-keyboard-ios/nepa-key/Controllers/KeyboardViewController.swift), `autocorrectTextForInsertion` inspects the trailing character in `documentContextBeforeInput`. If the field ends with `य` (or `𑐫`) and the typed character is virama `्` (or `𑑂`), it appends `\u{200C}` immediately.
- **Transliteration & Dictionaries:** In [`NepaliTransliterator.swift`](file:///Users/srt/Projects/XcodeProjects/multilingual-keyboard-ios/nepa-key/Engines%20and%20Managers/NepaliTransliterator.swift), `applyYaViramaAutocorrect` and `applyYaViramaAutocorrectNewa` ensure transliterated candidates and dictionary prefix matches seamlessly handle the ZWNJ character.

