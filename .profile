for bindir in $(find "$HOME/bin" -type d); do
    PATH="$bindir:$PATH"
done
PATH="$HOME/.cabal/bin:$PATH"

for mandir in $(find "$HOME/Programs" -type d -name man); do
    MANPATH="$mandir:$MANPATH"
done
