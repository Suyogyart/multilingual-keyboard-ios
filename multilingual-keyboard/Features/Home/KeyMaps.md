# Nepali & Nepal Lipi Transliteration Key Maps

This document provides a comprehensive reference of all key mappings and transliteration rules implemented in **NepaliTransliterator** for both **Devanagari** and **Nepal Lipi (Newa)** scripts.

---

## 1. Vowels & Matras (स्वर र मात्रा)

### Independent Vowels (शब्दको सुरु वा स्वरपछि)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Unicode (Deva / Newa) | Notes / Pronunciation |
|:---|:---:|:---:|:---:|:---|
| `a` | अ | 𑐀 | `U+0905` / `U+11400` | Short a (Schwa) |
| `aa` or `A` | आ | 𑐁 | `U+0906` / `U+11401` | Long aa |
| `i` | इ | 𑐂 | `U+0907` / `U+11402` | Short i (Hrasva) |
| `ii` or `ee` or `I` | ई | 𑐃 | `U+0908` / `U+11403` | Long ii (Dirgha) |
| `u` | उ | 𑐄 | `U+0909` / `U+11404` | Short u (Hrasva) |
| `uu` or `oo` or `U` | ऊ | 𑐅 | `U+090A` / `U+11405` | Long uu (Dirgha) |
| `rri` | ऋ | 𑐆 | `U+090B` / `U+11406` | Vocalic R (e.g. `rriSi` → ऋषि) |
| `e` | ए | 𑐊 | `U+090F` / `U+1140A` | Vowel e |
| `ai` or `E` | ऐ | 𑐋 | `U+0910` / `U+1140B` | Diphthong ai |
| `o` | ओ | 𑐌 | `U+0913` / `U+1140C` | Vowel o |
| `au` or `O` | औ | 𑐍 | `U+0914` / `U+1140D` | Diphthong au |

### Dependent Vowel Signs / Matras (व्यञ्जनसँग जोडिँदा)
When typed after any consonant (e.g., with `k` = क / 𑐎):
| Roman with `k` | Devanagari | Nepal Lipi (Newa) | Matra Name | Example Word |
|:---|:---:|:---:|:---|:---|
| `k` or `ka` | क | 𑐎 | मुक्तरूप (Implicit a) | `kamal` → कमल / 𑐎𑐩𑐮 |
| `kaa` or `kA` | का | 𑐎𑐵 | आकार (ा / 𑐵) | `kaam` → काम / 𑐎𑐵𑐩 |
| `ki` | कि | 𑐎𑐶 | ह्रस्व इकार (ि / 𑐶) | `kitab` → किताब / 𑐎𑐶𑐟𑐵𑐧 |
| `kii` or `kee` or `kI` | की | 𑐎𑐷 | दीर्घ ईकार (ी / 𑐷) | `keet` → कीट / 𑐎𑐷𑐚 |
| `ku` | कु | 𑐎𑐸 | ह्रस्व उकार (ु / 𑐸) | `kura` → कुरा / 𑐎𑐸𑐬𑐵 |
| `kuu` or `koo` or `kU` | कू | 𑐎𑐹 | दीर्घ ऊकार (ू / 𑐹) | `koop` → कूप / 𑐎𑐹𑐥 |
| `krri` | कृ | 𑐎𑐺 | ऋकार (ृ / 𑐺) | `kripa` or `krripa` → कृपा / 𑐎𑐺𑐥𑐵 |
| `ke` | के | 𑐎𑐾 | एकार (े / 𑐾) | `kera` → केरा / 𑐎𑐾𑐬𑐵 |
| `kai` or `kE` | कै | 𑐎𑐿 | ऐकार (ै / 𑐿) | `kaidi` → कैदी / 𑐎𑐿𑐡𑐷 |
| `ko` | को | 𑐎𑑀 | ओकार (ो / 𑑀) | `kosh` → कोश / 𑐎𑑀𑐱 |
| `kau` or `kO` | कौ | 𑐎𑑁 | औकार (ौ / 𑑁) | `kauwa` → कौवा / 𑐎𑑁𑐰𑐵 |

---

## 2. Consonants (व्यञ्जन वर्ण)

### Ka-varga (कण्ठ्य - Velar)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `k` | क | 𑐎 | क (Ka) |
| `kh` or `Kh` | ख | 𑐏 | ख (Kha) |
| `g` | ग | 𑐐 | ग (Ga) |
| `gh` or `Gh` | घ | 𑐑 | घ (Gha) |
| `ng` or `Ng` | ङ | 𑐒 | ङ (Nga) |

### Cha-varga (तालव्य - Palatal)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `c` or `ch` | च | 𑐔 | च (Cha) |
| `chh` or `Ch` or `C` | छ | 𑐕 | छ (Chha) |
| `j` | ज | 𑐖 | ज (Ja) |
| `jh` or `Jh` or `z` | झ | 𑐗 | झ (Jha) |
| `nh` or `Nh` | ञ | 𑐘 | ञ (Nya) |

### Ta-varga (मूर्धन्य - Retroflex)
> **Note Capitalization:** Uppercase `T`, `D`, `N` produce retroflex letters.
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `T` | ट | 𑐚 | ट (Ta - Retroflex) |
| `Th` | ठ | 𑐛 | ठ (Tha - Retroflex) |
| `D` | ड | 𑐜 | ड (Da - Retroflex) |
| `Dh` | ढ | 𑐝 | ढ (Dha - Retroflex) |
| `N` | ण | 𑐞 | ण (Na - Retroflex) |

### Ta-varga (दन्त्य - Dental)
> **Note Lowercase:** Lowercase `t`, `d`, `n` produce dental letters.
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `t` | त | 𑐟 | त (Ta - Dental) |
| `th` | थ | 𑐠 | थ (Tha - Dental) |
| `d` | द | 𑐡 | द (Da - Dental) |
| `dh` | ध | 𑐢 | ध (Dha - Dental) |
| `n` | न | 𑐣 | न (Na - Dental) |

### Pa-varga (ओष्ठ्य - Labial)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `p` | प | 𑐥 | प (Pa) |
| `ph` or `Ph` or `f` or `F` | फ | 𑐦 | फ (Pha / Fa) |
| `b` | ब | 𑐧 | ब (Ba) |
| `bh` or `Bh` or `B` | भ | 𑐨 | भ (Bha) |
| `m` | म | 𑐩 | म (Ma) |

### Antastha (अन्तस्थ - Semivowels)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `y` | य | 𑐫 | य (Ya) |
| `r` | र | 𑐬 | र (Ra) |
| `l` | ल | 𑐮 | ल (La) |
| `v` or `w` | व | 𑐰 | व (Va / Wa) |

### Ushma & Additional (ऊष्म र अन्य)
| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Character Name |
|:---|:---:|:---:|:---|
| `sh` | श | 𑐱 | श (Sha - Talavya) |
| `Sh` | ष | 𑐲 | ष (Sha - Murdhanya) |
| `s` or `S` | स | 𑐳 | स (Sa - Dantya) |
| `h` | ह | 𑐴 | ह (Ha) |
| `L` or `lh` or `Lh` | ळ | 𑐯 | ळ (Retroflex La) |

---

## 3. Special Conjuncts & Ligatures (संयुक्त व्यञ्जन)

| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Description / Example |
|:---|:---:|:---:|:---|
| `ksh` or `Ksh` or `x` or `X` | क्ष | 𑐎𑑂𑐲 | क्ष (`k + sh`) → `kshyama` = क्षमा / 𑐎𑑂𑐲𑐩𑐵 |
| `tr` or `Tr` | त्र | 𑐟𑑂𑐬 | त्र (`t + r`) → `patra` = पत्र / 𑐥𑐟𑑂𑐬 |
| `gn` or `Gn` or `Z` | ज्ञ | 𑐖𑑂𑐘 | ज्ञ (`j + ny`) → `gyan` or `gnan` = ज्ञान / 𑐖𑑂𑐘𑐵𑐣 |
| `Q` | क्व | 𑐎𑑂𑐰 | क्व (`k + v`) conjunct shortcut |
| `hm` | ह्म | 𑐴𑑂𑐩 | ह्म (`h + m`) conjunct |
| `hn` | ह्न | 𑐴𑑂𑐣 | ह्न (`h + n`) conjunct |
| `ng` + `h` (ङ + ् + ह) | ङ्ह | 𑐓 | Nepal Lipi letter **NGAH** (Independent atomic glyph) |
| `nh` + `h` (ञ + ् + ह) | ञ्ह | 𑐙 | Nepal Lipi letter **NYAH** (Independent atomic glyph) |
| `r` + `h` (र + ् + ह) | र्ह | 𑐭 | Nepal Lipi letter **RHA** (Independent atomic glyph) |

---

## 4. Diacritics & Modifiers (चिह्न र संकेतक)

| Roman Keystroke | Devanagari | Nepal Lipi (Newa) | Sign Name | Example Word |
|:---|:---:|:---:|:---|:---|
| `M` | ं | 𑑄 | Anusvara (शिरोबिन्दु) | `saMbidhan` → संविधान / 𑐳𑑄𑐰𑐶𑐢𑐵𑐣 |
| `~` | ँ | 𑑃 | Chandrabindu (चन्द्रबिन्दु) | `kaha~` → कहाँ / 𑐎𑐴𑐵𑑃 |
| `H` | ः | 𑑅 | Visarga (विसर्ग) | `duHkha` → दुःख / 𑐡𑐸𑑅𑐏 |
| `\|` | ् | 𑑂 | Virama / Halant (हलन्त) | `k\|` → क् / 𑐎𑑂 |
| `'` | ऽ | 𑐯/ऽ | Avagraha (अवग्रह) | `so'ham` → सोऽहम् |

---

## 5. Digits (अंकहरु)

| Roman Key | Devanagari Digit | Nepal Lipi (Newa) Digit |
|:---:|:---:|:---:|
| `0` | ० | 𑑐 |
| `1` | १ | 𑑑 |
| `2` | २ | 𑑒 |
| `3` | ३ | 𑑓 |
| `4` | ४ | 𑑔 |
| `5` | ५ | 𑑕 |
| `6` | ६ | 𑑖 |
| `7` | ७ | 𑑗 |
| `8` | ८ | 𑑘 |
| `9` | ९ | 𑑙 |

---

## 6. Punctuation (विराम चिह्न)

| Roman Key | Devanagari | Nepal Lipi (Newa) | Description |
|:---:|:---:|:---:|:---|
| `.` | । | 𑑋 | Purna Virama (पूर्णविराम / Single Danda) |
| `..` | ॥ | 𑑌 | Dirgha Virama (दीर्घविराम / Double Danda) |
| `,`, `!`, `?`, `-`, `(`, `)` | Same | Same | Standard punctuation marks preserved directly |

---

## 7. Key Transliteration & Autocorrect Rules

### Rule 1: Automatic Halant for Consonant Clusters
When typing two consonants back-to-back without an intervening vowel, a Virama (Halant) is automatically inserted between them:
- `kt` → `k` (क) + ् + `t` (त) = **क्त** (𑐎𑑂𑐟)
- `namaste` → `n` (न) + `m` (म) + `s` (स) + ् + `t` (त) + `e` (े) = **नमस्ते** (𑐣𑐩𑐳𑑂𑐟𑐾)

### Rule 2: Ya + Virama Autocorrect with ZWNJ (`य्‌` / `𑐫𑑂‌`)
In traditional Nepali and Newa typography, when a word or morpheme ends with or uses half-Ya (`य्`), inserting a standard Virama often causes the layout engine to inadvertently fuse into an undesirable conjunct form with subsequent letters.
- To maintain the correct half-letter glyph representation, typing `y` followed by Halant automatically appends a **Zero-Width Non-Joiner (ZWNJ: `\u{200C}`)**:
  - Devanagari: `\u{092F}\u{094D}\u{200C}` (**य्‌**)
  - Nepal Lipi: `\u{1142B}\u{11442}\u{200C}` (**𑐫𑑂‌**)

### Rule 3: Vocalic ऋ (`rri`) vs Consonant Ri (`ri`)
- Typing `rri` produces the independent vocalic vowel **ऋ** (`U+090B`) / **𑐆** (`U+11406`), or following a consonant, the vocalic matra **ृ** (`U+0943`) / **𑐺** (`U+1143A`).
  - Example: `rriSi` → **ऋषि** / **𑐆𑐲𑐶**, `krripa` → **कृपा** / **𑐎𑐺𑐥𑐵**
- Typing `ri` produces the consonant **र** with short-i matra **ि** → **रि** / **𑐬𑐶**.
  - Example: `ritu` → **रितु** / **𑐬𑐶𑐟𑐸**
