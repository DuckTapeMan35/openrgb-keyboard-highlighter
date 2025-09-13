# Openrgb keyboard highlighter

Support for highlighting keys when held according to a configuration file with pywal, i3wm and hyprland integration, supports key combinations of any order/size

## Requirements

### General requirements

- i3wm (optional)
- hyprland (optional)
- pywal (optional)
- python
- openrgb

### Python libraries

- i3ipc (optional)
- keyboard
- watchdog
- pyyaml
- openrgb-python

```bash
sudo python -m venv /root/openrgb_keyboard_highlighter_venv
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install --upgrade pip
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install keyboard openrgb-python watchdog yaml i3ipc
```

## Setup

```bash
git clone https://github.com/DuckTapeMan35/openrgb-keyboard-highlighter
cd openrgb-keyboard-highlighter
chmod +x setup.sh
./setup.sh
```

You need yay or paru for this setup script to work.

This will create a daemon for root that runs the highlighter. There is a 5 second delay on startup to ensure the openrgb server is running correctly so it's normal if the lighting effect takes a bit on startup, I couldn't get this delay to be smaller reliably.

If you don't want to run this as a daemon (as it is intended) it must be run as root and with the environment variable `OPENRGB_USER` set as your user.

Afterwards simply edit the config file under `.config/openrgb-keyboard-highlighter/`, below I use my personal config file as an example.

## Configuration file

The configuration file should be named config.yaml and be placed under `.config/openrgb-keyboard-highlighter/`

Here is my personal config file that I will be detailing the workings of:

```yaml
pywal: true
window_manager: hyprland
log_level: info

key_positions:
  # Define positions for individual keys, the tuple corrsponds to (row, column) of they keyboard as defioned by openrgb
  # Alternatively you can also use key names instead of tuples
  q:
    - (2, 1)
  d:
    - 'd'
  x:
    - 'x'
  i:
    - 'i'
  s:
    - 's'
  1_key:
    - '1'
  2_key:
    - '2'
  3_key:
    - '3'
  4_key:
    - '4'
  5_key:
    - '5'
  6_key:
    - '6'
  7_key:
    - '7'
  8_key:
    - '8'
  9_key:
    - '9'
  0_key:
    - '0'

  # Define positions for special keys
  super: 
    - 'left windows'
  enter: 
    - 'enter'
  shift:
    - 'left shift'
    - 'right shift'

  # Define groups of keys
  numbers:
    - '1'
    - '2'
    - '3'
    - '4'
    - '5'
    - '6'
    - '7'
    - '8'
    - '9'
    - '0'
  # You can also use a list
  arrows: ['right arrow', 'left arrow' , 'up arrow', 'down arrow']

modes:
  # Base mode - applied when no keys are pressed
  base:
    rules:
      - keys: [all]
        color: color[9]
      - keys: [numbers]
        condition: non_empty_workspaces
        value: false
        color: color[3]
      - keys: [numbers]
        condition: non_empty_workspaces
        value: true
        color: color[15]

  # Single-key modes
  super:
    rules:
      - keys: [numbers]
        condition: non_empty_workspaces
        value: false
        color: color[3]
      - keys: [numbers]
        condition: non_empty_workspaces
        value: true
        color: color[15]
      - keys: [super]
        color: [255, 255, 255]
      - keys: [enter]
        color: color[7]
      - keys: [d]
        color: color[2] 
      - keys: [x]
        color: [255, 0, 0]
      - keys: [i]
        color: color[3]
      - keys: [arrows]
        color: color[1]
      - keys: [shift]
        color: [255, 255, 255]

  # n-key combination modes are formated as KeyBeingHeld_NewKeyBeingHeld_etc
  super_shift:
    rules:
      - keys: [numbers]
        condition: non_empty_workspaces
        value: false
        color: color[3]
      - keys: [numbers]
        condition: non_empty_workspaces
        value: true
        color: color[15]
      - keys: [super]
        color: [255, 255, 255]
      - keys: [q]
        color: [255, 0, 0]
      - keys: [shift]
        color: [255, 255, 255]
      - keys: [arrows]
        color: color[1]
      - keys: [s]
        color: color[6]

  
  alt:
    rules:
      - keys: [1_key]
        color: [188,214,160]
      - keys: [2_key]
        color: [143,143,144]
      - keys: [3_key]
        color: [99,146,152]
      - keys: [4_key]
        color: [57,99,88]
      - keys: [5_key]
        color: [173,74,44]
      - keys: [6_key]
        color: [146,120,150]
      - keys: [7_key]
        color: [93,185,213]
      - keys: [8_key]
        color: [38,52,115]
      - keys: [9_key]
        color: [43,86,138]
      - keys: [10_key]
        color: [131,97,130]
```

### Pywal
`pywal: true/false`, will determine wether or not pywal will be integrated.

### window_manager

`window_manager: i3/sway/hyprland` determines wether or not i3/sway/hyprland integration is needed.

### Log

The line `log_level: debug/info/warning/error/critical` sets the level, by default `log_level` is `info`.

### Key positions

Key positions follow the structure of

```yaml
key_positions:
  key_name: 
    - (2, 1)
```

key_name can be anything and the tuple corresponds to the (row, column) of the key as defined by openrgb matrix of your keyboard, or you can use the key name (not case sensitive). It is also possible to define a key as having several positions/names, that is, a key group. rules applied to a key group will apply to all keys in said group. Rules are applied sequentially.

### Modes

#### Base

The base mode is of special importance, it represents what happens when no valid key combos are held, I recommend setting this to a single solid color or a solid color with workspaces.

#### Keys and Rules

- Single keys

Single keys follow the structure of:

```yaml
KeyHeld:
    rules:
      - keys: [key_name]
        condition: non_empty_workspaces
        value: true/false
        color: color[pywal_color_numeber] or [R,G,B]
```

For now the only condition is non_empty_workspaces, for it to work the workspaces must be renamed to numbers (1-10) and it can only be applied to numbers.

As an example if key_name is 6 and it's position corresponds to the 6 key on the keyboard and the value of the condition is true the key will be lit up with the given color if there is a window open on the workspace, if the value is false then it will be lit up with the provided color if there are no windows in the corresponding workspace.

- n keys

n keys refers to when n keys are being held together, they follow the structure of FirstKeyHeld_SecondKeyHeld_etc . As an example let's take super_shift, this mode and its rules will only trigger when first super is held and then shift is held.

Note: if you don't care about order you need to add both super_shift and shift_super with the same rules.
