"""
Hex Viewer.

Licensed under MIT
Copyright (c) 2011-2015 Isaac Muse <isaacmuse@gmail.com>
"""
import sublime
import sublime_plugin
import re
from os.path import basename
from struct import unpack
import HexViewer.hex_common as common
from binascii import unhexlify, hexlify
from HexViewer.hex_notify import error

HIGHLIGHT_EDIT_SCOPE = "keyword"
HIGHLIGHT_EDIT_ICON = "none"
HIGHLIGHT_EDIT_STYLE = "underline"


class HexEditGlobal(object):
    """Hex edit global object."""

    bfr = None
    region = None

    @classmethod
    def clear(cls):
        """Clear."""

        cls.bfr = None
        cls.region = None


class HexEditApplyCommand(sublime_plugin.TextCommand):
    """Apply edits to the view."""

    def run(self, edit):
        """Run command."""

        self.view.replace(edit, HexEditGlobal.region, HexEditGlobal.bfr)


class HexEditorListenerCommand(sublime_plugin.EventListener):
    """Hex Editor listener command."""

    fail_safe_view = None
    handshake = -1

    def restore(self, value):
        """Restore."""

        window = sublime.active_window()
        view = None
        if value.strip().lower() == "yes" and self.fail_safe_view is not None:
            # Quit if cannot find window
            if window is None:
                self.reset()
                return

            # Get new view if one was created
            if self.handshake != -1:
                for v in window.views():
                    if self.handshake == v.id():
                        view = v
                        # Reset handshake so view won't be closed
                        self.handshake = -1
            if view is None:
                view = window.new_file()

            # Restore view
            if view is not None:
                # Get highlight settings
                highlight_scope = common.hv_settings("highlight_edit_scope", HIGHLIGHT_EDIT_SCOPE)
                highlight_icon = common.hv_settings("highlight_edit_icon", HIGHLIGHT_EDIT_ICON)
                style = common.hv_settings("highlight_edit_style", HIGHLIGHT_EDIT_STYLE)

                # No icon?
                if highlight_icon == "none":
                    highlight_icon = ""

                # Process highlight style
                if style == "outline":
                    style = sublime.DRAW_OUTLINED
                elif style == "none":
                    style = sublime.HIDDEN
                elif style == "underline":
                    style = sublime.DRAW_EMPTY_AS_OVERWRITE
                else:
                    style = 0

                # Setup view with saved settings
                view.set_name(basename(self.fail_safe_view["name"]) + ".hex")
                view.settings().set("hex_viewer_bits", self.fail_safe_view["bits"])
                view.settings().set("hex_viewer_bytes", self.fail_safe_view["bytes"])
                view.settings().set("hex_viewer_actual_bytes", self.fail_safe_view["actual"])
                view.settings().set("hex_viewer_file_name", self.fail_safe_view["name"])
                view.settings().set("font_face", self.fail_safe_view["font_face"])
                view.settings().set("font_size", self.fail_safe_view["font_size"])
                view.set_syntax_file("Packages/HexViewer/Hex.%s" % common.ST_SYNTAX)
                view.sel().clear()
                HexEditGlobal.bfr = self.fail_safe_view["buffer"]
                HexEditGlobal.region = sublime.Region(0, view.size())
                view.run_command("hex_edit_apply")
                HexEditGlobal.clear()
                view.set_scratch(True)
                view.set_read_only(True)
                view.sel().add(sublime.Region(common.ADDRESS_OFFSET, common.ADDRESS_OFFSET))
                view.add_regions(
                    "hex_edit",
                    self.fail_safe_view["edits"],
                    highlight_scope,
                    highlight_icon,
                    style
                )
        self.reset()

    def reset(self):
        """Rest."""
        window = sublime.active_window()
        if window is not None and self.handshake != -1:
            for v in window.views():
                if self.handshake == v.id():
                    window.focus_view(v)
                    window.run_command("close_file")
        self.fail_safe_view = None
        self.handshake = -1

    def on_close(self, view):
        """Handle the close event."""

        if view.settings().has("hex_viewer_file_name") and common.is_hex_dirty(view):
            window = sublime.active_window()
            file_name = file_name = view.settings().get("hex_viewer_file_name")

            if window is not None and file_name is not None:
                # Save hex view settings
                self.fail_safe_view = {
                    "buffer": view.substr(sublime.Region(0, view.size())),
                    "bits": view.settings().get("hex_viewer_bits"),
                    "bytes": view.settings().get("hex_viewer_bytes"),
                    "actual": view.settings().get("hex_viewer_actual_bytes"),
                    "name": file_name,
                    "font_face": view.settings().get("font_face"),
                    "font_size": view.settings().get("font_size"),
                    "edits": view.get_regions("hex_edit")
                }

                # Keep window from closing by creating a view
                # If the last is getting closed
                # Use this buffer as the restore view if restore occurs
                count = 0
                for v in window.views():
                    if not v.settings().get("is_widget"):
                        count += 1
                if count == 1:
                    view = sublime.active_window().new_file()
                    if view is not None:
                        self.handshake = view.id()

                # Alert user that they can restore
                window.show_input_panel(
                    ("Restore %s? (yes | no):" % basename(file_name)),
                    "yes",
                    self.restore,
                    None,
                    lambda: self.restore(value="yes")
                )


class HexDiscardEditsCommand(sublime_plugin.WindowCommand):
    """Discard current edits."""

    def is_enabled(self):
        """Check if command is enabled."""

        return bool(common.is_enabled() and len(self.window.active_view().get_regions("hex_edit")))

    def run(self):
        """Run command."""
        view = self.window.active_view()
        group_size = int(view.settings().get("hex_viewer_bits", None))
        bytes_wide = int(view.settings().get("hex_viewer_actual_bytes", None))
        common.clear_edits(view)
        self.window.run_command('hex_viewer', {"bits": group_size, "bytes": bytes_wide})


class HexEditorCommand(sublime_plugin.WindowCommand):
    """Hex editor command."""

    handshake = -1

    def init(self):
        """Initialize."""

        init_status = False

        # Get highlight settings
        self.highlight_scope = common.hv_settings("highlight_edit_scope", HIGHLIGHT_EDIT_SCOPE)
        self.highlight_icon = common.hv_settings("highlight_edit_icon", HIGHLIGHT_EDIT_ICON)
        style = common.hv_settings("highlight_edit_style", HIGHLIGHT_EDIT_STYLE)

        # No icon?
        if self.highlight_icon == "none":
            self.highlight_icon = ""

        # Process highlight style
        self.highlight_style = 0
        if style == "outline":
            self.highlight_style = sublime.DRAW_OUTLINED
        elif style == "none":
            self.highlight_style = sublime.HIDDEN
        elif style == "underline":
            self.highlight_style = sublime.DRAW_EMPTY_AS_OVERWRITE

        # Get Seetings from settings file
        group_size = self.view.settings().get("hex_viewer_bits", None)
        self.bytes_wide = self.view.settings().get("hex_viewer_actual_bytes", None)
        # Process hex grouping
        if group_size is not None and self.bytes_wide is not None:
            self.group_size = group_size / common.BITS_PER_BYTE
            init_status = True
        return init_status

    def is_enabled(self):
        """Check if command is enabled."""

        view = self.window.active_view()
        return common.is_enabled() and view is not None and not view.settings().get("hex_viewer_fake", False)

    def apply_edit(self, value):
        """Apply edits."""

        edits = ""
        self.view = self.window.active_view()
        # Is this the same view as earlier?
        if self.handshake != -1 and self.handshake == self.view.id():
            total_chars = self.total_bytes * 2
            selection = self.line["selection"].replace(" ", "")

            # Transform string if provided
            if re.match("^s\:", value) is not None:
                edits = hexlify(value[2:len(value)].encode("ascii")).decode("ascii")
            else:
                edits = value.replace(" ", "").lower()

            # See if change occured and if changes are valid
            if len(edits) != total_chars:
                self.edit_panel(value, "Unexpected # of bytes!")
                return
            elif re.match("[\da-f]{" + str(total_chars) + "}", edits) is None:
                self.edit_panel(value, "Invalid data!")
                return
            elif selection != edits:
                # Get previous dirty markers before modifying buffer
                regions = self.view.get_regions("hex_edit")

                # Construct old and new data for diffs
                edits = self.line["data1"] + edits + self.line["data2"]
                original = self.line["data1"] + selection + self.line["data2"]

                # Initialize
                ascii_str = " :"
                start = 0
                ascii_start_pos = self.ascii_pos
                hex_start_pos = self.line["range"].begin() + common.ADDRESS_OFFSET
                end = len(edits)
                count = 1
                change_start = None

                # Reconstruct line
                l_buffer = self.line["address"]
                while start < end:
                    byte_end = start + 2
                    value = edits[start:byte_end]

                    # Diff data and mark changed bytes
                    if value != original[start:byte_end]:
                        if change_start is None:
                            change_start = [hex_start_pos, ascii_start_pos]
                            # Check if group end
                            if count == self.group_size:
                                regions.append(sublime.Region(change_start[0], hex_start_pos + 2))
                                change_start[0] = None
                        else:
                            # Check if after group end
                            if change_start[0] is None:
                                change_start[0] = hex_start_pos
                            # Check if group end
                            if count == self.group_size:
                                regions.append(sublime.Region(change_start[0], hex_start_pos + 2))
                                change_start[0] = None
                    elif change_start is not None:
                        if self.view.score_selector(hex_start_pos - 1, 'raw.nibble.lower'):
                            if change_start[0] is not None:
                                regions.append(sublime.Region(change_start[0], hex_start_pos))
                        else:
                            if change_start[0] is not None:
                                regions.append(sublime.Region(change_start[0], hex_start_pos - 1))
                        regions.append(sublime.Region(change_start[1], ascii_start_pos))
                        change_start = None

                    # Write bytes and add space and at group region end
                    l_buffer += value
                    if count == self.group_size:
                        l_buffer += " "
                        hex_start_pos += 1
                        count = 0

                    # Copy valid printible ascii chars over or substitute with "."
                    dec = unpack("=B", unhexlify(value))[0]
                    ascii_str += chr(dec) if dec in range(32, 127) else "."
                    start += 2
                    count += 1
                    hex_start_pos += 2
                    ascii_start_pos += 1

                # Check for end of line case for highlight
                if change_start is not None:
                    if change_start[0] is not None:
                        regions.append(sublime.Region(change_start[0], hex_start_pos))
                    regions.append(sublime.Region(change_start[1], ascii_start_pos))
                    change_start = None

                # Append ascii chars to line accounting for missing bytes in line
                delta = int(self.bytes_wide) - len(edits) / 2
                group_space = int(delta / self.group_size) + (1 if delta % self.group_size else 0)
                l_buffer += " " * int(group_space + delta * 2) + ascii_str

                # Apply buffer edit
                self.view.sel().clear()
                self.view.set_read_only(False)
                HexEditGlobal.bfr = l_buffer
                HexEditGlobal.region = self.line["range"]
                self.view.run_command("hex_edit_apply")
                HexEditGlobal.clear()
                self.view.set_read_only(True)
                self.view.sel().add(sublime.Region(self.start_pos, self.end_pos))

                # Underline if required
                if self.highlight_style == sublime.DRAW_EMPTY_AS_OVERWRITE:
                    regions = common.underline(regions)

                # Highlight changed bytes
                self.view.add_regions(
                    "hex_edit",
                    regions,
                    self.highlight_scope,
                    self.highlight_icon,
                    self.highlight_style
                )

                # Update selection
                self.window.run_command('hex_highlighter')
        else:
            error("Hex view is no longer in focus! Edit Failed.")
        # Clean up
        self.reset()

    def reset(self):
        """Reset."""

        self.handshake = -1
        self.total_bytes = 0
        self.start_pos = -1
        self.end_pos = -1
        self.line = {}

    def ascii_to_hex(self, start, end):
        """Convert ascii to hex."""

        num_bytes = 0
        size = end - start
        ascii_range = self.view.extract_scope(start)

        # Determine if selection is within ascii range
        if start >= ascii_range.begin() and end <= ascii_range.end() + 1:
            # Single char selection or multi
            num_bytes = 1 if size == 0 else end - start

        if num_bytes != 0:
            row, column = self.view.rowcol(start)
            column = common.ascii_to_hex_col(start - ascii_range.begin(), self.group_size)
            hex_pos = self.view.text_point(row, column)
            start = hex_pos

            # Traverse row finding the specified bytes
            byte_count = num_bytes
            while byte_count:
                # Byte rising edge
                if self.view.score_selector(hex_pos, 'raw.nibble.upper'):
                    hex_pos += 2
                    byte_count -= 1
                    # End of selection
                    if byte_count == 0:
                        end = hex_pos - 1
                else:
                    hex_pos += 1
        return start, end, num_bytes

    def edit_panel(self, value, error=None):
        """Show edit panel."""

        msg = "Edit:" if error is None else "Edit (" + error + "):"
        self.window.show_input_panel(
            msg,
            value,
            self.apply_edit,
            None,
            self.reset
        )

    def run(self):
        """Run command."""

        self.view = self.window.active_view()

        # Identify view
        if self.handshake != -1 and self.handshake == self.view.id():
            self.reset()
        self.handshake = self.view.id()

        # Single selection?
        if len(self.view.sel()) == 1:
            # Init
            if not self.init():
                self.reset()
                return
            sel = self.view.sel()[0]
            start = sel.begin()
            end = sel.end()
            num_bytes = 0

            # Get range of hex data
            line = self.view.line(start)
            range_start = line.begin() + common.ADDRESS_OFFSET
            range_end = range_start + common.get_hex_char_range(self.group_size, self.bytes_wide)
            hex_range = sublime.Region(range_start, range_end)

            if self.view.score_selector(start, "comment"):
                start, end, num_bytes = self.ascii_to_hex(start, end)

            # Determine if selection is within hex range
            if start >= hex_range.begin() and end <= hex_range.end():
                # Adjust beginning of selection to begining of first selected byte
                if num_bytes == 0:
                    start, end, num_bytes = common.adjust_hex_sel(self.view, start, end, self.group_size)

                # Get general line info for diffing and editing
                if num_bytes != 0:
                    self.ascii_pos = hex_range.end() + common.ASCII_OFFSET
                    self.total_bytes = num_bytes
                    self.start_pos = start
                    self.end_pos = end + 1
                    selection = self.view.substr(sublime.Region(start, end + 1))
                    self.line = {
                        "range": line,
                        "address": self.view.substr(sublime.Region(line.begin(), line.begin() + common.ADDRESS_OFFSET)),
                        "selection": selection.replace(" ", ""),
                        "data1": self.view.substr(sublime.Region(hex_range.begin(), start)).replace(" ", ""),
                        "data2": self.view.substr(sublime.Region(end + 1, hex_range.end() + 1)).replace(" ", "")
                    }

                    # Send selected bytes to be edited
                    self.edit_panel(selection.strip())
