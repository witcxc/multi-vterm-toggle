# multi-vterm-toggle.el

An Emacs package to quickly toggle a `multi-vterm` buffer dedicated to your current context (Git repository, file directory, or home).

## Features

- **Smart Context Detection**:
  - **Git Project**: Opens vterm at the project root.
  - **Regular File**: Opens vterm in the file's parent directory.
  - **Other Buffers**: Opens vterm in the Home directory.
- **Smart Toggle**:
  - If the vterm exists and is focused: **Closes the window**.
  - If the vterm exists but is hidden: **Opens it in a split window**.
  - If the vterm doesn't exist: **Creates it** and sets the correct directory.
- **Reusable**: Keeps one terminal per project/directory to avoid clutter.
- **Multi-vterm compatible**: Works alongside existing `multi-vterm` setups.

## Installation

### Manual

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/multi-vterm-toggle.git
   ```
2. Add to your `init.el`:
   ```elisp
   (add-to-list 'load-path "/path/to/multi-vterm-toggle")
   (require 'multi-vterm-toggle)
   ```

### Using `use-package` (Recommended)

Assuming you have the package locally or configured via a recipe:

```elisp
(use-package multi-vterm-toggle
  :load-path "/path/to/multi-vterm-toggle/" ;; If local
  :bind (("C-c t" . multi-vterm-toggle))
  :config
  (setq multi-vterm-toggle-height 0.3) ;; Occupy 30% of screen
  )
```

## Configuration

| Variable | Default | Description |
| :--- | :--- | :--- |
| `multi-vterm-toggle-height` | `0.4` | Fraction of the frame height (0.0 - 1.0) for the terminal window. |
| `multi-vterm-toggle-use-dedicated-window` | `t` | Lock the window to the vterm buffer so other buffers don't steal it. |

## Usage

Bind `multi-vterm-toggle` to your preferred key (e.g., `C-c t` or `F12`).

1. Open a file in a Git repo.
2. Press `C-c t`. A terminal opens at the repo root.
3. Do some work in the terminal.
4. Press `C-c t` again. The terminal window closes (buffer remains alive).
5. Switch to a file in another directory (outside git).
6. Press `C-c t`. A **new**, separate terminal opens for that directory.
