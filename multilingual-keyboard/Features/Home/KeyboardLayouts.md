# Supported Keyboard Layouts

This app supports **5 primary typing layouts** across three writing systems: **Nepal Lipi (Prachalit / Newa)**, **Devanagari (Nepali)**, and **Latin (English)**. Each layout is engineered for authentic script representation, ergonomic touch typing, and native iOS responsiveness.

---

## 1. 𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Traditional) — `newa-trad`

A direct character layout for **Nepal Lipi (नेपाल लिपि / Prachalit script)**, designed for typing Nepalbhasa and Sanskrit texts with authentic typographical fidelity.

- **Script:** Nepal Lipi (Unicode block `U+11400`–`U+1145F`).
- **Primary & Shift Layers:**
  - Base consonants (`𑐎`, `𑐐`, `𑐔`, `𑐖`, `𑐟`, `𑐡`, `𑐥`, `𑐧`, `𑐫`, `𑐬`, `𑐮`, `𑐰`, `𑐳`, `𑐴`, ...) mapped for quick access.
  - Shift layer reveals aspirated letters (`𑐏`, `𑐑`, `𑐕`, `𑐗`, `𑐠`, `𑐢`, `𑐦`, `𑐨`, ...), retroflex series (`𑐚`, `𑐛`, `𑐜`, `𑐝`, `𑐞`), and independent vowels (`𑐀`, `𑐁`, `𑐂`, `𑐃`, `𑐄`, `𑐅`, `𑐆`, `𑐇`, `𑐈`, `𑐉`, `𑐊`, `𑐋`, `𑐌`, `𑐍`).
- **Barakhari & Matra Popovers:**
  - Long-pressing any consonant reveals its complete vowel sign variations (e.g., long-pressing `𑐎` reveals `𑐎𑑂`, `𑐎𑐵`, `𑐎𑐶`, `𑐎𑐷`, `𑐎𑐸`, `𑐎𑐹`, `𑐎𑐺`, `𑐎𑐻`, `𑐎𑐼`, `𑐎𑐽`, `𑐎𑐾`, `𑐎𑐿`, `𑐎𑑀`, `𑐎𑑁`, `𑐎𑑄`, `𑐎𑑅`).
- **Special Ligatures & Autocorrect:**
  - Native support for Newa consonant ligatures: `𑐓` (Nyha), `𑐙` (Nnyha), and `𑐭` (Rha).
  - Automatic Zero Width Non-Joiner (ZWNJ) autocorrect for `𑐫𑑂‌` (Ya + Virama) to maintain distinct locative case markers without unwanted ligature collapsing.

---

## 2. 𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Transliteration) — `newa-translit`

Phonetic Roman-to-Nepal Lipi typing (**EN → 𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵**). Type phonetically using standard English letters, and the keyboard converts your input into Nepal Lipi in real time.

- **How It Works:** Type words the way they sound using the Latin alphabet (e.g., `jwojalapa`, `namaste`, `nepal`).
- **Real-Time Word Suggestions:** The suggestion bar presents prioritized Nepal Lipi candidates and prefix completions powered by the built-in `NewaTransliterationDictionary`.
- **Space & Return Commit:** Tapping the spacebar or return key automatically commits the transliterated word.
- **Ideal For:** Users who want to write in Nepal Lipi without needing to learn the traditional key positions.

---

## 3. नेपाली (Traditional) — `np-trad`

A standardized Devanagari layout based on traditional Nepali typewriter and Unicode keyboard conventions.

- **Script:** Devanagari (`U+0900`–`U+097F`).
- **Direct Character Keys:** Easy access to core consonants, independent vowels, and common conjunct ligatures (`क्ष`, `त्र`, `ज्ञ`).
- **Full Barakhari Alternates:** Long-press any consonant key to view and select all 16 dependent matra forms (Aakar, Hrasva/Deergha Ikar, Ukar, Rrikar `ृ`, `ॄ`, `ॢ`, `ॣ`, Ekar, Aikar, Okar, Aukar, Anusvara `ं`, Visarga `ः`, and Halanta `्`).
- **Typographical Autocorrect:** Automatic Zero Width Non-Joiner insertion on `य्‌` (Ya + Virama) ensures standard Nepali orthography without unwanted half-forms or ligatures.

---

## 4. नेपाली (Transliteration) — `np-translit`

Phonetic Roman-to-Devanagari typing (**EN → नेपाली**). Type Nepali phonetically on a familiar QWERTY layout with intelligent rule heuristics and dictionary suggestions.

- **Greedy Phonetic Engine:** Seamlessly handles digraphs (`kh`, `gh`, `ch`, `chh`, `jh`, `th`, `dh`, `ph`, `bh`, `sh`), retroflex/dental pairs (`t`/`T`, `d`/`D`, `n`/`N`), vocalic R (`rri` → `ऋ`), and conjunct clustering (`kt` → `क्त`).
- **Smart Suggestions:** Dynamic suggestion bar offers short/long vowel alternatives, aspirated variants, anusvara/chandrabindu variations, and lexicon completions from `NepaliTransliterationDictionary`.
- **Speed & Precision:** Tap space or return to accept the transliterated word.

---

## 5. English (US) — `en-US`

A fast, native-feeling English keyboard following Apple iOS interaction standards.

- **Layout:** Standard QWERTY arrangement.
<!-- - **Smart Predictive Engine:**
  - Prefix-based word suggestions as you type.
  - Contextual next-word predictions following completed words. -->
- **Shortcuts:** Double-tap spacebar to insert a period and space (`. `).
- **Shift & Caps Lock:** Single-tap Shift for capitalized initial; double-tap for Caps Lock.

---

## 6. Numbers, Symbols & Punctuation

Each language mode includes specialized auxiliary keyboards accessible via the `123` / `numbers` and `#+=` / `symbols` keys:

- **English Mode:** ASCII digits `0`–`9` and standard punctuation marks.
- **Nepali Mode:** Devanagari numerals `०`–`९`, Purna Virama (`।`), Deergha Virama (`॥`), and Avagraha (`ऽ`).
- **Nepal Lipi Mode:** Authentic Nepal Lipi numerals `𑑐`–`𑑙` (`U+11450`–`U+11459`) and traditional Newa punctuation marks (`𑑋`, `𑑌`).
- **Emoji Keyboard:** Built-in emoji layout with recent emoji tracking and categorized icons.

---

## 7. How to Switch Layouts

- **Globe Key (`🌐`):**
  - **Single Tap:** Instantly cycles to the next enabled language layout.
  - **Long Press:** Opens a quick-select popup menu displaying all available languages for immediate switching.
- **Spacebar Indicator:** The spacebar displays the active language name (e.g., `नेपाली`, `𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵`, `EN -> नेपाली`, `English (US)`).
