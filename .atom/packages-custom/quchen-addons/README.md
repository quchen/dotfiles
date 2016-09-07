# Quchen’s Atom addons



## Alignment

The alignment script differs from all  other alignment functions and packages by
not being "smart", having a predictable outcome, and not being shit in general.

### Multi-align

Align the first unaligned selection of each line

![][multialign]

### Align right

Align the first selection of each line by their right ends

![][align-right]

### Available commands

  - `quchen:align-multi`: Alignment with the first non-aligned selection of
    each line.
  - `quchen:align-right`: Insert spaces at the end to align to the right of the
    first selection of each line.



## Close all open parentheses

![For all selected unbalanced parentheses, insert the matching closing one.][balance]

### Available commands

  - `quchen:close-open-parentheses`



## Collapse vertical whitespace

In order to standardize my vertical space usage, this script

  - Shrinks 2 empty lines to a single one
  - Collapses 4+ empty lines to only 3

### Available commands

  - `quchen:collapse-vertical-space`



## Comment aware

Adds insert line above/below and join lines with above/below while respecting
comments.

  - New line
    - `quchen:comment-aware-newline`
    - `quchen:comment-aware-newline-above`
    - `quchen:comment-aware-newline-below`
  - Join lines
    - `quchen:comment-aware-join-lines-up`
    - `quchen:comment-aware-join-lines-down`



## Cycle selection

The most common use case is swapping two selections, which is a special case of
a cyclic permutation.

![][swap-selections]

### Available commands

  - `quchen:rotate-selection-right`
  - `quchen:rotate-selection-left`



## Delete line

Like Atom's built-in `delete line`, but will maintain the current row of the
cursor, if possible.

### Available commands

  - `quchen:delete-line`



## Duplicate

Duplicate all selections. If nothing is selected, duplicate the entire line.

![][duplicate]

### Available commands

  - `quchen:duplicate`

## Fill line

Fill the line with the selection to either the configured line length, or to
match the length of the previous line. The filling string is either the current
selection, or the character left of the cursor if nothing is selected.

![][fill-to-length-of-previous]

### Available commands

  - `quchen:fill-lines-entirely`: Fill each line to the configured
    `editor.preferredLineLength`.
  - `quchen:fill-lines-to-length-of-previous`: Fill each line to the length of the
    previous line.



## Enumerate selections

Fill all selections with ascending numbers.

![][number-from-1]

### Available commands

  - `quchen:number-from-0`
  - `quchen:number-from-1`
  - `quchen:number-from-first-selection`: Pick the starting number from the first
    selection



## Selection refinement

Based on a language-specific configuration setting, select all matching
substrings. Pairs well with the alignment script.

![][refine]

### Available commands

  - `quchen:refine-by-config`: Select all configured substrings
  - `quchen:refine-by-first-word`: Select all substrings that match the first
    selected non-whitespace substring

### Configuration

```coffee
"*":
  quchen:
    refinements:
      "source.haskell": [
        "="
        "|"
        "::"
        "=>"
        "->"
        "<-"
      ]
      "source.rust": [
        "=>"
      ]
```



## Shell commands

Run a shell command, and insert its result.

### Available commands

  - `quchen:insert-date`:                  2016-08-26
  - `quchen:insert-date-and-time`:         2016-08-26 10:33:06
  - `quchen:insert-date-unix-time`:        1472200390
  - `quchen:insert-date-iso-8601-with-ns`: 2016-08-26T10:33:19,138647952+0200
  - `quchen:insert-date-rfc-3339-with-ns`: 2016-08-26 10:33:26.035962180+02:00



[align-right]:                demos/align-right.gif
[balance]:                    demos/close-all-open-parentheses.gif
[duplicate]:                  demos/duplicate.gif
[fill-to-length-of-previous]: demos/fill-to-length-of-previous.gif
[multialign]:                 demos/multialign.gif
[number-from-1]:              demos/number-from-1.gif
[refine]:                     demos/refine.gif
[swap-selections]:            demos/swap-selections.gif
