-- Filetype detection for Yocto/BitBake layouts.
--
-- Neovim only recognizes systemd units under a path containing "systemd/"
-- (e.g. /etc/systemd/system/foo.service). Yocto recipes ship unit files inside
-- the recipe's own directory, recipes-<x>/<pkg>/<pkg>/<pkg>.service, which never
-- matches, so those buffers get no filetype and no highlighting at all.
--
-- Matching on extension alone is fine here: these are unambiguous systemd unit
-- suffixes, and syntax/systemd.vim ships with Neovim, so this needs no parser.
-- Only the suffixes that actually appear in recipe dirs. .link/.network files here
-- live under a systemd/ path already, so upstream detection covers them.
-- .bb / .bbappend / .inc already resolve to bitbake upstream.
vim.filetype.add({
  extension = {
    service = "systemd",
    socket = "systemd",
    timer = "systemd",
  },
})
