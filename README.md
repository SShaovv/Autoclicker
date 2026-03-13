# ⚡ AutoClicker (AutoHotkey v2)

A lightweight **AutoHotkey v2 AutoClicker** featuring a modern dark interface, multi-key spamming, toggle hotkeys, and a compact **mini floating indicator mode**.
The program is designed to be fast, simple, and unobtrusive while running.

---

# ✨ Features

## ⚡ Key Spamming

The clicker repeatedly sends key presses at high speed.

Multiple keys can be configured by separating them with commas.

Example input:

```
LButton
```

or

```
LButton,RButton,Space
```

Execution order:

```
LButton → RButton → Space → repeat
```

The loop runs using a **1 ms timer**, allowing extremely fast input repetition.

---

## ▶ Start / Stop Controls

The GUI provides two primary control buttons.

**START**

* Begins the key spam loop
* Updates the status indicator

**STOP**

* Stops all key sending

Status indicator:

```
Status: ON   (green)
Status: OFF  (red)
```

---

## ⌨ Toggle Hotkey

A global hotkey can be configured to toggle the clicker while using other programs.

Example workflow:

1. Enter a hotkey (for example `F8`)
2. Click **Set hotkey**
3. Press the hotkey anywhere to toggle the clicker

Available options:

* Set toggle hotkey
* Remove hotkey
* Display the currently active hotkey

---

## 🧭 Mini Floating Mode

The main window can be minimized into a **small floating control bar**.

Mini window elements:

| Element | Function            |
| ------- | ------------------- |
| ⚡       | Application logo    |
| ●       | Activity indicator  |
| +       | Restore main window |

Indicator colors:

* **Green** → clicker active
* **Red** → clicker inactive

Mini window properties:

* Always on top
* Draggable
* Uses minimal screen space

---

## 🎨 Custom Dark Interface

The GUI includes:

* Borderless window
* Custom header bar
* Rounded window corners
* Dark theme
* Clean centered layout

The interface is intentionally minimal and distraction-free.

---

# 🖥 Interface Layout

Main window:

```
Keys to spam
[ input field ]

[ START ]   [ STOP ]

Status: ON / OFF

Toggle hotkey
[ input field ]

[ Set hotkey ] [ Remove hotkey ]

Exit
```

Top bar:

```
⚡ AutoClicker        -
```

The **– button** switches the program into mini floating mode.

---

# ⚙ Technical Details

Language:

```
AutoHotkey v2
```

Core mechanisms used:

* `SetTimer` loop for rapid key sending
* `Send {key}` for simulated keyboard/mouse input
* Windows **GDI drawing** for the mini indicator
* `CreateDIBSection` bitmap rendering
* `CreateRoundRectRgn` for rounded window shapes
* Borderless draggable window via `PostMessage`

---

# 🧩 Internal Behavior

### Click Loop

The timer continuously cycles through configured keys.

Process:

```
1. Read keys from input field
2. Split into array
3. Send current key
4. Move to next index
5. Repeat indefinitely
```

---

### Mini Indicator Rendering

The activity indicator is dynamically drawn using Windows GDI:

1. Create bitmap buffer
2. Fill background
3. Draw circular indicator
4. Display inside the GUI picture control

The dot color automatically reflects whether the clicker is running.

---

# 📦 Installation

There are **two ways to use the program**.

## Option 1 — Run the Script (requires AutoHotkey)

Requirements:

* Windows
* **AutoHotkey v2.0 or newer**

Steps:

1. Install AutoHotkey v2
2. Download the repository
3. Run:

```
AutoClicker.ahk
```

Download AutoHotkey:
https://www.autohotkey.com/

---

## Option 2 — Run the Executable (no AutoHotkey required)

The repository also contains a **compiled `.exe` version**.

Advantages:

* **No AutoHotkey installation required**
* Runs as a standalone application
* Simply download and launch

Steps:

1. Download `AutoClicker.exe`
2. Run the file

---

# 📁 Repository Structure

```
AutoClicker/
│
├─ AutoClicker.ahk
├─ AutoClicker.exe
├─ README.md
└─ LICENSE
```

---

# 📜 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

You are free to:

* Use
* Modify
* Distribute
* Share improvements

Under the condition that **all modified versions must also provide their source code and remain under the same AGPL-3.0 license**.

See the `LICENSE` file for full license text.

---

# ⚠ Disclaimer

This software simulates keyboard and mouse input.
Ensure that its use complies with the rules of any software, game, or service where it is used.

The author is not responsible for misuse.
