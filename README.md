# ⌨️ Universal Multilingual iOS Keyboard Engine

A **data‑driven, high‑performance iOS Custom Keyboard Extension** built
from the ground up to support **complex multilingual scripts** (such as
English and Nepali) while maintaining a **native Apple look and feel**.

This keyboard is designed to be **highly extensible**, allowing new
languages and layouts to be added through configuration rather than code
changes.

------------------------------------------------------------------------

# 🚀 Core Philosophy: Universal Rendering

Unlike traditional keyboards that hardcode button logic, this engine
behaves like a **mathematical rendering system**.

Instead of defining UI components manually, the keyboard:

1.  Consumes a JSON layout
2.  Calculates key frames dynamically
3.  Applies styles and mappings
4.  Renders the keyboard using low‑level layers

This architecture enables:

-   Adding new languages without writing Swift code
-   Supporting complex scripts
-   Dynamically generating layouts
-   Maintaining high performance within iOS extension constraints

------------------------------------------------------------------------

# 🛠 Technical Architecture

## Performance & Memory

Custom keyboards run under strict memory limitations on iOS. This engine
is optimized specifically for those constraints.

**Memory Footprint**

-   \~14MB runtime usage
-   Optimized for the **50--70MB iOS Extension limit**

**Rendering Strategy**

Instead of high-level UIKit components, the engine uses:

-   `CALayer`
-   `CAShapeLayer`
-   `CATextLayer`

This avoids heavy view hierarchies such as:

-   `UIStackView`
-   `UIButton`

Benefits:

-   Smooth **60fps rendering**
-   Lower CPU overhead
-   Reduced memory consumption

------------------------------------------------------------------------

## 🎨 Theming

Supports full **Dark Mode / Light Mode** adaptation.

Technologies used:

-   iOS 17 `registerForTraitChanges`
-   `traitCollection.displayScale`
-   Context-aware system color palettes

------------------------------------------------------------------------

# 🧠 Core Engine

## KeyboardTouchEngineView

This is the **mathematical engine of the keyboard** responsible for
rendering and touch interaction.

### Pythagorean Hit‑Testing

Instead of relying on simple rectangular hit detection, the engine:

-   Calculates the **distance between the touch point and key centers**
-   Selects the **closest key**

Benefits:

-   No dead zones
-   Better edge-of-screen accuracy
-   More forgiving typing

------------------------------------------------------------------------

### Gesture Handling

Integrated gesture logic supports:

-   Long‑press detection
-   Sliding selection for alternate characters

------------------------------------------------------------------------

### Native‑Style Backspace

Implements a **multi‑phase deletion system**:

1.  Single delete on tap
2.  0.4s delay before repetition
3.  Smooth repeating delete
4.  1.5s acceleration for rapid word deletion

This behavior closely mimics the native iOS keyboard.

------------------------------------------------------------------------

# 📄 JSON Layout Schema

Keyboard layouts are defined entirely through JSON files.

### Layout Files

    en-US.json
    en-US-numbers.json
    en-US-symbols.json

------------------------------------------------------------------------

## Key Properties

  ------------------------------------------------------------------------
  Property              Type            Description
  --------------------- --------------- ----------------------------------
  id                    String          Command (e.g. `"space"`,
                                        `"numbers"`) or literal character

  primaryLabel          String          Text shown on the key in lowercase
                                        state

  shiftLabel            String?         Character displayed when Shift is
                                        active

  isAction              Bool?           Applies darker **System Key**
                                        style (Shift, Delete, etc.)

  fontSize              Float?          Optional label size override
                                        (default **22pt**)

  widthMultiplier       Float           Relative width (1.0 = standard
                                        key, 5.0 = spacebar)

  alternates            \[String\]      Characters available via
                                        long‑press
  ------------------------------------------------------------------------

### Example Key Definition

``` json
{
  "id": "a",
  "primaryLabel": "a",
  "shiftLabel": "A",
  "widthMultiplier": 1.0,
  "alternates": ["á","à","â","ä"]
}
```

------------------------------------------------------------------------

# ✨ Implemented Features

-   ✅ **Adaptive Grid Layout**\
    Custom layout math distributes keys across different iPhone screen
    sizes and orientations.

-   ✅ **Three Layout Switching**

    -   ABC
    -   123
    -   #+=

-   ✅ **Smart Shift State Machine**

    Supports:

    -   Lowercase
    -   Uppercase (auto revert)
    -   Caps Lock (double tap detection within **0.3s**)

-   ✅ **Multi‑Row Alternates**

    Long‑press popover grid supports:

    -   Up to **15 characters**
    -   Maximum **3 rows**
    -   Smart bounds checking to prevent screen clipping

-   ✅ **Native Visual Fidelity**

    Carefully replicated iOS keyboard visuals:

    -   1px bottom shadows
    -   Apple-style key color palette
    -   Background blur effects

------------------------------------------------------------------------

# 📂 Project Structure

    KeyboardViewController.swift
    KeyboardTouchEngineView.swift
    AlternatesCalloutView.swift
    LayoutManager.swift
    KeyModel.swift

### KeyboardViewController.swift

Extension entry point responsible for:

-   Keyboard state management
-   Shift handling
-   Layout switching
-   Text input routing via `textDocumentProxy`

------------------------------------------------------------------------

### KeyboardTouchEngineView.swift

Core rendering and interaction engine.

Responsibilities:

-   Layer rendering
-   Touch lifecycle
-   Key highlighting
-   Hit detection

------------------------------------------------------------------------

### AlternatesCalloutView.swift

Floating popover used for alternate characters.

Features:

-   Multi‑row selection grid
-   Dynamic hit detection
-   Smart screen boundary handling

------------------------------------------------------------------------

### LayoutManager.swift

Handles keyboard layout loading and decoding.

Key responsibilities:

-   JSON parsing
-   Layout switching
-   Asset loading using:

```{=html}
<!-- -->
```
    Bundle(for: self)

Ensures JSON assets are accessible inside the **keyboard extension
sandbox**.

------------------------------------------------------------------------

### KeyModel.swift

Defines the **Codable schema** used for keyboard layouts.

------------------------------------------------------------------------

# 🗺 Roadmap

## Phase 2 --- Refined Typing Mechanics

### Double‑Tap Space

Automatically insert:

    ". "

when space is pressed twice.

------------------------------------------------------------------------

### Auto‑Capitalization

Automatic shift activation when:

-   Starting a sentence
-   After punctuation (`.`, `!`, `?`)

------------------------------------------------------------------------

### Key Magnifiers

Classic iOS pop‑up magnifiers appearing above keys during taps to
provide visual confirmation.

------------------------------------------------------------------------

## Phase 3 --- NLP & Predictions

### Trie Dictionary

Efficient dictionary storage for:

-   English
-   Nepali

------------------------------------------------------------------------

### Next‑Word Prediction

Implementation of a **suggestion bar** above the keyboard.

------------------------------------------------------------------------

### Fuzzy Autocorrect

Uses **Levenshtein distance** to correct typing mistakes caused by:

-   Fast typing
-   Edge touches
-   Fat‑finger errors

------------------------------------------------------------------------

# 🧩 Project Goals

-   Support **complex multilingual scripts**
-   Maintain **native iOS keyboard experience**
-   Stay within **strict extension memory limits**
-   Enable **layout‑driven keyboard development**
-   Allow **new languages without changing Swift code**

------------------------------------------------------------------------

# 📜 License

This project is open source and available under the **MIT License**.
